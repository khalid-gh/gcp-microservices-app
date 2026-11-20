#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y squid skopeo

internal_ip=$(curl --fail --silent --show-error \
  -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

cat > /etc/squid/squid.conf <<EOF
http_port $internal_ip:3128
acl cluster_sources src 10.0.0.0/18 10.48.0.0/14
acl CONNECT method CONNECT
acl tls_port port 443
acl private_destinations dst 0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 ::1/128 fc00::/7 fe80::/10
acl repository_hosts dstdomain .github.com .githubusercontent.com .pkg.dev .googleapis.com .googleusercontent.com
http_access deny !CONNECT
http_access deny !tls_port
http_access deny private_destinations
http_access allow cluster_sources repository_hosts
http_access deny all
cache deny all
access_log stdio:/var/log/squid/access.log
EOF

squid -k parse
systemctl enable squid
systemctl restart squid
systemctl is-active --quiet squid
