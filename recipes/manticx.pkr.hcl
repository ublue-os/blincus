packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
source "incus" "manticx" {
  image        = "images:ubuntu/mantic"
  output_image = "ubuntu-manticx"
  reuse        = true
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Mantic - X"
    "cloud-init"  = "none"
    "profiles"    = "container,idmap,xdevs"
    "scripts"     = "ubuntu"
  }
}

build {
  sources = ["incus.manticx"]
  provisioner "file" {
    source      = "common/90-incus"
    destination = "/tmp/90-incus"
  }
  provisioner "file" {
    source      = "common/debian/mystartup.service"
    destination = "/tmp/mystartup.service"
  }

  provisioner "file" {
    source      = "common/debian/mystartup.sh"
    destination = "/tmp/mystartup.sh"
  }
  provisioner "shell" {
    scripts = [
      "common/debian/code.sh",
      "common/debian/user.sh",
      "common/debian/sudoers.sh",
      "common/debian/provisionstartup.sh",
    ]
  }

  post-processor "manifest" {
    output     = "manticx.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


