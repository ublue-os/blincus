---
title: Your first Blincus instance
description: Your first Blincus instance
---

## Let's Fire This Thing Up

You've [installed incus](/guides/getting-started), and you've [installed Blincus](/guides/installing). You did the quick tasks in the [post incus install](/guides/post-incus-install) guide. Now we're ready to take Blincus for a spin.


### Blincus Launch

To start your first instance, use `blincus launch`. 

The `launch` command expects the name of your instance as an argument. This will be the hostname, I tend to be specific to the purpose of the instance: `fleekdev`, `wails`, `briandotdev`. The instance name will be the only useful thing you have to help you remember why you created it; `dancing-monkey` isn't going to cut it.

The `launch` command also requires a flag specifying the template you want to use. To see the starter templates that come with Blincus, run `blincus template list`.

```
> blincus template list
ubuntu:
Ubuntu Jammy + cloud
Image: images:ubuntu/jammy/cloud

ubuntux:
Ubuntu Jammy cloud + x
Image: images:ubuntu/jammy/cloud
```

Pick one to test and launch it.

```bash
> blincus launch myfirst -t ubuntu
Using ubuntu template
Using debian cloud-init profile
Starting instance myfirst
Mounting scripts from /home/bjk/.blincus/scripts
Waiting for cloud init...
/usr/bin/cloud-init
..........................................
status: done
Blincus ID: bc11b8e9445c4a169eafa63bd293b224                                  
Mounting home directory at /home/bjk/host
Allowing X sharing:                                          
access control disabled, clients can connect from any host
Instance myfirst ready
Run blincus shell myfirst to enter

```

Success! And the output gives you your next step: `blincus shell myfirst`:

```bash
> blincus shell myfirst
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

 * Blincus instance: myfirst
 * Template: ubuntu
 * Image: images:ubuntu/jammy/cloud
 * Host Mounts: Host <-> Instance
   - /home/bjk/.config/blincus/scripts/ubuntu <-> /opt/scripts
   - /home/bjk <-> /home/bjk/host/

bjk@myfirst:~$ 

```

Blincus automatically sets the MOTD (message of the day) in your shell with some helpful information about the instance's configuration.

You're in a shell inside your running instance. To prove it to yourself, try running 

```bash
> cat /etc/os-release
```

The output should match the template you specified in the launch command.

```bash
PRETTY_NAME="Ubuntu 22.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.3 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy

```

That's pretty cool, since I'm running on a Fedora-based [Bluefin](https://projectbluefin.io) computer.