write_defaults() {

	# default container engine

	config_set "Jammy.image" "images:ubuntu/jammy/cloud"
	config_set "Jammy.description" "Ubuntu Jammy + cloud-init"

	
	# todo: flag or JIT set this
	# xhost +
}
