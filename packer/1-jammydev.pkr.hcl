packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
source "incus" "jammydev" {
  image        = "jammybase"
  output_image = "jammydev"
  reuse        = true
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Jammy - Dev"
    "template"    = "nocloud"
    "scripts"     = "ubuntu"
  }
}

build {
  sources = ["incus.jammydev"]
  provisioner "file" {
    source      = "common/90-incus"
    destination = "/tmp/90-incus"
  }
  provisioner "shell" {
    scripts = [
      "common/debian/packagesdev.sh",
    ]
  }

  post-processor "manifest" {
    output     = "1-jammydev.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


