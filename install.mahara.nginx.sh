#!/bin/bash

# Ensure the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Step 1: Update your system
echo "Updating system..."
yum update -y

# Step 2: Install Nginx
echo "Installing Nginx..."
yum install -y nginx

# Start and enable Nginx to run on boot
systemctl start nginx
systemctl enable nginx

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
yum install -y php php-fpm php-mysqlnd php-curl php-gd php-xml php-mbstring php-json php-zip

# Configure PHP-FPM to use the Nginx user
sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf

# Start and enable PHP-FPM
systemctl start php-fpm
systemctl enable php-fpm

# Step 5: Create a database for Mahara
echo "Creating MariaDB database and user for Mahara..."
mysql -u root -p -e "CREATE DATABASE mahara_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p -e "GRANT ALL ON mahara_db.* TO 'mahara_user'@'localhost' IDENTIFIED BY 'secure_password';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Step 6: Download and install Mahara
echo "Downloading Mahara..."
wget https://launchpad.net/mahara/21.04/21.04.2/+download/mahara-21.04.2.zip
unzip mahara-21.04.2.zip -d /usr/share/nginx/html/

# Set the correct permissions
chown -R nginx:nginx /usr/share/nginx/html/mahara-21.04.2
chmod -R 755 /usr/share/nginx/html/mahara-21.04.2

# Step 7: Configure Nginx for Mahara
echo "Configuring Nginx for Mahara..."
cat > /etc/nginx/conf.d/mahara.conf << EOF
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    root /usr/share/nginx/html/mahara-21.04.2/htdocs;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Restart Nginx to apply the new configuration
systemctl restart nginx

echo "Mahara installation is complete. Please navigate to your domain to complete the setup through the web interface."
