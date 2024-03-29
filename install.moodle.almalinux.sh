
#!/bin/bash

# Update system packages
sudo dnf update -y

# Install Nginx, MariaDB, PHP, and dependencies
sudo dnf install -y nginx mariadb-server mariadb-client php php-fpm php-gd php-mbstring php-xml php-curl php-zip unzip

# Start and enable MariaDB and PHP-FPM services
sudo systemctl start mariadb nginx php-fpm
sudo systemctl enable mariadb nginx php-fpm

# Secure MariaDB installation
sudo mysql_secure_installation

# Create a database for Moodle
mysql -u root -p <<EOF
CREATE DATABASE moodle;
EOF

# Create a user for Moodle and grant permissions
mysql -u root -p <<EOF
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'YourMoodlePassword';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Download the latest Moodle codebase
sudo su - nobody -s /bin/bash -c 'wget https://download.moodle.org/latest.tar.gz'

# Extract the codebase
sudo tar -xvf latest.tar.gz

# Move the extracted directory to the document root for Nginx
sudo mv moodle /var/www/html/

# Set ownership and permissions for the Moodle directory
sudo chown -R apache:apache /var/www/html/moodle

# Configure Nginx for Moodle
sudo nano /etc/nginx/conf.d/moodle.conf

# Add the following configuration, replacing 'your_domain' with your actual domain name:

server {
    listen       80;
    server_name  your_domain;

    location / {
        root   /var/www/html/moodle;
        index  index.php index.html index.htm;

        # Pass PHP scripts to PHP-FPM
        location ~ \.php$ {
            try_files $uri /index.php?$query_string;
            fastcgi_pass unix:/run/php-fpm/www.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}

# Restart Nginx to apply configuration changes
sudo systemctl restart nginx

# Open a web browser and navigate to http://your_domain to complete the Moodle installation process.
echo "Moodle installation complete! Visit http://your_domain to finalize the setup using the database details created earlier."
