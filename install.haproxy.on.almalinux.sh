#!/bin/bash

# Update system packages
dnf update -y

# Install HAProxy
dnf install haproxy -y

# Set ownership of HAProxy configuration directory (optional but recommended)
chown root:root /etc/haproxy

# Enable and start HAProxy service
systemctl enable haproxy
systemctl start haproxy

# Verify installation (optional)
systemctl status haproxy

echo "HAProxy installation complete on AlmaLinux!"
