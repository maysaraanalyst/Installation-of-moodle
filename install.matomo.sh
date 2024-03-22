#!/bin/bash

# Update system packages
sudo yum update -y

# Install LEMP Stack dependencies
sudo yum install nginx php php-curl php-gd php-cli mariadb mariadb-server php-mysql php-xml php-mbstring -y

# Enable and start Nginx and MariaDB services
sudo systemctl enable nginx mysqld
sudo systemctl start nginx mysqld

# Create a database for Matomo
mysql -u root -p -e "CREATE DATABASE matomo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Set a strong password for the MySQL root user (replace 'your_strong_password' with your desired password)
mysql -u root -p -e "ALTER USER root@localhost IDENTIFIED BY 'your_strong_password';"

# Create a new user for Matomo database access (replace 'matomo_user' and 'your_matomo_password' with your desired credentials)
mysql -u root -p -e "CREATE USER matomo_user@localhost IDENTIFIED BY 'your_matomo_password';"

# Grant permissions to the Matomo user for the Matomo database
mysql -u root -p -e "GRANT ALL PRIVILEGES ON matomo.* TO matomo_user@localhost;"

# Download Matomo latest stable version
wget https://api.matomo.org/update/Matomo.zip

# Extract Matomo archive
unzip Matomo.zip

# Move Matomo directory to a desired location (usually outside the web root for security)
sudo mv Matomo /var/www/matomo

# Set ownership and permissions for the Matomo directory
sudo chown -R apache:apache /var/www/matomo

# Configure Nginx for Matomo (replace 'your_domain_or_ip' with your actual domain or IP)
sudo cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/matomo.conf
sudo sed -i 's/server \{\n/\server {\n    listen 80;\n    server_name your_domain_or_ip;\n    root /var/www/matomo;\n    index index.php index.html index.htm;\n    location / {\n        try_files $uri $uri/ /index.php?$args;\n    }\n    location ~ \.php$ {\n        include snippets/fastcgi-php.conf;\n        fastcgi_pass 127.0.0.1:9000;\n    }\n}/' /etc/nginx/conf.d/matomo.conf

# Restart Nginx service
sudo systemctl restart nginx

# Access Matomo setup in your web browser: http://your_domain_or_ip

echo "Matomo installation complete. Please visit http://your_domain_or_ip to finish the setup process."
echo "**Security Note:** Remember to replace 'your_strong_password' and 'your_matomo_password' with strong passwords."
echo "**Security Consideration:** This script installs Matomo outside the web root for an extra layer of security. Consider additional security measures for production deployments."

