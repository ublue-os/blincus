
cfgdir=$(dirname "${CONFIG_FILE}")
name=${args[name]}
scriptdir=${args[--scripts]}
sourcetemplate=${args[--template]}

recipe="${cfgdir}/build/${name}.yaml"


# ensure sourcetemplate exists
if [ ! -e "${cfgdir}/templates/${sourcetemplate}.config.yaml" ]; then
    echo "Source template $(red ${sourcetemplate}) does not exist"
    exit 1
fi

# ensure recipe exists
touch "${recipe}" 


# ensure scriptdir exists
if [ ! -e "${cfgdir}/scripts/${scriptdir}" ]; then
    echo "Script directory $(red ${scriptdir}) does not exist"
    exit 1
fi


# Create config values for this image
config_set "builder-${name}.image" "builder-${name}"
config_set "builder-${name}.scripts" "${scriptdir}"

# copy image template
cp "${cfgdir}/templates/${sourcetemplate}.config.yaml" "${cfgdir}/templates/builder-${name}.config.yaml"

echo "Created $(blue ${recipe}) recipe"
echo "Created $(blue ${cfgdir}/templates/builder-${name}.config.yaml) template"
echo "$(yellow Next Steps:)"
echo " * Edit $(blue ${recipe}) with a valid Distrobuilder recipe"
echo " * See examples in $(blue ${cfgdir}/build) for inspiration"
echo " * Run $(magenta_bold blincus custom-image build ${name}) to build the image"