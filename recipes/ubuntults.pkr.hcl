packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
source "incus" "focal" {
  image        = "images:ubuntu/focal"
  output_image = "focalp"
  reuse        = true
  publish_properties = {
    "builder" = "blincus"
    "description" = "Ubuntu Focal"
    "cloud-init"  = "none"
    "scripts" = "ubuntu"
  }
}
source "incus" "jammy" {
  image        = "images:ubuntu/jammy"
  output_image = "jammyp"
  reuse        = true
  publish_properties = {
    "builder" = "blincus"
    "description" = "Ubuntu Jammy"
    "cloud-init"  = "none"
    "scripts" = "ubuntu"

  }
}

build {
  sources = [
    "incus.focal",
    "incus.jammy"
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
    output     = "ubuntults.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}

