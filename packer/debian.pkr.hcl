packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
source "incus" "bookworm" {
  image        = "images:debian/bookworm"
  output_image = "debian-bookworm"
  reuse        = true
  publish_properties = {
    "builder" = "blincus"
    "description" = "Debian Bookworm"
    "template" = "nocloud"
    "scripts" = "ubuntu"
  }
}
source "incus" "trixie" {
  image        = "images:debian/trixie"
  output_image = "debian-trixie"
  reuse        = true
  publish_properties = {
    "builder" = "blincus"
    "description" = "Debian Trixie"
    "template" = "nocloud"
    "scripts" = "debian"
  }
}

source "incus" "sid" {
  image        = "images:debian/sid"
  output_image = "debian-sid"
  reuse        = true
  publish_properties = {
    "builder" = "blincus"
    "description" = "Debian Sid"
    "template" = "nocloud"
    "scripts" = "debian"
  }
}

build {
  sources = [
    "incus.bookworm",
    "incus.trixie",
    "incus.sid",
    ]
  provisioner "file" {
    source = "common/90-incus"
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
    output     = "debian.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}

