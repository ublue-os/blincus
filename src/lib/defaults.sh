write_defaults() {


	# default container engine
	config_set "default_cloud-init" "debian"
	config_set "default_container_image" "images:ubuntu/mantic/cloud"
	config_set "default_container_profiles" "container,idmap"
	config_set "default_scripts" "ubuntu"
	config_set "default_home-mounts" "none"
	config_set "default_vm_image" "images:ubuntu/mantic/cloud"
	config_set "default_vm_profiles" "idmap,vmkeys"
	config_set "prompt_integration" "false"

	# ubuntu defaults
	config_set "ubuntu.image" "images:ubuntu/jammy/cloud"
	config_set "ubuntu.scripts" "ubuntu"
	config_set "ubuntu.description" "Ubuntu Jammy + cloud"

	config_set "ubuntux.image" "images:ubuntu/jammy/cloud"
	config_set "ubuntux.scripts" "ubuntu"
	config_set "ubuntux.description" "Ubuntu Jammy cloud + x"
	config_set "ubuntux.profiles" "container,idmap,xdevs"
	config_set "ubuntux.cloud-init" "debianx"
	
	# debian defaults
	config_set "debian.image" "images:debian/bookworm/cloud"
	config_set "debian.scripts" "debian"
	config_set "debian.description" "Debian Bookworm + cloud"
	
	config_set "debianx.image" "images:debian/bookworm/cloud"
	config_set "debianx.scripts" "debian"
	config_set "debianx.description" "Debian Bookworm cloud + x"
	config_set "debianx.profiles" "container,idmap,xdevs"
	config_set "debianx.cloud-init" "debianx"

	#fedora defaults
	config_set "fedora.image" "images:fedora/39/cloud"
	config_set "fedora.scripts" "fedora"
	config_set "fedora.description" "Fedora 39 + cloud"

	config_set "fedorax.image" "images:fedora/39/cloud"
	config_set "fedorax.scripts" "fedora"
	config_set "fedorax.description" "Fedora 39 cloud + x"
	config_set "fedorax.profiles" "container,idmap,xdevs"
	config_set "fedorax.cloud-init" "fedorax"
	
	# nix defaults

	config_set "nix.image" "images:ubuntu/jammy/cloud"
	config_set "nix.description" "Ubuntu + Nix"
	config_set "nix.scripts" "nix"
	# todo: flag or JIT set this
	# xhost +
}
