---
title: Incus Installation
description: Notes about installing Incus
---

## Post-Install

### Incus Admin Group

Make sure to add your user to the `incus-admin` group:

```bash
usermod -aG incus-admin `whoami`
```

Logout or reboot for the group membership to take effect.

### Sub UID and Sub GID

You also need to edit `/etc/subuid` and `/etc/subgid` to add two sets of ID maps.

The first set allows Incus to create unprivileged containers as `root`:

```bash
echo "root:1000000:1000000000" | sudo tee -a /etc/subuid /etc/subgid
```

The second set allows Incus to map your user ID on to host to your user in the container to allow for seamless file sharing.

```bash
echo "root:1000:1" | sudo tee -a /etc/subuid /etc/subgid
```


## Further reading

- Read [about how-to guides](https://diataxis.fr/how-to-guides/) in the Diátaxis framework
