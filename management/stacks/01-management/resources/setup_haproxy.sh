#!/usr/bin/env bash

set -e

yum -y install epel-release
yum -y install haproxy
setsebool -P haproxy_connect_any 1

# backup initial haproxy config
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.original

# Create new haproxy config
cat > /etc/haproxy/haproxy.cfg << EOF
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2 info

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

defaults
    # Mode the server is running in
    mode               tcp
    option             tcplog
    log                global
    
    timeout connect    10s
    timeout client     30s
    timeout server     30s

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend  cce-in *:8091
    default_backend   cce

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend cce
    balance roundrobin
    server cce1 cce1:8091 check
EOF

systemctl start haproxy
systemctl enable haproxy