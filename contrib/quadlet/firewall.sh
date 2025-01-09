#!/bin/env bash

# firewalld needs to be running, too
sudo firewall-cmd --zone=trusted --change-interface=incusbr0 --permanent
sudo firewall-cmd --reload
