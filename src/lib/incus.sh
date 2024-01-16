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
	incus image get-property "$1" "$2"
}
