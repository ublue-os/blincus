# blincus

Disposable [Incus](https://linuxcontainers.org/incus/) dev containers for the
current directory — so project cruft lands in a container, not on your host.

```console
$ cd ~/projects/myapp
$ blincus enter
Creating container 'myapp' from images:debian/trixie/cloud...
Mounted /home/you/projects/myapp -> ~/myapp
you@myapp:~/myapp$ code .        # opens on your host display
```

## What it does

`blincus enter`, run from a project directory:

- creates (or reuses) a container bound to that directory
- mounts the directory at `~/<dirname>` inside the container
- forwards X11, Wayland, and PulseAudio/PipeWire sockets and the GPU,
  so GUI apps — IDEs included — render on the host display
- drops you into a login shell in the project directory

Containers are tracked by project path, so `blincus enter`, `blincus rm`,
and `blincus ls` all just work from inside the project.

## Commands

| Command | What it does |
|---|---|
| `blincus enter [-i IMAGE]` | Create or enter the container for `$PWD` |
| `blincus ls` | List blincus containers and their project dirs |
| `blincus rm [NAME]` | Delete a container (default: the one for `$PWD`) |

## Requirements

- Linux host with [Incus](https://linuxcontainers.org/incus/docs/main/installing/)
  initialized (`incus admin init`)
- `jq`
- `xhost` (for X11 apps; part of `x11-xserver-utils` on Debian)
- `root`'s `/etc/subuid` and `/etc/subgid` must include your host uid. Incus
  runs unprivileged containers as root through a subordinate id range that,
  by default, does not overlap real user uids, but blincus's `raw.idmap`
  maps your host uid straight into the container (see below) — which
  `newuidmap`/`newgidmap` only allow if that uid is explicitly listed for
  `root`. If `blincus enter` fails with `newuidmap: ... not allowed`, add a
  line for your uid to both files, e.g. for uid 1000:

  ```console
  $ echo "root:1000:1" | sudo tee -a /etc/subuid /etc/subgid
  ```

## Install

```console
$ ./install     # copies blincus to ~/.local/bin + bash completions
```

## Configuration

`~/.config/blincus/config`, created on first run:

```ini
image=images:debian/trixie/cloud
```

Any cloud-init-enabled image works (`incus image list images: cloud`).
Override per-container with `blincus enter -i images:fedora/42/cloud`.

## How the forwarding works

Host sockets can't be mounted directly onto `/tmp` or `/run/user` in the
container (both are fresh tmpfs at boot), so blincus mounts them under
`/mnt/.blincus/` via a shared `blincus` Incus profile and a small systemd
user service links them into place at login. `raw.idmap` maps your host
uid to the container user, and X11 access is granted with
`xhost +si:localuser:$USER` — your user only, not `xhost +`.

Delete the `blincus` profile (`incus profile delete blincus`) after changing
display setups; it's recreated from the live environment on the next launch.

## License

[Apache 2.0](LICENSE)
