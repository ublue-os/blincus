---
title: How Blincus Works
description: How Blincus Works.
---

Blincus ships with a set of templates that follow a set of common conventions.

## Convention: cloud-init

Each template uses [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) to install a set of packages and create a user matching the user on the host.

```yaml
    #cloud-config
    packages:
      - curl
      - wget
      - openssh-server
    users:
      - name: BLINCUSUSER
        plain_text_passwd: 'BLINCUSUSER'
        home: /home/BLINCUSUSER
        shell: /bin/bash
        lock_passwd: True
        gecos: BLINCUSFULLNAME
        groups: [adm, cdrom, dip, sudo]
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - SSHKEY
```

The `blincus launch` command creates an `incus` container based on the template configuration. The script replaces the `BLINCUS*` variables with your user name, your full name, and the first SSH public key it finds in `~/.ssh/`.

The basic templates install a few packages and create a user. More complicated templates set up device sharing:

```yaml
devices:
  mygpu:
    gid: "44"
    type: gpu
  pulseaudio-socket:
    path: /mnt/.container_pulseaudio_socket
    source: /run/user/1000/pulse/native
    type: disk
  x11-socket:
    path: /mnt/.container_x11_socket
    source: /tmp/.X11-unix/X0
    type: disk
```

and even [write more complicated scripts](https://github.com/ublue-os/blincus/blob/main/instances/ubuntux.config.yaml#L23) to do things like share the host's graphical and audio sessions.

A healthy amount of the *magic* that makes Blincus work comes from these cloud-init configurations.

## Convention: Host and instance $USER matching

The templates create a user in the container that matches the user on the host. They also set up [id maps](https://linuxcontainers.org/incus/docs/main/userns-idmap/) that map your host user to your user in the instance, allowing seampless file sharing.

## Convention: Templates have matching config in `config.ini`

The Blincus configuration file is located at `~/.config/blincus/config.ini`. It contains a few configuration values for each template.

```ini
[ubuntu]
image = images:ubuntu/jammy/cloud
scripts = ubuntu

[ubuntux]
image = images:ubuntu/jammy/cloud
scripts = ubuntu
```

The `image` value tells Blincus which [image](https://images.linuxcontainers.org/) to start for each template.

The `scripts` value tells Blincus which directory to mount in the instance for convenience scripts. Blincus will copy the contents of a matching directory at `~/.config/blincus/scripts` into the instance at `/opt/scripts`. In the above example both the `ubuntu` and `ubuntux` templates will create containers that have the contents of `~/.config/blincus/scripts/ubuntu` mounted at `/opt/scripts` inside. 

As an added bonus, if there is an `init.sh` script in that folder, the pre-built templates are [configured to execute it](https://github.com/ublue-os/blincus/blob/main/instances/ubuntux.config.yaml#L52) when the container launches.

## Configs and Directories

Blincus stores user configurations at `~/.config/blincus`.

In that directory is a `config.ini` file used to set configuration values per template.

There are two directories under `~/.config/blincus`. `scripts` and `templates`.

The `scripts` directory contains one or more subdirectories that will be copied into an instance when it's created. The `scripts` key in `config.ini` determines which directory.  You can have one directory that's shared by multiple templates (say all Debian based templates use the same scripts). Or you can make a new scripts directory for each template.

The `templates` directory contains Incus configuration templates that are used in the `blincus launch` command. The first part of the filename is used as the template name. To use `~/.config/blincus/templates/ubuntu.config.yaml` you would run `blincus launch -t ubuntu <containername>`.

There is no limit to the number of templates you can have, but each template must have a corresponding configuration section in the `config.ini` specifying which image to use and which scripts directory to mount.