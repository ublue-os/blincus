#!/bin/env bash


## Run at instance launch as "root"

export FORCE=1; curl -fsSL https://get.jetpack.io/devbox | bash
chmod 0755 /usr/local/bin/devbox
