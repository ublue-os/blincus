image_id() {
	local build=$1
	local manifest=$2
	#echo "build: $build"
	cfgdir=$(dirname "${CONFIG_FILE}")
	workdir="${cfgdir}/recipes"
	img_id=$(jq -r '.builds[] | select(.name=="'"$build"'") | .artifact_id' "$workdir/$manifest.json")
	echo "$img_id"

}

image_alias() {
	local build=$1
	local manifest=$2
	#echo "build: $build"
	cfgdir=$(dirname "${CONFIG_FILE}")
	workdir="${cfgdir}/recipes"
	img_id=$(jq -r '.builds[] | select(.name=="'"$build"'") | .custom_data.alias' "$workdir/$manifest.json")
	echo "$img_id"

}

unique_builds() {
	local build=$1
	cfgdir=$(dirname "${CONFIG_FILE}")
	workdir="${cfgdir}/recipes"
	builds=$(jq -r '.builds| group_by(.name) | .[][-1] | .name' "$workdir/$1.json")
	# return builds as an array
	echo "$builds"
}

plugin() {
	# check for packer plugin
	found=$(packer plugins installed | grep -q "incus" && echo "true" || echo "false")

	if [ "$found" == "false" ]; then
		echo "Installing packer plugin"
		packer plugins install github.com/bketelsen/incus
	fi

}

packer_build() {
	cfgdir=$(dirname "${CONFIG_FILE}")
	name=$1
	recipe="${cfgdir}/recipes/${name}.pkr.hcl"
	if [ ! -f "${recipe}" ]; then
		echo "ERROR: packer build recipe file not found: ${recipe}"
		exit 1
	fi

	workdir="${cfgdir}/recipes"
	pushd "${workdir}" >/dev/null
	packer build --force "${name}.pkr.hcl"
	popd >/dev/null

	ubuilds=$(unique_builds "${name}")
	echo "Unique builds: " $ubuilds
	for build in ${ubuilds}; do
		echo ""
		echo "$(blue Build:) ${build}"
		img_id=$(image_id "${build}" "${name}")
		echo "  $(blue fingerprint:) ${img_id}"
		alias=$(image_alias "${build}" "${name}")
		echo "  $(blue alias:) ${alias}"
		scrpts=$(blincus_get_property "${img_id}" "scripts")
		echo "  $(blue scripts:) ${scrpts}"
		cloudinit=$(blincus_get_property "${img_id}" "cloud-init")
		echo "  $(blue cloud-init:) ${cloudinit}"
		profiles=$(blincus_get_property "${img_id}" "profiles")
		echo "  $(blue profiles:) ${profiles}"

		description=$(blincus_get_property "${img_id}" "description")
		echo "  $(blue description:) ${description}"
		# ensure scriptdir exists
		if [ ! -e "${cfgdir}/scripts/${scrpts}" ]; then
			echo "Script directory $(red ${scrpts}) does not exist"
			exit 1
		fi

		local imageref
		# if alias is set, use it
		if [ -n "${alias}" ]; then
			imageref="${alias}"
		else
			imageref="${img_id}"
		fi

		local tname
		# if alias is set, use it
		if [ -n "${alias}" ]; then
			tname="${alias}"
		else
			tname="${name}-packer"
		fi

		# Create config values for this image
		config_set "${tname}.image" "${imageref}"
		config_set "${tname}.scripts" "${scrpts}"
		config_set "${tname}.description" "${description}"
		if [ ! -z "${cloudinit}" ]; then
			config_set "${tname}.cloud-init" "${cloudinit}"
		fi
		if [ ! -z "${profiles}" ]; then
			config_set "${tname}.profiles" "${profiles}"
		fi

	done
}
