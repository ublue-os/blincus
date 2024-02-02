source "incus" "lunar" {
  image        = "images:ubuntu/lunar"
  output_image = "lunarvm"
  reuse        = true
  virtual_machine = true
  init_sleep = "30"
  launch_config = {
    "limits.memory" = "8GiB"
    "limits.cpu" = "4"
  }
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu Lunar CloudInit VM"
    "scripts"     = "ubuntu"
    "profiles"    = "idmap,vmcloud"
    "cloud-init"  = "debianvm"
  }
}

build {
  sources = ["incus.lunar"]
  provisioner "file" {
    source      = "common/90-incus"
    destination = "/tmp/90-incus"
  }

  provisioner "shell" {
    scripts = [
      "common/debian/cleanusers.sh",
      "common/debian/cloud.sh",
      "common/debian/packagesdev.sh",
    ]
  }

  post-processor "manifest" {
    output     = "lunarvm.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


