#!/bin/bash

# Check Linux distribution type
if [ -f /etc/os-release ]; then
  # RedHat-based distro
  source /etc/os-release
  if [[ "$ID" == "centos" || "$ID" == "rhel" || "$ID_LIKE" == *"redhat"* ]]; then
    distro="redhat"
  fi
elif [ -f /etc/lsb-release ]; then
  # Debian-based distro
  source /etc/lsb-release
  if [[ "$DISTRIB_ID" == "debian" || "$DISTRIB_ID" == "ubuntu" ]]; then
    distro="debian"
  fi
else
  echo "Unsupported Linux distribution. Exiting..."
  exit 1
fi

# Function to install LEMP stack for Debian
install_lemp_debian() {
  # Update package lists
  sudo apt update -y

  # Install Nginx
  sudo apt install nginx -y

  # Start and enable Nginx service
  sudo systemctl start nginx
  sudo systemctl enable nginx

  # Install MariaDB
  sudo apt install mariadb-server mariadb-client -y

  # Secure MariaDB installation (prompts for root password)
  sudo mysql_secure_installation

  # Start and enable MariaDB service
  sudo systemctl start mariadb
  sudo systemctl enable mariadb

  # Install PHP and common modules
  sudo apt install php php-fpm php-mysqlnd php-gd php-mbstring php-xml -y

  # Enable PHP-FPM service
  sudo systemctl start php-fpm
  sudo systemctl enable php-fpm
}

# Function to install LEMP stack for RedHat
install_lemp_redhat() {
  # Update package lists
  sudo dnf update -y

  # Enable EPEL repository (for some PHP modules)
  sudo dnf install epel-release -y

  # Install Nginx
  sudo dnf install nginx -y

  # Start and enable Nginx service
  sudo systemctl start nginx
  sudo systemctl enable nginx

  # Install MariaDB
  sudo dnf install mariadb-server mariadb-client -y

  # Secure MariaDB installation (prompts for root password)
  sudo mysql_secure_installation

  # Start and enable MariaDB service
  sudo systemctl start mariadb
  sudo systemctl enable mariadb

  # Install PHP and common modules
  sudo dnf install php php-fpm php-mysqlnd php-gd php-mbstring php-xml -y

  # Enable PHP-FPM service
  sudo systemctl start php-fpm
  sudo systemctl enable php-fpm
}

# Install LEMP stack based on distro
if [[ "$distro" == "debian" ]]; then
  install_lemp_debian
elif [[ "$distro" == "redhat" ]]; then
  install_lemp_redhat
fi

# Download Moodle
wget https://download.moodle.org/latest.tar.gz

# Extract Moodle archive
tar -xzf latest.tar.gz

# Move Moodle files to web directory
sudo mv moodle/* /var/www/html/

# Set ownership and permissions for web content directory (adjust as needed)
sudo chown -R www-data:www-data /var/www/html

# (Optional) Create a basic Moodle configuration file (replace with actual database details)
# You'll need to complete the Moodle installation process through the web interface
# sudo echo "<?php
# \$CFG->dbtype    = 'mysql';
# \$CFG->dbhost    = 'localhost';
# \$CFG->dbname    = 'your_database_name';
# \$CFG->dbuser    = 'your_database_user';
# \$CFG->dbpass    = 'your_database_password';
# \$CFG->wwwroot   = '/var/www/html';
# ?>
# " > /var/www/html/config.php

# Open firewall ports (adjust as needed)
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload

echo "LEMP stack and Moodle installation (partially) complete!"

echo "Access the Moodle web interface (usually http://your_server_ip/) to complete the installation process."
echo "Remember to replace placeholders in the Moodle configuration file (if created) with your actual database credentials."
