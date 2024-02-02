source "incus" "jammydevx" {
  image        = "jammydev"
  output_image = "jammydevx"
  reuse        = true
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Jammy - Dev X"
    "scripts"     = "ubuntu"
    "cloud-init"  = "none"
    "profiles"    = "container,idmap,xdevs"
  }
}

build {
  sources = ["incus.jammydevx"]

  provisioner "shell" {
    scripts = [
      "common/debian/code.sh",
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


