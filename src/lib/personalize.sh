personalize() {

	cfgdir=$(dirname "${CONFIG_FILE}")

	cloud_path="${cfgdir}/cloud-init"

	for file in $cloud_path/* $cloud_path/**/*; do

		# if it's not a directory
		if ! [ -d "$file" ]; then
			personalize_file "${file}"
		fi
	done

	profile_path="${cfgdir}/profiles"

	for file in $profile_path/* $profile_path/**/*; do

		# if it's not a directory
		if ! [ -d "$file" ]; then
			personalize_file "${file}"
		fi
	done
}

personalize_file() {
	file=$1
	fullname=$(getent passwd "$USER" | cut -d ':' -f 5)
	sed -i "s/BLINCUSUSER/$USER/g" "$file"
	sed -i "s/BLINCUSFULLNAME/$fullname/g" "$file"

	# if we're running on WSL we need to remove the gecos line from the config
	# https://wsl.dev/wslblincus/
	if grep -qE "(Microsoft|WSL)" /proc/version &>/dev/null; then
		sed -i 's/gecos/#gecos/g' "$file"
	fi

	# I don't know a better way to get the first file
	for i in "$HOME"/.ssh/id*.pub; do
		[ -f "$i" ] || break
		contents=$(cat "$i")
		sed -i "s|SSHKEY|$contents|g" "$file"
		break

	done
}