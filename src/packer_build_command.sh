cfgdir=$(dirname "${CONFIG_FILE}")
name=${args[name]}

plugin

personalize

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