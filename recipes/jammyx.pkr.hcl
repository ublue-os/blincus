packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
source "incus" "jammyx" {
  image        = "images:ubuntu/jammy"
  output_image = "ubuntu-jammyx"
  reuse        = true
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Jammy - X"
    "scripts"     = "ubuntu"
    "profiles"    = "container,idmap,xdevs"
    "cloud-init"  = "none"
  }
}

build {
  sources = ["incus.jammyx"]
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
    output     = "jammyx.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


