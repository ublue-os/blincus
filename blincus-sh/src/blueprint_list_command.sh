comp=${args[--completions]}

cfgdir=$(dirname "${CONFIG_FILE}")

template_path="${cfgdir}/templates"

tmplts=$(cat "${cfgdir}"/config.ini | grep "^\[" | awk -F'[][]' '{print $2}')
for t in ${tmplts}; do
	echo "$(blue $t):"
	desc=$(config_get "${t}.description")
	if [ -z "$desc" ]; then
		desc="[no description]"
	fi
	echo "Description: ${desc}"
	imagename=$(config_get "$t".image)
	if [ -z "$imagename" ]; then
		imagename="(default)"
	fi
	echo "Image: ${imagename}"
	echo ""
done
#config_keys
