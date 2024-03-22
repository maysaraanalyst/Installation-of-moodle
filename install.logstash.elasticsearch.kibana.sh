#!/bin/bash

# Update system packages
yum update -y

# Install Java (required by Elasticsearch)
yum install java -y

# Install Elasticsearch and Kibana repositories
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch  # Update URL if needed
yum install -y https://artifacts.elastic.co/packages/oss/7.x/yum/elastic-repo-7.x.rpm

# Install Elasticsearch
yum install elasticsearch -y

# Enable and start Elasticsearch service
systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch

# Install Logstash
yum install logstash -y

# Install Kibana
yum install kibana -y

# Enable and start Kibana service
systemctl enable kibana
systemctl start kibana

# (Optional) Configure Logstash to collect Moodle logs

# This section requires further customization based on your Moodle setup and desired log data.
# You'll need to configure Logstash inputs (e.g., file input for Moodle logs) and filters 
# to parse the log data and extract relevant fields. Finally, define an Elasticsearch output 
# to send the processed data to Elasticsearch.

# Refer to the official Logstash documentation for detailed configuration steps:
# https://www.elastic.co/guide/en/logstash/8.12/index.html

echo "Logstash, Elasticsearch, and Kibana installed."
echo "**Next Steps:**"
echo "1. Configure Logstash to collect and process Moodle logs (refer to Logstash documentation)."
echo "2. Create Kibana dashboards to visualize Moodle usage data (requires further configuration)."
echo "3. Consider security measures for data access and communication between these tools."

