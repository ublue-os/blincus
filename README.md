# blincus

```
 ____  _ _
|  _ \| (_)
| |_) | |_ _ __   ___ _   _ ___
|  _ <| | | '_ \ / __| | | / __|
| |_) | | | | | | (__| |_| \__ \
|____/|_|_|_| |_|\___|\__,_|___/

```

Manage development containers with Incus

[Documentation](https://blincus.dev)
[Discourse](https://universal-blue.discourse.group/)


## Usage as a flake

[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/ublue-os/blincus/badge)](https://flakehub.com/flake/ublue-os/blincus)

Add blincus to your `flake.nix`:

```nix
{
  inputs.blincus.url = "https://flakehub.com/f/ublue-os/blincus/*.tar.gz";

  outputs = { self, blincus }: {
    # Use in your outputs
  };
}

```

## Reminders / Notes
- [ ] todo add check for genisoimage/mkisofs
sudo ln -s /usr/bin/genisoimage mkisofs
