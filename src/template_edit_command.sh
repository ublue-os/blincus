
cfgdir=$(dirname "${CONFIG_FILE}")

template_path="${cfgdir}/templates"
$EDITOR ${template_path}/${args[name]}.config.yaml