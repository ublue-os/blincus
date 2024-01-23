packer {
  required_plugins {
    incus = {
      version = ">= 1.0.4"
      source  = "github.com/bketelsen/incus"
    }
  }
}
source "incus" "jammydevx" {
  image        = "jammydev"
  output_image = "jammydevx"
  reuse        = true
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Jammy - Dev X"
    "template"    = "nocloud"
    "scripts"     = "ubuntu"
  }
}

build {
  sources = ["incus.jammydevx"]

  provisioner "shell" {
    scripts = [
      "common/debian/packagesx.sh",
    ]
  }

  post-processor "manifest" {
    output     = "2-jammydevx.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


