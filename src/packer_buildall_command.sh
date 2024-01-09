cfgdir=$(dirname "${CONFIG_FILE}")

personalize

packer_path="${cfgdir}/packer"

for file in $packer_path/*.pkr.hcl; do
    name="$(basename "${file}" .pkr.hcl)"
    echo ""
	echo "Found definition $(red_bold $name):"
    blincus packer build $name

done