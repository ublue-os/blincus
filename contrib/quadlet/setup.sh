#!/bin/env bash

sudo mkdir -p /var/lib/incus

# add the groups if they are missing
# modify existing groups to correct GIDs
if [ $(getent group incus-admin) ]; then
    sudo groupmod -g 250 incus-admin
    sudo groupmod -g 251 incus
else
    sudo groupadd -g 250 incus-admin
    sudo groupadd -g 251 incus
fi

# add yourself to incus-admin
sudo usermod -aG incus-admin ${USER}

if ! command -v incus >/dev/null 2>&1; then
    wget https://github.com/lxc/incus/releases/download/v6.0.0/bin.linux.incus.x86_64
    sudo mv bin.linux.incus.x86_64 /usr/local/bin/incus
    sudo chmod +x /usr/local/bin/incus
fi

# this won't start until after reboot
sudo cp incus.container /etc/containers/systemd/incus.container

echo "You must reboot to start Incus"
