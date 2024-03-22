#!/bin/bash

# Update system packages
sudo yum update -y

# Install dependencies
sudo yum install git gcc gcc-c++ make openssl openssl-devel libcurl libcurl-devel pcre-devel perl perl-devel postgresql postgresql-contrib -y

# Enable and start PostgreSQL service
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Install Node Version Manager (NVM)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Reload shell configuration to use NVM commands
source ~/.bashrc

# Install Node.js (adjust version number if needed)
nvm install 16  # Replace 16 with the desired Node.js version

# Switch to the installed Node.js version
nvm use 16

# Clone Learning Locker repository
git clone https://github.com/LearningLocker/LearningLocker.git

# Navigate to the Learning Locker directory
cd LearningLocker

# Install dependencies
yarn install

# Create a system user for running Learning Locker (recommended)
sudo useradd -r learninglocker

# Set ownership of the Learning Locker directory to the learninglocker user
sudo chown -R learninglocker:learninglocker .

# Initialize Learning Locker database (refer to Learning Locker documentation for specific commands)
# This script won't configure the database, but you'll likely need commands like:
# sudo -u postgres psql -c "CREATE USER learninglocker WITH PASSWORD 'your_password'"
# sudo -u postgres psql -c "CREATE DATABASE learninglocker OWNER learninglocker"

# Configure Learning Locker (refer to Learning Locker documentation for specific instructions)
# This script won't configure Learning Locker, but you'll need to edit configuration files 
# (e.g., config.json) to define database connection details, ports, etc.

# (Optional) Configure Nginx to proxy requests to Learning Locker
# This script won't modify Nginx configuration, but consider adding a server block 
# to proxy requests to the Learning Locker port (default: 3000).

echo "Learning Locker installation complete (basic setup)."
echo "**Next Steps:**"
echo "1. Configure Learning Locker database and other settings (refer to Learning Locker documentation)."
echo "2. (Optional) Configure Nginx to proxy requests to Learning Locker."
echo "3. Implement security measures for production deployments (not included in this script)."
echo "4. Explore options for running Learning Locker as a service (e.g., using systemd)."
echo "5. Configure Moodle to integrate with Learning Locker (likely requires additional plugins or configurations)."

