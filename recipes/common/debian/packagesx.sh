#!/bin/bash

sleep 5

DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server curl wget pulseaudio-utils