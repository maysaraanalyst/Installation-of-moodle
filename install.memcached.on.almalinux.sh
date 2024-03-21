#!/bin/bash

# Update package lists
yum update -y

# Install Memcached
yum install memcached -y

# Enable and start Memcached service
systemctl enable --now memcached

# Configure Memcached for Moodle (edit with your details)
MEMCACHED_HOST="localhost"
MEMCACHED_PORT="11211"

# Update Moodle configuration file
sed -i "s/\\;\/\/ memcached/memcached/g" /etc/php/7.4/fpm/php.ini  # Adjust path based on your PHP version

# Add Memcached configuration block
cat << EOF >> /etc/php/7.4/fpm/php.ini

[memcached]
memcached.sock = unix:///var/run/memcached.sock  # Adjust if using socket
; uncomment and set these if using TCP connection
; memcached.host = ${MEMCACHED_HOST}
; memcached.port = ${MEMCACHED_PORT}
EOF

# Reload PHP-FPM service to apply changes
systemctl reload php-fpm.service

# Install Moodle memcached plugin (adjust URL if necessary)
wget https://download.moodle.org/plugins/filter/memcached/filter_memcached_x.x.tgz -O memcached.tgz

# Extract plugin archive (adjust version number)
tar -xzf memcached.tgz

# Copy plugin folder to Moodle plugins directory
cp -r filter_memcached_x.x/ /var/www/html/your_moodle_directory/course/filter

# Clean up temporary files
rm -rf memcached.tgz filter_memcached_x.x

# Set ownership and permissions for plugin directory
chown -R apache:apache /var/www/html/your_moodle_directory/course/filter/filter_memcached_x.x

# Restart Nginx for changes to take effect
systemctl restart nginx

echo "Memcached installed and configured for Moodle."
