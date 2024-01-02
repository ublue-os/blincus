blincus_instances() {
    incus ls --format json |  jq -r '.[] | select(.config."user.blincusuid" != null) | .config."user.blincusuid"'
}

blincus_instance_name() {
    local guid=$1
    incus ls --format json |  jq -r '.[] | select(.config."user.blincusuid" == "'"$guid"'") | .name'
}