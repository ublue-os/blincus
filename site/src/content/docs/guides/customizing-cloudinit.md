---
title: Custom Images - cloud-config
description: Create custom images using Distrobuilder with cloud-init.
---

## Tutorial

You will create a build recipe in `$HOME/.config/blincus/build`. The recipe must be a valid distrobuilder template.

This example creates a recipe called `fatfedora`, associates the `fedora` scripts directory to it, and copies the launch template from the existing `fedora.config.yaml`.

```bash
$ blincus custom-image create fatfedora --template fedora --scripts fedora
Created /home/bjk/.config/blincus/build/fatfedora.yaml recipe
Created /home/bjk/.config/blincus/templates/builder-fatfedora.config.yaml template
Next Steps:
 * Edit /home/bjk/.config/blincus/build/fatfedora.yaml with a valid Distrobuilder recipe
 * Run `blincus custom-image build fatfedora` to build the image

```

The template is then associated with the image and the scripts directory in the blincus config file:

```ini
[builder-fatfedora]
image = builder-fatfedora
scripts = fedora
```

The recipe that `blincus custom-image create` creates is empty. This is the part where you make that empty recipe file into a valid Distrobuilder definition. You'll need these references for your journey:

- [distrobuilder examples](https://github.com/lxc/distrobuilder/tree/main/doc/examples)
- [linuxcontainers images: sources](https://github.com/lxc/lxc-ci/tree/main/images)
- the blincus Ubuntu example at `$HOME/.config/blincus/build/ubuntu.yaml`
- the blincus Fedora example at `$HOME/.config/blincus/build/fedora.yaml`

:::note[Pay Careful Attention]
Most Blincus templates use `#cloud-config` definitions embedded in your launch templates to create users and install packages in your instances. This isn't a requirement, but a convention that simplifies the process of creating a user in your instance that matches your user on the host.

If you don't include `cloud-init` in your custom recipes and provide a valid `cloud-config` in your launch template then you are responsible for creating a matching user account in your custom recipe. `blincus shell` expects to execute a login shell on the instance with a user account that matches the one on the host.

Your Distrobuilder recipe needs to install and use `cloud-init`, which will apply the `#cloud-config` supplied by your launch template when your instances are created.

The [reference docs](https://linuxcontainers.org/distrobuilder/docs/latest/reference/) for distrobuilder are a little opaque, so use the provided examples as a guide.

Finally, notice that the provided Ubuntu and Fedora examples specify `variant: cloud` right at the top of the config. Yours should too!
:::

Now that the recipe and launch template are in place, we can build the custom image:

```bash
$ blincus custom-image build fatfedora
... LOTS OF SCROLLING BUILD OUTPUT HERE ...
Importing image
Image imported with fingerprint: 68243888d2955cf6097e516ebaa77226c1b5584ddd555235c2cd6eee5fc89470
Image builder-fatfedora imported

```

## Conventions

### Build Recipe Name

A build recipe in the file `$HOME/.config/blincus/build/mysnowflake.yaml` will result in an image with the alias `builder-mysnowflake`. Blincus prepends `builder-` to the image names to try to minimize confusion between stock Incus images and your custom built local images.

### Template Name

When launching an instance with a custom image, Blincus follows the same [conventions](/about/how-blincus-works) as it does when launching a stock image. the `blincus custom-image create` will create a new launch template for you based on the existing template you specify with the `--template` flag.

### Custom Properties

When importing the image after it is built, Blincus will add the custom property `builder` and set the value to `blincus`.

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


### Tailscale

Ephemeral keys https://tailscale.com/kb/1085/auth-keys