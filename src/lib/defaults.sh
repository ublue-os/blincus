
write_defaults() {


  # default container engine
  config_set "engine" "incus"


  # ubuntu defaults
  config_set "ubuntu.image" "images:ubuntu/jammy/cloud"
  config_set "ubuntu.scripts" "ubuntu"
  
  config_set "ubuntux.image" "images:ubuntu/jammy/cloud"
  config_set "ubuntux.scripts" "ubuntu"
  # debian defaults
  config_set "debian.image" "images:debian/bookworm/cloud"
  config_set "debian.scripts" "debian"

  config_set "debianx.image" "images:debian/bookworm/cloud"
  config_set "debianx.scripts" "debian"
 
  #fedora defaults
  config_set "fedora.image" "images:fedora/39/cloud"
  config_set "fedora.scripts" "fedora"
  
  config_set "fedorax.image" "images:fedora/39/cloud"
  config_set "fedorax.scripts" "fedora"
  # todo: flag or JIT set this
  xhost +
}
