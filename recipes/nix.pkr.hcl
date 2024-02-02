source "incus" "nix" {
  image = "images:ubuntu/jammy"
  output_image = "ubuntu-nix"
  reuse = true
  publish_properties = {
    "builder" = "blincus"
    "description" = "Ubuntu + Nix"
    "cloud-init"  = "none"
    "scripts" = "ubuntu"
  }
}

build {
  sources = ["incus.nix"]
  provisioner "file" {
    source = "common/90-incus"
    destination = "/tmp/90-incus"
  }
  provisioner "shell" {
    scripts = [
      "common/debian/packages.sh",
      "common/debian/user.sh",
      "common/debian/sudoers.sh",
      "common/debian/nix.sh",
    ]
  }
    post-processor "manifest" {
    output     = "nix.json"
    strip_path = true
    custom_data = {
      alias = "${build.Alias}"
    }
  }


}

