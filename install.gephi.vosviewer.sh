#!/bin/bash

# Update system packages
sudo yum update -y

# Install Java (required by both Gephi and VOSviewer)
sudo yum install java-17-openjdk-devel -y

# Install Gephi dependencies
sudo yum install gtk2-devel libcairo-devel pango-devel libxt6-devel libgimp2.0-devel at-spi2-core libchamplain-devel libgconf2-devel -y

# Download Gephi
wget https://www.apache.org/dyn/closer.cgi?path=/gephi/binaries/Gephi-0.9.2-bin.zip -O gephi.zip

# Extract Gephi archive
unzip gephi.zip

# Move Gephi directory to a desired location (optional)
# This script extracts it to the current directory. You can uncomment 
# the following line and adjust the path to move it elsewhere.
# mv gephi-0.9.2 /opt/gephi

# Set environment variable for Gephi executable (optional)
# This line is commented out. Uncomment it if you want to avoid the full path 
# when running Gephi. You'll need to adjust the path based on the actual location.
# echo 'export GEPHI_HOME=/path/to/gephi-0.9.2' >> ~/.bashrc
# source ~/.bashrc

echo "Gephi installation complete."
echo "**How to run Gephi (if environment variable not set):**"
echo "./gephi-0.9.2/bin/gephi.sh"

# Install VOSviewer dependencies
sudo yum install python3 python3-devel gcc gcc-c++ make openssl openssl-devel libcurl libcurl-devel -y

# Download VOSviewer
wget https://www.vosviewer.com/download/VOSviewer-1.6.16.zip -O vosviewer.zip

# Extract VOSviewer archive
unzip vosviewer.zip

# Move VOSviewer directory to a desired location (optional)
# This script extracts it to the current directory. You can uncomment 
# the following line and adjust the path to move it elsewhere.
# mv VOSviewer-1.6.16 /opt/vosviewer

# Install VOSviewer (Python 3 version)
cd VOSviewer-1.6.16
python3 setup.py install

echo "VOSviewer installation complete."
echo "**How to run VOSviewer:**"
echo "python3 VOSviewer.py"

