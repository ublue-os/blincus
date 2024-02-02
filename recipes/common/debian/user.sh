#!/bin/bash

userdel -rf ubuntu >/dev/null 2>&1 || true
userdel -rf debian >/dev/null 2>&1 || true
groupdel -f ubuntu >/dev/null 2>&1 || true
groupdel -f debian >/dev/null 2>&1 || true

getent group sudo >/dev/null 2>&1 || groupadd --system sudo
useradd --create-home -s /bin/bash -G sudo -U BLINCUSUSER