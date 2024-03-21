#!/bin/bash

# Update system packages
dnf update -y

# Enable the AlmaLinux Extras repository (may require manual configuration based on your AlmaLinux version)
dnf config-manager --set-enabled AlmaLinux-8-extras

# Install Pacemaker and Corosync packages
dnf install pacemaker corosync pcs -y

# Set password for hacluster user (used for cluster management)
passwd hacluster

# Enable and start Pacemaker, Corosync, and pcsd services
systemctl enable pacemaker corosync pcsd
systemctl start pacemaker corosync pcsd

echo "Pacemaker and Corosync installed on AlmaLinux."
echo "**Next Steps:**"
echo "1. Configure cluster nodes using pcs command (refer to Pacemaker documentation)."
echo "2. Define and manage cluster resources for high availability."

