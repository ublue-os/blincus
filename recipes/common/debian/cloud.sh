#!/bin/bash

sleep 5

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install cloud-init