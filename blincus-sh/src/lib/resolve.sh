profile_line() {
	local template=$1
	local vm=$2
	profilelist=$(config_get "$template".profiles)
	if [ -z "$profilelist" ]; then
		if [[ ! -z "${vm}" ]]; then
			profilelist=$(config_get default_vm_profiles)
		else
			profilelist=$(config_get default_container_profiles)
		fi
	fi
	IFS=,
	read line <<<$profilelist
	profiles=($line)
	shopt -s extglob
	profileline='--profile default'
	for each in "${profiles[@]}"; do
		profileline+=" --profile "
		profileline+="${each##*( )}"
	done
	echo "${profileline}"
}

image() {
	local template=$1
	local vm=$2

	imagename=$(config_get "$template".image)
	if [ -z "$imagename" ]; then
		if [[ ! -z "${vm}" ]]; then
			imagename=$(config_get default_vm_image)
		else
			imagename=$(config_get default_container_image)
		fi
	fi
	echo "${imagename}"
}
scripts() {
	local template=$1
	local vm=$2

	scriptsdir=$(config_get "$template".scripts)
	if [ -z "$scriptsdir" ]; then

		scriptsdir=$(config_get default_scripts)

	fi
	echo "${scriptsdir}"
}

home_mounts() {
	local template=$1
	local vm=$2

	homemounts=$(config_get "$template".home-mounts)
	if [ -z "$homemounts" ]; then

		homemounts=$(config_get default_home-mounts)

	fi
	echo "${homemounts}"
}

cloud() {
	local template=$1
	local vm=$2

	cloudinit=$(config_get "$template".cloud-init)
	if [ -z "$cloudinit" ]; then

		cloudinit=$(config_get default_cloud-init)

	fi
	echo "${cloudinit}"
}

get_profile() {
	local image=$1
	local isx11=0
	local iswayland=0
	local xsocket="0"
	local waylandsocket="0"
	local prefix=""
	local base="shifting"
	local profile=""

	# alpine is special
	if [[ $image =~ "alpine" ]]; then
		prefix="alpine"
	fi
	if [[ -v WAYLAND_DISPLAY ]]; then
		iswayland=1
		if [[ $WAYLAND_DISPLAY =~ "1" ]]; then
			waylandsocket="1"
		fi
	else
		isx11=1
		if [[ $DISPLAY =~ "1" ]]; then
			xsocket="1"
		fi
	fi

	# check for wayland, use it if it is there
	if [[ iswayland -eq 1 ]]; then
		base+="wayland"
		base+="${waylandsocket}"
	else
		base+="x"
		base+="${xsocket}"
	fi

	echo "${prefix}${base}"

}
