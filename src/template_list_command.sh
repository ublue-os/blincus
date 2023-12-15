comp=${args[--completions]}

cfgdir=$(dirname "${CONFIG_FILE}")

template_path="${cfgdir}/templates"


if [[  $comp ]]; then
    templates=()
    for file in $template_path/*.config.yaml; do
        name="$(basename "${file}" .config.yaml)"
        templates+=( $name )
    done
    echo ${templates[@]}
    return
fi


for file in $template_path/*.config.yaml; do
    name="$(basename "${file}" .config.yaml)"
	echo "$(blue_bold $name)"
    echo "  $(grep "description" ${file})"

done