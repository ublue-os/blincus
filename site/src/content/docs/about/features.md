---
title: Blincus Features 
description: Blincus Features.
---

Blincus is a shell script that wraps the `incus` command, adding some commands to simplify the process of doing containerized development.  Here's a brief list of what Blincus provides:

- Pre-built container configurations with cloud-init
- Automatic creation of a user matching your host user in the container
- Automatic provisioning of SSH keys
- Automatic mounting of your $HOME in a subdirectory in the container's $HOME
- Optional mounting of $HOME subdirectories in the container
- Optional sharing of the host's display and audio
- Automatic mounting of frequently-used convenience scripts in the container