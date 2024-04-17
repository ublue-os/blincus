cfgdir=$(dirname "${CONFIG_FILE}")

profile_path="${cfgdir}/profiles"
init_path="${cfgdir}/cloud-init"
baseDir="$(prefix)/share/blincus"
templateDir="${baseDir}/templates"
profileDir="${baseDir}/profiles"
initDir="${baseDir}/cloud-init"

echo ""
echo "$(red To restore original files, copy from the installer directory to the user directory)"
echo ""
echo "$(green Installer base directory:) $baseDir"
echo "$(green User base directory:) $cfgdir"

echo ""
echo "$(blue Installer profile directory:) $profileDir"
echo "$(blue User profile directory:) $profile_path"
echo ""
echo "$(blue Installer cloud-init directory:) $initDir"
echo "$(blue User cloud-init directory:) $init_path"
echo ""
