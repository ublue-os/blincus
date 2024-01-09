image_id(){
    local build=$1
    local manifest=$2
    #echo "build: $build"
    cfgdir=$(dirname "${CONFIG_FILE}")
    workdir="${cfgdir}/packer"
    img_id=$(jq -r '.builds[] | select(.name=="'"$build"'") | .artifact_id' "$workdir/$manifest.json")
    echo "$img_id"

}

image_alias(){
    local build=$1
    local manifest=$2
    #echo "build: $build"
    cfgdir=$(dirname "${CONFIG_FILE}")
    workdir="${cfgdir}/packer"
    img_id=$(jq -r '.builds[] | select(.name=="'"$build"'") | .custom_data.alias' "$workdir/$manifest.json")
    echo "$img_id"

}


unique_builds(){
    local build=$1
    cfgdir=$(dirname "${CONFIG_FILE}")
    workdir="${cfgdir}/packer"
    builds=$(jq -r '.builds| group_by(.name) | .[][-1] | .name' "$workdir/$1.json" )
    # return builds as an array
    echo "$builds"
}

plugin(){
    # check for packer plugin
    found=$(packer plugins installed | grep -q "incus" && echo "true" || echo "false")

    if [ "$found" == "false" ]; then
        echo "Installing packer plugin"
        packer plugins install github.com/bketelsen/incus
    fi

}