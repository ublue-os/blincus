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

## Convention: Template Names ending in 'x' pass through host X and audio

Template names that end in `x` like `ubuntux` or `fedorax` will pass through the X and pulseaudio sockets from the host.

## Configs and Directories

Blincus stores user configurations at `~/.config/blincus`.

In that directory is a `config.ini` file used to set configuration values per template.

There are two directories under `~/.config/blincus`. `scripts` and `templates`.

The `scripts` directory contains one or more subdirectories that will be copied into an instance when it's created. The `scripts` key in `config.ini` determines which directory.  You can have one directory that's shared by multiple templates (say all Debian based templates use the same scripts). Or you can make a new scripts directory for each template.

The `cloud-init` and `profiles` directories contains Incus configuration templates that are used in the `blincus launch` command.

`profiles` are Incus configurations that specify settings for your instance. You can apply one or many profiles to your instances. Blincus takes an opinionated approach, specifying one category of configuration per profile, letting you add them together as needed.

`cloud-init` files are configurations that specify users, package installation, and other operating system configurations on first boot. The big cloud providers like Azure, AWS, and Google Cloud all use this same method to configure your virtual machines when you launch.  Blincus uses `cloud-init` configurations to create a user in your instances that matches your user on the host and setup SSH configuration.

Collectively, a base image, one or more `profiles`, and a `cloud-init` are a `template`.

`templates` are defined in `~/.config/blincus/config.ini` and look like this:

```ini
[ubuntu]
description = Ubuntu Jammy + cloud
image = images:ubuntu/jammy/cloud
scripts = ubuntu
```

This template does not specify `profiles` or `cloud-init`, so Blincus will use the defaults that are listed at the top of the `config.ini`:

```ini
default_cloud-init = debian
default_container_image = images:ubuntu/mantic/cloud
default_container_profiles = container,idmap
default_home-mounts = Documents,projects
default_scripts = ubuntu
default_vm_image = images:ubuntu/mantic/cloud
default_vm_profiles = idmap,vmkeys
```

`image`, `cloud-init`, plus `profiles` together define a configuration that meets the conventions listed at the top of this page:

* `cloud-init` to create user, assign groups, add SSH keys, install packages
* `profiles` to configure properties of the Incus instance
* `image` to define the base operating system used to create your instance

Additionally, you can add some other convenient things:

* `home-mounts`: a list of folders from $HOME on your host that will be mapped into the instance
* `scripts`: a directory containing scripts you commonly use