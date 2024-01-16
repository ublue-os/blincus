image_id() {
    local build=$1
    local manifest=$2
    #echo "build: $build"
    cfgdir=$(dirname "${CONFIG_FILE}")
    workdir="${cfgdir}/packer"
    img_id=$(jq -r '.builds[] | select(.name=="'"$build"'") | .artifact_id' "$workdir/$manifest.json")
    echo "$img_id"

}

image_alias() {
    local build=$1
    local manifest=$2
    #echo "build: $build"
    cfgdir=$(dirname "${CONFIG_FILE}")
    workdir="${cfgdir}/packer"
    img_id=$(jq -r '.builds[] | select(.name=="'"$build"'") | .custom_data.alias' "$workdir/$manifest.json")
    echo "$img_id"

}

unique_builds() {
    local build=$1
    cfgdir=$(dirname "${CONFIG_FILE}")
    workdir="${cfgdir}/packer"
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
    recipe="${cfgdir}/packer/${name}.pkr.hcl"
    if [ ! -f "${recipe}" ]; then
        echo "ERROR: recipe file not found: ${recipe}"
        exit 1
    fi

    workdir="${cfgdir}/packer"
    pushd "${workdir}" >/dev/null
    packer build --force "${name}.pkr.hcl"
    popd >/dev/null

    ubuilds=$(unique_builds "${name}")
    for build in ${ubuilds}; do
        echo ""
        echo "$(blue Build:) ${build}"
        img_id=$(image_id "${build}" "${name}")
        echo "  $(blue fingerprint:) ${img_id}"
        alias=$(image_alias "${build}" "${name}")
        echo "  $(blue alias:) ${alias}"
        tmplt=$(blincus_get_property "${img_id}" "template")
        echo "  $(blue template:) ${tmplt}"
        scrpts=$(blincus_get_property "${img_id}" "scripts")
        echo "  $(blue scripts:) ${scrpts}"

        # ensure sourcetemplate exists
        if [ ! -e "${cfgdir}/templates/${tmplt}.config.yaml" ]; then
            echo "Source template $(red ${tmplt}) does not exist"
            exit 1
        fi
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

        # Create config values for this image
        config_set "packer-${name}.image" "${imageref}"
        config_set "packer-${name}.scripts" "${scrpts}"

        # copy image template
        cp "${cfgdir}/templates/${tmplt}.config.yaml" "${cfgdir}/templates/packer-${name}.config.yaml"

    done
}
