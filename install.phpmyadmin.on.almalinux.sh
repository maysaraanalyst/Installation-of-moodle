#!/bin/bash

# Update package lists
yum update -y

# Install phpMyAdmin
yum install phpmyadmin -y

# Enable and start phpMyAdmin service
systemctl enable --now phpmyadmin.httpd

# Create symbolic link for phpMyAdmin access (adjust path if needed)
ln -s /usr/share/phpMyAdmin /var/www/html/phpmyadmin

# Configure phpMyAdmin access in Nginx (adjust server block path)
SERVER_BLOCK_PATH="/etc/nginx/conf.d/your_moodle_server.conf"

# Add location block for phpMyAdmin
cat << EOF >> "${SERVER_BLOCK_PATH}"

location /phpmyadmin {
    # Deny access from all by default
    deny all;

    # Allow access from localhost only (adjust for security needs)
    allow 127.0.0.1;

    # Point alias to phpMyAdmin directory
    root /usr/share/phpMyAdmin;

    # Index file for directory listings
    index index.php index.html index.htm;

    # Configure basic authentication if desired (optional)
    # auth_basic "Restricted";
    # auth_basic_user_file path/to/htpasswd;
}
EOF

# Reload Nginx configuration
systemctl reload nginx

echo "phpMyAdmin installed and integrated with Moodle (accessible at http://your_server_ip/phpmyadmin)."
