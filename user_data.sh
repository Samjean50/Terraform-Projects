#!/bin/bash
exec > >(tee /var/log/user-data.log) 2>&1
exec 2>&1

echo "=== WordPress Installation Started ==="
date

# Update and install Apache
echo "Installing Apache..."
yum update -y
yum install -y httpd

# Install PHP 7.4
echo "Installing PHP..."
amazon-linux-extras install -y php7.4
yum install -y php-mysqlnd php-gd php-xml php-mbstring

# Install NFS utilities
echo "Installing NFS utilities..."
yum install -y nfs-utils

# Start Apache
echo "Starting Apache..."
systemctl start httpd
systemctl enable httpd

# Create WordPress directory
mkdir -p /var/www/html

# Mount EFS
echo "Mounting EFS ${efs_id}..."
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
  ${efs_id}.efs.${aws_region}.amazonaws.com:/ /var/www/html

# Add to fstab
echo "${efs_id}.efs.${aws_region}.amazonaws.com:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Download and install WordPress
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/html/
    
    # Configure WordPress
    echo "Configuring WordPress..."
    cd /var/www/html
    cp wp-config-sample.php wp-config.php
    
    # IMPORTANT: Strip port from endpoint if present
    DB_HOST=$(echo "${db_endpoint}" | cut -d: -f1)
    
    # Update database settings
    sed -i "s/database_name_here/${db_name}/" wp-config.php
    sed -i "s/username_here/${db_username}/" wp-config.php
    sed -i "s/password_here/${db_password}/" wp-config.php
    sed -i "s/localhost/$DB_HOST/" wp-config.php
    
    # Set proper permissions
    chown -R apache:apache /var/www/html
    chmod -R 755 /var/www/html
    
    echo "WordPress configured with database: $DB_HOST"
else
    echo "WordPress already installed"
fi

# Restart Apache
echo "Restarting Apache..."
systemctl restart httpd
systemctl status httpd

echo "=== Installation Completed ==="
date
