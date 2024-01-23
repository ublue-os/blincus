#!/bin/bash
mv /tmp/90-incus /etc/sudoers.d/90-incus
chmod 440 /etc/sudoers.d/90-incus
chown root:root /etc/sudoers.d/90-incus
