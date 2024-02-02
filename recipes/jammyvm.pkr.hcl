source "incus" "jammy" {
  image        = "images:ubuntu/jammy"
  output_image = "jammyvm"
  reuse        = true
  virtual_machine = true
  init_sleep = "30"
  launch_config = {
    "limits.memory" = "8GiB"
    "limits.cpu" = "4"
  }
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Jammy Cloud-Init VM"
    "template"    = "nocloud"
    "scripts"     = "ubuntu"
    "profiles"    = "idmap,vmcloud"
    "cloud-init"  = "debianvm"
  }
}

build {
  sources = ["incus.jammy"]

  provisioner "shell" {
    scripts = [
      "common/debian/cleanusers.sh",
      "common/debian/cloud.sh",
      "common/debian/packagesdev.sh",
    ]
  }

  post-processor "manifest" {
    output     = "jammyvm.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


