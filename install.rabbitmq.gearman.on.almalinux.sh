#!/bin/bash

# Update system packages
yum update -y

# Install RabbitMQ and Erlang (dependency)
yum install erlang rabbitmq-server php-amqp -y

# Enable and start RabbitMQ service
systemctl enable rabbitmq-server
systemctl start rabbitmq-server

# Install Gearman server and worker
yum install gearman gearman-job-server -y

# Enable and start Gearman services
systemctl enable gearmand
systemctl start gearmand
systemctl enable gearman-job-server
systemctl start gearman-job-server

# (Optional) Create a RabbitMQ user for Moodle (replace with desired username and password)
rabbitmqctl add_user moodleuser your_password
rabbitmqctl add_vhost moodle_vhost
rabbitmqctl set_permissions -p moodle_vhost moodleuser "" ".*" ".*"

# (Optional) Configure Moodle to use RabbitMQ for specific tasks
# Refer to Moodle documentation for specific configuration steps based on your version.
# This might involve installing additional Moodle plugins or modifying configuration files.

echo "RabbitMQ and Gearman installed."
echo "**Next Steps:**"
echo "1. Configure Moodle to use RabbitMQ for specific asynchronous tasks (refer to Moodle documentation)."
echo "2. Develop or integrate Gearman worker scripts to handle long-running Moodle tasks (optional)."
echo "3. Consider security implications and adjust access controls for RabbitMQ if needed."
