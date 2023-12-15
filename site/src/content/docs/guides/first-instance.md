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

```bash
> blincus template list
debian
  description: "Debian"
debianx
  description: "Debian with X Sharing"
fedora
  description: "Fedora"
fedorax
  description: "Fedora with X Sharing"
nix
  description: "Nix on Ubuntu"
ubuntu
  description: "Ubuntu"
ubuntux
  description: "Ubuntu with X sharing"
```

Pick one to test and launch it.

```bash
> blincus launch myfirst -t ubuntu
Using ubuntu template
Creating myfirst
Starting instance myfirst
Waiting for cloud init...
...........................
status: done
Mounting home directory
Device myhomedir added to myfirst
Instance myfirst ready
Run 'blincus shell myfirst' to enter

```

Success! And the output gives you your next step: `blincus shell myfirst`:

```bash
> blincus shell myfirst
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

bjk@myfirst:~$ 

```

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