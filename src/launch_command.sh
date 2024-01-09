
nomount=${args[--no-mount]}
cfgdir=$(dirname "${CONFIG_FILE}")
name=${args[name]}
template=${args[--template]}
persist=${args[--persist]}

image=$(config_get ${template}.image)

config="${cfgdir}/templates/${template}"
echo "Using $(blue ${template}) template"
incus init "${image}" "${args[name]}" < "${config}.config.yaml"

if [[ ! -z "${persist}" ]]; then
    echo "$(yellow_bold Persisting home directories for $name at $persist)"
    mkdir -p "$persist"
    incus config device add "${args[name]}" persistdir disk source="$persist" path=/home
fi

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
incus exec "${args[name]}" -- bash -c "command -v cloud-init && cloud-init status --wait || echo No cloud-init" 

## MOTD
TMPFILE=$(mktemp)
echo " * Blincus instance: $(red $name)" > $TMPFILE
echo " * Template: $(red $template)" >> $TMPFILE
echo " * Image: $(red $image)" >> $TMPFILE
echo " * Helper Scripts: $(red /opt/scripts)" >> $TMPFILE
echo " " >> $TMPFILE

incus file push $TMPFILE "$name"/etc/blincus
MOTDPROFILE=$(mktemp)
echo "cat /etc/blincus" > $MOTDPROFILE

incus file push $MOTDPROFILE "$name"/etc/profile.d/02-blincus.sh
guid=$(uuid)
echo "Blincus ID: $(yellow $guid)"
incus config set "$name"  user.blincusuid=$guid

prompt_create_profile "$guid" "$name"

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

