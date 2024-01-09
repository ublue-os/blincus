packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
source "incus" "jammybase" {
  image        = "images:ubuntu/jammy"
  output_image = "jammybase"
  reuse        = true
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Jammy - X"
    "template"    = "nocloud"
    "scripts"     = "ubuntu"
  }
}

build {
  sources = ["incus.jammybase"]
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
    output     = "0-jammybase.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


