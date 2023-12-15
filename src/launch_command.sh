
nomount=${args[--no-mount]}
cfgdir=$(dirname "${CONFIG_FILE}")
name=${args[name]}
template=${args[--template]}

image=$(config_get ${template}.image)

config="${cfgdir}/templates/${template}"
echo "Using $(blue ${template}) template"
incus init "${image}" "${args[name]}" < "${config}.config.yaml"


echo "$(yellow Starting instance $name)"
# add our useful scripts
# mount or copy scripts
scripts=$(config_get ${template}.scripts)
scriptdir="${cfgdir}/scripts/${scripts}"


incus file push -r -p "$scriptdir"/* "$name"/opt/scripts/

# now start it
incus start "${args[name]}"

echo "$(yellow Waiting for cloud init...)"

# wait for cloud-init to create the user
# otherwise the home mount will prevent /etc/skel from being applied
incus exec "${args[name]}" -- cloud-init status --wait

## TODO


# mount $HOME at $HOME/host

if [[ ! $nomount ]]; then
    echo "$(yellow Mounting home directory)"
    incus config device add "${args[name]}" myhomedir disk source="$HOME" path=/home/"${USER}"/host/
fi
if [[ ! -z "${DISPLAY}" ]]; then
    echo "$(yellow_bold Allowing X sharing:)"
    xhost +
fi
echo "$(green_bold Instance $name ready)"
echo "Run $(magenta_bold blincus shell $name) to enter"

