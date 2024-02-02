cfgdir=$(dirname "${CONFIG_FILE}")

personalize

packer_path="${cfgdir}/recipes"

for file in $packer_path/*.pkr.hcl; do
	name="$(basename "${file}" .pkr.hcl)"
	echo ""
	echo "Found definition $(red_bold $name):"
	packer_build $name

done

for image in $(dangling_images); do
	incus image --quiet delete "${image}"
done
