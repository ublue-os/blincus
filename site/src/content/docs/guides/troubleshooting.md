

## No root device could be found

```
If this is your first time running Incus on this machine, you should also run: incus admin init

Creating somecontainer
Error: Failed instance creation: Failed creating instance record: Failed initialising instance: Failed getting root disk: No root device could be found

```

This error is because Incus hasn't been initialized yet. Run `incus admin init`.