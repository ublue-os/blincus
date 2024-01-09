---
title: Customizing Blincus
description: Make incus based development environments from custom images.
---



If you find yourself using the same images with the same packages/tools frequently you can use Hashicorp's Packer to build your own customized images. This trades one-time build costs for improved launch times since your customizations are done at build rather than launch.

:::note[This step is entirely optional!]
You can continue to use the templates that come with Blincus. They use `cloud-config` to provision the generic images provided by linuxcontainers.org.

Use this customization guide if you find yourself adding the same tools to each instance you launch and you want to speed up your launch times.
:::

Custom images are a way for you to move the time cost of installing frequently used packages and tools from "every time you launch an instance" to "whenever you want to refresh your custom image".

Custom images are built using [Packer](https://www.packer.io/), so you'll need to have `packer` installed on your Incus server.  Blincus will automatically install the Packer builder plugin that supports Incus images the first time you use it.

## Packer Recipes

Packer recipes are stored at `~/.config/blincus/packer` and have the file suffix `.pkr.hcl`.  They're written in HCL - Hashicorp Configuration Language, which is very similar to JSON.

### Plugins 

Every recipe starts with the plugin requirements stanza which tells Packer what plugins to use:

```
packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
```

Packer will automatically retrieve and install plugins required in this block.

### Source

The next block in the recipe defines the interaction with the Incus server. It specifies the source image that we'll use as a starting point, and it specifies the name of the output image that will be published to our Incus server.

```js {2,3,8,9}
source "incus" "jammy" {
  image        = "images:ubuntu/jammy"
  output_image = "ubuntu-jammy"
  reuse        = true
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Jammy"
    "template"    = "nocloud"
    "scripts"     = "ubuntu"
  }
}
```

This example will use `images:ubuntu/jammy` as the base image, and publish it as `ubuntu-jammy` on our local server when it's built.

:::note[Publish Properties]
Blincus uses the `publish_properties` list to store some important metadata about our custom image. Most importantly, it defines the launch template and scripts folder that should be used when launching an instance based on this image.
:::

### Build

The last stanza in the Packer recipe describes how to build the image. It references the sources we defined above, and describes how to provision the image using Packer provisioning plugins. All of the examples Blincus ships use the `shell` and `file` provisioners, but you can also choose others like Ansible if that is your thing.

Blincus expects the provisioner(s) to configure the image to conform to the [Conventions](/about/how-blincus-works) that Blincus uses.  Specifically:

* Matching user created in the image
* Plumbing required for sharing GUI/Audio 


A full Packer tutorial is outside the scope of this documention, please see the Packer website for more details. The provided examples should give you a good idea of how to get things done.

```js {3,8}
build {
  sources = ["incus.jammy"]
  provisioner "file" {
    source      = "common/90-incus"
    destination = "/tmp/90-incus"
  }

  provisioner "shell" {
    scripts = [
      "common/debian/packages.sh",
      "common/debian/user.sh",
      "common/debian/sudoers.sh",
    ]
  }
  ...
}
```

Here, the `file` provisioner takes the local file `common/90-incus` and places it in `/tmp/90-incus` in the instance. Later one of the provisioning scripts will put this file where it belongs with the appropriate permissions.

Next, the `shell` provisioner runs three bash scripts which install required packages, create the user in the image, and move the file from the `file` provisioner into `/etc/sudoers.d/` with the correct permissions.

When referencing files for your provisioning scripts, Blincus and Packer assume the `~/.config/blincus/packer` directory as the base directory if you use relative paths.

You can write your scripts inline if you prefer, or include them from disk as shown in these examples.

### Manifest

Blincus relies on the `manifest` post-processor in Packer to persist information about the build to disk.  Be sure to include `manifest` in your recipes that output a JSON file that has a name that matches the recipe file.  


Full example:

```
build {
...
  post-processor "manifest" {
    output     = "jammy.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }
}
```

## Putting it All Together

For a Packer recipe named `jammy.pkr.hcl`, you can run `blincus packer build jammy`.

Blincus will run Packer against the recipe, build the image, import into your Incus instance, and create a launch template for it. Finally Blincus will add an entry to your Blincus config (`~/.config/blincus/config.ini`) that ties the launch template together with the custom image name and shared scripts directory.

```ini
[packer-jammy]
image = ubuntu-jammy
scripts = ubuntu
```

When the build is complete you can launch an instance like this:

```bash
blincus launch -t packer-jammy myjammy
```

Get a shell with this command:

```bash
blincus shell myjammy
```

## Pro Tips

* Check the provided examples with names that start with numbers. They create layered images, each building off the previous. Use this as a recipe to build variations of images with a common base.

* Recipes can have more than one source, which would build more than one image. See the `debian` and `ubuntults` recipes for an example of how to do this.

* Share provisioning scripts between recipes. The examples use the `common/debian` scripts for both Ubuntu and Debian image provisioning. Similarly you could create `common/rhel` for images that use RedHat type commands and packages and share them with CentOS, Fedora, Alma images.

* Build individual recipes with `blincus packer build`, or build all of them with `blincus packer buildall`

* Use crontab or systemd timers to schedule regular rebuilds of your images

* Don't forget to add the plumbing to share graphical/audio resources if you want them in the instance. The example recipes that have names ending in `x` show you how to do this.



