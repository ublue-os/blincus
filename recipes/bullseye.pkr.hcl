packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
source "incus" "bullseye" {
  image        = "images:debian/bullseye"
  output_image = "debian-bullseye"
  reuse        = true
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Debian Bullseye"
    "scripts"     = "debian"
    "cloud-init"  = "none"
  }
}

build {
  sources = ["incus.bullseye"]
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
    output     = "bullseye.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


