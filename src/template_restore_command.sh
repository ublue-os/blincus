cfgdir=$(dirname "${CONFIG_FILE}")

template_path="${cfgdir}/templates"

templateDir="$(prefix)/share/blincus/templates"
echo "$(blue Installer template directory:) $templateDir"
echo "$(blue User template directory:) $template_path"
echo ""
echo "$(red To restore a template copy the template from the installer directory to the user directory)"