#!/bin/bash
set -x
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/tmp/tflog.out 2>&1

REDIS_CONFIG_FILE=/etc/redis.conf

# Setup firewall rules
firewall-offline-cmd  --zone=public --add-port=${redis_port1}/tcp
firewall-offline-cmd  --zone=public --add-port=${redis_port2}/tcp
systemctl restart firewalld

# Install wget and gcc
yum install -y wget gcc

# Download and compile Redis
wget http://download.redis.io/releases/redis-${redis_version}.tar.gz
tar xvzf redis-${redis_version}.tar.gz
cd redis-${redis_version}
make install

# Configure REDIS
cat << EOF > $REDIS_CONFIG_FILE
port ${redis_port1}
cluster-enabled no
appendonly yes
requirepass ${redis_password}
bind 127.0.0.1 ${master1_private_ip}
masterauth ${redis_password}
protected-mode no
EOF

systemctl restart redis

sleep 30

