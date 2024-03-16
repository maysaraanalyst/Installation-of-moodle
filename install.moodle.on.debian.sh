#!/bin/bash

# Update package lists
apt update

# Install Nginx web server
apt install nginx -y

# Start and enable Nginx service
systemctl start nginx
systemctl enable nginx

# Install MariaDB database server
apt install mariadb-server mariadb-client -y

# Secure MariaDB with a strong password
mysql_secure_installation

# Install PHP and required modules
apt install php php-fpm php-curl php-cli php-zip php-mysql php-xml php-gd php-mbstring php-json -y

# Restart Nginx service to reflect PHP configuration changes
systemctl restart nginx

# Create a database for Moodle
mysql -u root -p -e "CREATE DATABASE moodle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Create a user for Moodle database access
mysql -u root -p -e "CREATE USER moodle@localhost IDENTIFIED BY 'strong_password';"

# Grant permissions to the Moodle user
mysql -u root -p -e "GRANT ALL PRIVILEGES ON moodle.* TO moodle@localhost;"

# Download latest Moodle code (replace with desired version if needed)
wget https://download.moodle.org/latest.tar.gz

# Extract downloaded Moodle code
tar -xvf latest.tar.gz

# Move extracted Moodle files to document root
mv moodle /var/www/html

# Set ownership of Moodle files to the web server user (usually www-data)
chown -R www-data:www-data /var/www/html/moodle

# Create a self-signed SSL certificate (replace with a Let's Encrypt certificate for production)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/moodle.key -out /etc/ssl/certs/moodle.crt  -subj "/C=US/ST=YourState/L=YourCity/O=YourOrganization/CN=yourdomain.com"

# Configure Nginx virtual host for Moodle
cat << EOF > /etc/nginx/sites-available/moodle.conf
server {
  listen 443 ssl;
  server_name yourdomain.com;

  ssl on;
  ssl_certificate /etc/ssl/certs/moodle.crt;
  ssl_certificate_key /etc/ssl/private/moodle.key;

  root /var/www/html/moodle;
  index index.php index.html index.htm;

  location / {
    try_files $uri /index.php?$query_string;
  }

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass 127.0.0.1:9000;
  }
}
EOF

# Enable the Moodle virtual host configuration
ln -s /etc/nginx/sites-available/moodle.conf /etc/nginx/sites-enabled/

# Restart Nginx to apply the new configuration
systemctl restart nginx

# Open your web browser and visit https://yourdomain.com to complete the Moodle installation
echo "Please visit https://yourdomain.com to complete the Moodle installation process."
echo "Remember to replace 'strong_password' with a strong password for the Moodle database user."
