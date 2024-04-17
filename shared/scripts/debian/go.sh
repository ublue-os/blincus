#!/bin/env bash
#
sudo apt-get install wget
wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz

echo export PATH=$PATH:/usr/local/go/bin >>~/.profile
