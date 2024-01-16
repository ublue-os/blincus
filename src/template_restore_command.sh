cfgdir=$(dirname "${CONFIG_FILE}")

template_path="${cfgdir}/templates"
packer_path="${cfgdir}/packer"

baseDir="$(prefix)/share/blincus"
templateDir="${baseDir}/templates"
packerDir="${baseDir}/packer"

echo ""
echo "$(green Installer base directory:) $baseDir"
echo ""
echo "$(blue Installer template directory:) $templateDir"
echo "$(blue User template directory:) $template_path"
echo ""
echo "$(red To restore a template copy the template from the installer directory to the user directory)"
echo ""
echo ""
echo "$(magenta Installer packer template directory:) $packerDir"
echo "$(magenta User packer template directory:) $packer_path"
echo ""
echo "$(red To restore a packer template copy the template from the installer directory to the user directory)"
