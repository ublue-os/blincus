source "incus" "mantic" {
  image        = "images:ubuntu/mantic"
  output_image = "ubuntu-mantic"
  reuse        = true
  publish_properties = {
    "builder" = "blincus"
    "description" = "Ubuntu Mantic"
    "scripts"     = "ubuntu"
    "cloud-init"  = "none"
  }
}

build {
  sources = ["incus.mantic"]
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
    output     = "mantic.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}

