#!/bin/bash

# Define variables (replace with actual values)
GALERA_CLUSTER_NAME="mycluster"
WSREP_NODE_ADDRESS=( "<node1_ip>" "<node2_ip>" "<node3_ip>" )  # Replace with IP addresses of each node
WSREP_CLUSTER_ADDRESS="gcomm://$(hostname -I | awk '{print $1}')"  # Cluster address using first node's IP

# Update package list
yum update -y

# Enable EPEL repository for Galera packages
yum install epel-release -y

# Install MariaDB and Galera packages
yum install galera mariadb-server rsync socat mysql-connector-python -y

# Secure MariaDB installation (run on each node)
mysql_secure_installation

# Create systemd service file for Galera
cat << EOF > /etc/systemd/system/mariadb.service
[Unit]
Description=MariaDB Database Server
After=network.target

[Service]
User=mysql
Group=mysql
PIDFile=/var/lib/mysql/mysqld.pid
ExecStart=/usr/bin/mysqld --wsrep-node-address=$WSREP_CLUSTER_ADDRESS --wsrep_cluster_name=$GALERA_CLUSTER_NAME --wsrep_sst_auth=user:password  # Replace password

# Include Galera specific options in the data directory
IncludeDirectory /etc/my.cnf.d/

[Install]
WantedBy=multi-user.target
EOF

# Create directory for Galera specific configuration
mkdir /etc/my.cnf.d/

# Create Galera configuration file (replace password)
cat << EOF > /etc/my.cnf.d/galera.cnf
[mysqld]
wsrep_on=ON
wsrep_sst_method=rsync
binlog_format=ROW
default_storage_engine=innodb
bind-address=0.0.0.0

# Galera cluster configuration
wsrep_cluster_address=$WSREP_CLUSTER_ADDRESS
wsrep_node_address=${WSREP_NODE_ADDRESS[0]}  # Replace with first node's IP for initial configuration

# Replace with unique IDs for each node (starting from 1)
wsrep_node_incoming_address_append=

# Adjust based on your environment (optional)
wsrep_sst_auth=user:password  # Replace password
wsrep_provider=tcp

# Adjust based on your hardware (optional)
wsrep_cluster_size=3  # Adjust for number of nodes
wsrep_slave_skip_errors=all
EOF

# Initialize Galera cluster (only on the first node)
if [[ $(hostname -I | awk '{print $1}') == "${WSREP_NODE_ADDRESS[0]}" ]]; then
  galera_new_cluster
fi

# Reload systemd and start MariaDB service
systemctl daemon-reload
systemctl enable mariadb
systemctl start mariadb

# Join remaining nodes to the cluster (replace with node IP for each)
for node_ip in "${WSREP_NODE_ADDRESS[@]:1}"; do
  ssh root@${node_ip} "/etc/init.d/mariadb stop"
  scp /etc/my.cnf.d/galera.cnf root@${node_ip}:/etc/my.cnf.d/
  ssh root@${node_ip} "sed -i 's/${WSREP_NODE_ADDRESS[0]}/${node_ip}/' /etc/my.cnf.d/galera.cnf"  # Replace first node IP with current node IP
  ssh root@${node_ip} "/etc/init.d/mariadb start"
done

# Check Galera cluster status (on any node)
echo "Checking Galera cluster status..."
mysql -h localhost -P 3306 -u root -p<password> -e "SHOW STATUS LIKE 'wsrep%'"

echo "MariaDB Galera Cluster installation complete!"
