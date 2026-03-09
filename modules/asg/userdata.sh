#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== WordPress Installation Started at $(date) ==="

# Update system
apt-get update -y
apt-get upgrade -y

# Install Apache
apt-get install -y apache2

# Install PHP and extensions
apt-get install -y php php-mysql php-gd php-xml php-mbstring php-curl libapache2-mod-php

# Install NFS client
apt-get install -y nfs-common

# Start and enable Apache
systemctl start apache2
systemctl enable apache2

# Wait for EFS to be available
echo "Waiting for EFS to be available..."
for i in {1..30}; do
    if timeout 5 bash -c "echo > /dev/tcp/$(echo ${efs_dns_name} | cut -d. -f1).efs.$(echo ${efs_dns_name} | cut -d. -f2).amazonaws.com/2049" 2>/dev/null; then
        echo "EFS is reachable"
        break
    fi
    echo "Waiting for EFS... attempt $i"
    sleep 10
done

# Create mount point
mkdir -p /var/www/html

# Mount EFS using NFS4
echo "Mounting EFS: ${efs_dns_name}"
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
  ${efs_dns_name}:/ /var/www/html

# Add to fstab for persistence
if ! grep -q "${efs_dns_name}" /etc/fstab; then
    echo "${efs_dns_name}:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
fi

# Set permissions (Ubuntu uses www-data instead of apache)
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Install WordPress (only if not already present)
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing WordPress..."
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    
    # Copy WordPress files
    cp -r wordpress/* /var/www/html/
    
    cd /var/www/html
    cp wp-config-sample.php wp-config.php
    
    # Remove port from endpoint if present
    DB_HOST=$(echo "${db_endpoint}" | cut -d: -f1)
    
    # Configure database
    sed -i "s/database_name_here/${db_name}/" wp-config.php
    sed -i "s/username_here/${db_username}/" wp-config.php
    sed -i "s/password_here/${db_password}/" wp-config.php
    sed -i "s/localhost/$DB_HOST/" wp-config.php
    
    # Set correct permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    echo "WordPress installed with DB: $DB_HOST"
fi

# Enable Apache rewrite module (needed for WordPress permalinks)
a2enmod rewrite

# Configure Apache for WordPress
cat > /etc/apache2/sites-available/wordpress.conf <<'EOF'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog $${APACHE_LOG_DIR}/error.log
    CustomLog $${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable the site and disable default
a2ensite wordpress.conf
a2dissite 000-default.conf

# Restart Apache
systemctl restart apache2

echo "=== Installation Complete at $(date) ==="
echo "WordPress should be accessible via your ALB"