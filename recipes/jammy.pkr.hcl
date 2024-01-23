packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
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

  post-processor "manifest" {
    output     = "jammy.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


