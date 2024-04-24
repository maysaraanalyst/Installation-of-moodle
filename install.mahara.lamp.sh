#!/bin/bash

# Ensuring the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Step 1: Update your system
echo "Updating system..."
yum update -y

# Step 2: Install Apache
echo "Installing Apache..."
yum install -y httpd

# Start and enable Apache to run on boot
systemctl start httpd
systemctl enable httpd

# Step 3: Install MariaDB
echo "Installing MariaDB..."
yum install -y mariadb-server

# Start and enable MariaDB
systemctl start mariadb
systemctl enable mariadb

# Secure MariaDB installation
mysql_secure_installation

# Step 4: Install PHP and required extensions
echo "Installing PHP and extensions..."
yum install -y epel-release
yum install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
yum module reset php
yum module enable php:remi-7.4
yum install -y php php-mysqlnd php-curl php-gd php-xml php-mbstring php-json php-zip

# Restart Apache to load the new PHP module
systemctl restart httpd

# Step 5: Create a database for Mahara
echo "Creating MariaDB database and user for Mahara..."
mysql -u root -p -e "CREATE DATABASE mahara_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p -e "GRANT ALL ON mahara_db.* TO 'mahara_user'@'localhost' IDENTIFIED BY 'secure_password';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Step 6: Download and install Mahara
echo "Downloading Mahara..."
wget https://launchpad.net/mahara/21.04/21.04.2/+download/mahara-21.04.2.zip
unzip mahara-21.04.2.zip -d /var/www/html/

# Give proper permissions
chown -R apache:apache /var/www/html/mahara-21.04.2
chmod -R 755 /var/www/html/mahara-21.04.2

# Step 7: Configure Apache for Mahara
echo "Configuring Apache for Mahara..."
cat > /etc/httpd/conf.d/mahara.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@example.com
    DocumentRoot "/var/www/html/mahara-21.04.2/htdocs"
    ServerName yourdomain.com
    ServerAlias www.yourdomain.com

    <Directory "/var/www/html/mahara-21.04.2/htdocs">
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/httpd/mahara_error.log
    CustomLog /var/log/httpd/mahara_requests.log combined
</VirtualHost>
EOF

# Restart Apache to apply changes
systemctl restart httpd

echo "Mahara installation is complete. Please navigate to your domain to complete the setup through the web interface."
