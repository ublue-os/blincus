
cfgdir=$(dirname "${CONFIG_FILE}")

template_path="${cfgdir}/templates"

for file in $template_path/*.config.yaml; do
    name="$(basename "${file}" .config.yaml)"
	echo "$(blue_bold $name)"
    echo "  $(grep "description" ${file})"

done