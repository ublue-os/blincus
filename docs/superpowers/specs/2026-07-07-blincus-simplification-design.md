# blincus v2: Simplification Design

**Date:** 2026-07-07
**Status:** Approved

## Purpose

blincus exists so development cruft lands in disposable Incus containers instead of
the host. Over time it grew templates, VM support, a personalization system, a docs
site, and a code-generation toolchain. This design trims it back to one job:

> Run `blincus enter` in a project directory and get a container with that
> directory mounted as the project, with X11/Wayland forwarding so GUI IDEs
> run inside the container but appear on the host display.

## Requirements

1. Share the current directory into the container as the project.
2. Forward X11 and Wayland sockets so GUI apps (IDEs) display on the host.
3. Keep GPU passthrough and audio (PulseAudio/PipeWire) forwarding.
4. One default image, configurable, overridable per-launch.
5. Plain hand-written bash — no bashly code generation.

Explicitly dropped: VM support, the template system, per-distro script
directories, the personalize/sed system, `$HOME` mounted at `~/host`,
incus command passthrough, the Astro docs site, the Nix flake.

## CLI surface

```
blincus enter [-i IMAGE]   # create-or-enter the container for $PWD
blincus ls                 # list blincus containers + their project dirs
blincus rm [NAME]          # delete a container (default: the one for $PWD)
blincus --help | --version
```

The script is a single hand-written bash file (~300 lines), `set -euo pipefail`,
shellcheck-clean, with simple `case`-based argument parsing.

## Configuration

One file, `~/.config/blincus/config`, created on first run:

```
image=images:debian/trixie/cloud
```

`blincus enter -i images:fedora/42/cloud` overrides per-launch. No config
subcommand; users edit the file.

## Container identity

- Each container carries `user.blincus.project=<absolute project path>` in its
  Incus instance config.
- `enter` looks up containers by project path first. Name is derived from the
  sanitized directory basename (lowercase, alphanumeric plus hyphen); if a
  *different* directory already owns that name, a short hash of the full path
  is appended.
- `ls` filters `incus ls --format json` on `user.blincus.project` and shows
  name, status, and project path.
- `rm` resolves the container for `$PWD` when no name is given, confirms, then
  `incus delete -f`.

## The `blincus` Incus profile

Created idempotently on first run from the live host environment:

| Item | Value | Why |
|---|---|---|
| `raw.idmap` | `both 1000 1000` | Host uid maps 1:1; project mount ownership just works |
| `security.nesting` | `true` | Allows nested container tooling (docker/podman) inside |
| `gpu` device | gid 44 | Hardware acceleration for IDEs/browsers |
| `x11` disk | `/tmp/.X11-unix/X0` → `/mnt/.blincus/X0` | X11 socket |
| `wayland` disk | `$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY` → `/mnt/.blincus/wayland-0` | Wayland socket; skipped if host has no Wayland session |
| `audio` disk | `$XDG_RUNTIME_DIR/pulse/native` → `/mnt/.blincus/pulse-native` | PulseAudio socket; PipeWire serves the same path |

Sockets are mounted under `/mnt/.blincus/` and symlinked into their real
locations (`/tmp/.X11-unix/X0`, `$XDG_RUNTIME_DIR/wayland-0`,
`$XDG_RUNTIME_DIR/pulse/native`) by a small systemd user service inside the
container, because `/tmp` and `/run/user` are fresh tmpfs mounts at container
boot and would shadow direct disk-device mounts.

X11 authorization: `enter` runs `xhost +si:localuser:$USER` when `DISPLAY` is
set. Because of the idmap, the container user's connection carries the host
uid, so only that user is granted — replacing the previous `xhost +` (which
disabled access control entirely).

## Provisioning: inline cloud-init

On first `enter` for a project, the script generates cloud-init user-data
in-memory (heredoc) with live values — no files templated on disk:

- User: host `$USER`, uid 1000, sudo NOPASSWD, shell `/bin/bash` (the host's
  shell isn't guaranteed to exist in the image), first `~/.ssh/id*.pub` as
  authorized key if present.
- `write_files`: the socket-symlink startup script + systemd user service;
  `/etc/profile.d/blincus.sh` exporting `DISPLAY=:0`,
  `WAYLAND_DISPLAY=wayland-0`.
- `runcmd`: enable the user service.

Launch flow:

1. Ensure the `blincus` profile exists (create from host env if not).
2. `incus launch <image> <name> -p default -p blincus --config user.user-data=...`
3. Wait for cloud-init (`cloud-init status --wait`).
4. Add the project disk device: `$PWD` → `/home/$USER/<dirname>`.
5. `xhost +si:localuser:$USER` if `DISPLAY` is set.
6. Exec a login shell as the user, starting in the project directory.

Subsequent `enter`s: start the container if stopped, re-run the xhost grant,
exec in. No cloud-init wait.

## Error handling

- Missing `incus` binary → clear install pointer, exit 1.
- Name collision with a non-blincus container → error naming the conflicting
  container rather than adopting it.
- Cloud-init failure/timeout → surface the status output and suggest
  `blincus rm` + retry.
- `rm` with no matching container → say so, list candidates via `blincus ls`.

## Repo cleanup

**Deleted:** `site/`, `flake.nix`, `flake.lock`,
`.github/workflows/flakehub-publish-tagged.yml`, `Dockerfile`,
`.devcontainer/`, `src/` (all bashly sources), `templates/`, `profiles/`,
`cloud-init/`, `scripts/`, `test/`, `settings.yml`, `completions.bash`,
`renovate.json`, `.github/dependabot.yml`, `GLOSSARY.md`, `SHOULDERS.md`,
`TODO.md`.

**Kept / rewritten:**

- `blincus` — the new hand-written script (the source of truth, no codegen)
- `install` / `uninstall` — simplified copy-to-`~/.local/bin` scripts
- `completions/blincus` — hand-written bash completions for 3 commands
- `README.md` — becomes the documentation (usage, how forwarding works)
- `LICENSE`
- `Justfile` — `lint` (shellcheck), `format` (shfmt), `install`, `uninstall`
- `empty-incus.sh` — still useful for wiping test instances

## Testing

- `shellcheck` clean; `shfmt` formatted.
- Manual end-to-end on this machine (Incus 7.2, Wayland + Xwayland host):
  `blincus enter` in a real project → GUI app opens on host display →
  `blincus ls` shows it → `blincus rm` deletes it → re-`enter` recreates.

## Out of scope

Multiple simultaneous display servers, non-1000 uids, remote Incus servers,
Windows/WSL quirks, macOS.
