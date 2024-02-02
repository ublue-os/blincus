source "incus" "mantic" {
  image        = "images:ubuntu/mantic/desktop"
  output_image = "manticvmd"
  reuse        = true
  virtual_machine = true
  init_sleep = "30"
  launch_config = {
    "limits.memory" = "8GiB"
    "limits.cpu" = "4"
  }
  publish_properties = {
    "builder"     = "blincus"
    "description" = "Ubuntu mantic desktop"
    "cloud-init"  = "none"
    "profiles"    = "idmap,vmkeys"
    "scripts"     = "ubuntu"
  }
}

build {
  sources = ["incus.mantic"]
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
    output     = "manticvmd.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }

}


