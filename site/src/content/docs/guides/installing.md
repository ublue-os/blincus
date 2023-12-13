---
title: Installing Blincus
description: Make incus based development environments.
---

### Curl or Wget

If you like to live your life dangerously, or you want the latest release,
you can trust me and simply run this in your terminal:

```sh
curl -s https://raw.githubusercontent.com/ublue-os/blincus/main/install | sudo sh
# or using wget
wget -qO- https://raw.githubusercontent.com/ublue-os/blincus/main/install | sudo sh
```

or if you want to select a custom directory to install without sudo:

```sh
curl -s https://raw.githubusercontent.com/ublue-os/blincus/main/install | sh -s -- --prefix ~/.local
# or using wget
wget -qO- https://raw.githubusercontent.com/ublue-os/blincus/main/install | sh -s -- --prefix ~/.local
```

If you want to install the last development version, directly from last commit on git, you can use:

```sh
curl -s https://raw.githubusercontent.com/ublue-os/blincus/main/install | sudo sh -s -- --next
# or using wget
wget -qO- https://raw.githubusercontent.com/ublue-os/blincus/main/install | sudo sh -s -- --next
```

or:

```sh
curl -s https://raw.githubusercontent.com/ublue-os/blincus/main/install | sh -s -- --next --prefix ~/.local
# or using wget
wget -qO- https://raw.githubusercontent.com/ublue-os/blincus/main/install | sh -s -- --next --prefix ~/.local
```


## Further reading

- Read [about how-to guides](https://diataxis.fr/how-to-guides/) in the Diátaxis framework
