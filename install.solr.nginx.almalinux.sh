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

# Download Nginx configuration file
sudo wget https://raw.githubusercontent.com/elastic/examples/master/config/nginx/apache-solr.conf -O /etc/nginx/conf.d/solr.conf

# Update Nginx Solr Proxy Settings in /etc/nginx/conf.d/solr.conf
# (Replace "your_domain" with your actual domain name)
sudo sed -i "s/server_name your_domain;/server_name your_domain;/g" /etc/nginx/conf.d/solr.conf

# Enable Nginx Solr configuration
sudo systemctl enable nginx.service

# Start Solr
sudo su - solr -c "/opt/solr/server/solr/bin/solr start -f"

# Start Nginx
sudo systemctl start nginx.service

# Check Solr Status (Access http://your_domain/solr/ in your browser)
sudo su - solr -c "/opt/solr/server/solr/bin/solr status"

echo "Solr and Nginx reverse proxy installed and running!"
