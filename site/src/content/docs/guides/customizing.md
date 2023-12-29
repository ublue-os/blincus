---
title: Customizing Blincus
description: Make incus based development environments.
---



If you find yourself using the same images with the same packages/tools frequently you can use the `blincus custom-image` set of commands to create a custom image locally.

__* This step is entirely optional__

Custom images are a way for you to move the time cost of installing frequently used packages and tools from "every time you launch an instance" to "whenever you want to refresh your custom image".

Custom images are built using [distrobuilder](https://linuxcontainers.org/distrobuilder/introduction/), so you'll need to have `distrobuilder` installed on your Incus server.  Many of the `distrobuilder` recipes will use [debootstrap](https://wiki.debian.org/Debootstrap) if they're Debian or Ubuntu based recipes. So you'll probably want that installed as well.

:::note[Decision Time!]
Most Blincus templates use `#cloud-config` definitions embedded in your launch templates to create users and install packages in your instances. This isn't a requirement, but a convention that simplifies the process of creating a user in your instance that matches your user on the host.

Choose one of the guides below to build your custom recipe.
:::


:::tip[Use cloud-config]
Read the documentation for creating a recipe [with cloud-config](/guides/customizing-cloudinit).
:::

:::tip[No cloud-config]
Read the documentation for creating a recipe [without cloud-config](/guides/customizing-nocloudinit).
:::

## Conventions

### Build Recipe Name

A build recipe in the file `$HOME/.config/blincus/build/mysnowflake.yaml` will result in an image with the alias `builder-mysnowflake`. Blincus prepends `builder-` to the image names to try to minimize confusion between stock Incus images and your custom built local images.

### Template Name

When launching an instance with a custom image, Blincus follows the same [conventions](/about/how-blincus-works) as it does when launching a stock image. the `blincus custom-image create` will create a new launch template for you based on the existing template you specify with the `--template` flag.

### Custom Properties

When importing the image after it is built, Blincus will add the custom property `builder` to the image metadata, and set the value to `blincus`.

You can see this property and all the others that are set with the following command:

```bash
incus image list --format json
```

## Reference

| Configuration      | Description | Purpose | Location |
| ----------- | ----------- | ----------- | ----------- |
| Build Recipe      | Distrobuilder YAML file   | Describe image build process    |  $HOME/.config/blincus/build/{name}.yaml       |
| Launch Template   | Incus Launch Configuration    | Describe instance launch parameters   | $HOME/.config/blincus/templates/{name}.config.yaml          |
| Blincus Config      | Blincus configuration file   | Map launch templates to images   |  $HOME/.config/blincus/config.ini       |


