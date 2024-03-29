cfgdir=$(dirname "${CONFIG_FILE}")
[[ -d "$cfgdir" ]] || mkdir -p "$cfgdir"
if ! test -f "${CONFIG_FILE:-}"; then
	echo "$(yellow_bold Config file does not exist. Creating it with defaults.)"
	echo "$(yellow_bold Disabling XAuth controls.)"
	write_defaults
	echo "--> Config file created at ${CONFIG_FILE}."
fi

if [ "$BLINCUS_SKIP_SANITY" != 1 ]; then
	sanity
fi

#personalize
profiles
