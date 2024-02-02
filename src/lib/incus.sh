blincus_instances() {
	incus ls --format json | jq -r '.[] | select(.config."user.blincusuid" != null) | .config."user.blincusuid"'
}

blincus_instance_name() {
	local guid=$1
	incus ls --format json | jq -r '.[] | select(.config."user.blincusuid" == "'"$guid"'") | .name'
}

blincus_get_property() {
	local image=$1
	local property=$2
	incus image get-property "$1" "$2" || echo ""
}

blincus_profile_exists() {
	local profile=$1
	name=$(incus profile ls --format json | jq -r '.[] | select(.name == "'"$profile"'") | .name')
	if [[ $name == $profile ]]; then
		echo 1
	else
		echo 0
	fi

}

# images that haven't been assigned an alias
dangling_images() {
	incus image list --format json | jq -r '.[] | select ( .aliases | length == 0) | .fingerprint '
}