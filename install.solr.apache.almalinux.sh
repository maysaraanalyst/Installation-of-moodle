#!/bin/bash

# Update system packages
sudo dnf update -y

# Install Java OpenJDK
sudo dnf install java-11-openjdk-devel -y

# Download Solr
SOLR_VERSION="8.11.2"
wget https://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz

# Extract Solr
tar xzf solr-$SOLR_VERSION.tgz

# Create Solr User and Directory
sudo useradd -r -s /sbin/nologin solr
sudo mkdir -p /opt/solr/server

# Move Solr files
sudo mv solr-$SOLR_VERSION/server/solr/* /opt/solr/server/solr/

# Set ownership of Solr directory
sudo chown -R solr:solr /opt/solr/server

# Create Solr configuration directory
sudo mkdir -p /etc/solr/default

# Copy example solr.xml
sudo cp /opt/solr/server/solr/solr.xml /etc/solr/default/solr.xml

# Install Apache Web Server
sudo dnf install httpd -y

# Enable and Start Apache
sudo systemctl enable httpd.service
sudo systemctl start httpd.service

# Create Solr Virtual Host Configuration
sudo touch /etc/httpd/conf.d/solr.conf

# Add Apache Solr Proxy Configuration to /etc/httpd/conf.d/solr.conf
echo "<VirtualHost *:80>" >> /etc/httpd/conf.d/solr.conf
echo "    ProxyPreserveHost On" >> /etc/httpd/conf.d/solr.conf
echo "    ProxyPass /solr http://localhost:8983/solr/" >> /etc/httpd/conf.d/solr.conf
echo "</VirtualHost>" >> /etc/httpd/conf.d/solr.conf

# Reload Apache configuration
sudo systemctl reload httpd.service

# Start Solr
sudo su - solr -c "/opt/solr/server/solr/bin/solr start -f"

# Check Solr Status (Access http://your_server_ip/solr/ in your browser)
sudo su - solr -c "/opt/solr/server/solr/bin/solr status"

echo "Solr and Apache reverse proxy installed and running!"
