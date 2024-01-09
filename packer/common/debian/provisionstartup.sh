#!/bin/bash
mv /tmp/mystartup.sh /usr/local/bin/mystartup.sh
chmod 755 /usr/local/bin/mystartup.sh
chown root:root /usr/local/bin/mystartup.sh

mv /tmp/mystartup.service /usr/local/etc/mystartup.service
chmod 744 /usr/local/etc/mystartup.service
chown root:root /usr/local/etc/mystartup.service

mkdir -p /home/BLINCUSUSER/.config/systemd/user/default.target.wants
ln -s /usr/local/etc/mystartup.service /home/BLINCUSUSER/.config/systemd/user/default.target.wants/mystartup.service
ln -s /usr/local/etc/mystartup.service /home/BLINCUSUSER/.config/systemd/user/mystartup.service
chown -R BLINCUSUSER:BLINCUSUSER /home/BLINCUSUSER/.config
echo 'export DISPLAY=:0' >> /home/BLINCUSUSER/.profile
chown BLINCUSUSER:BLINCUSUSER /home/BLINCUSUSER/.profile