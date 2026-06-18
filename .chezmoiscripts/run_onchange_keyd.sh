#!/bin/sh
sudo mkdir -p /etc/keyd
sudo tee /etc/keyd/default.conf > /dev/null << 'EOF'
[ids]
*

[main]
meta = overload(meta, A-f1)

[meta:M]
EOF
sudo keyd reload
