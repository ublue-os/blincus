comp=${args[--completions]}

cfgdir=$(dirname "${CONFIG_FILE}")

packer_path="${cfgdir}/packer"


if [[  $comp ]]; then
    packers=()
    for file in $packer_path/*.pkr.hcl; do
        name="$(basename "${file}" .pkr.hcl)"
        packers+=( $name )
    done
    echo ${packers[@]}
    return
fi


for file in $packer_path/*.pkr.hcl; do
    name="$(basename "${file}" .pkr.hcl)"
	echo "$(blue_bold $name)"
    echo "$(grep "description" ${file})"

done