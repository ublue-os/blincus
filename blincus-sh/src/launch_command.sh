nomount=${args[--no - mount]}
cfgdir=$(dirname "${CONFIG_FILE}")
name=${args[name]}
blueprint=${args[--blueprint]}
# vm=${args[--vm]}
# vmflag=""
sizeflag=""
workspace=${args[--workspace]}
resolvedworkspace=""

if [[ ! -z "${workspace}" ]]; then
	resolvedworkspace=$(readlink -f "${workspace}")
fi

# set vm flag and size if specified
# if [[ ! -z "${vm}" ]]; then
# 	vmflag="--vm"
# 	sizeflag="--type t3.${vm}"
# fi

# profilelist=$(config_get "$blueprint".profiles)
# if [ -z "$profilelist" ]; then
# 	if [[ ! -z "${vm}" ]]; then
# 		profilelist=$(config_get default_vm_profiles)
# 	else
# 		profilelist=$(config_get default_container_profiles)
# 	fi
# fi

profilelist=$(get_profile)

# todo: extract this out if I can return an array properly
OLD_IFS=$IFS
IFS=,
read line <<<$profilelist
profiles=($line)
IFS=${OLD_IFS}

image=$(image $blueprint$vmflag)
scripts=$(scripts $blueprint$vmflag)
cloudinit=$(cloud $blueprint$vmflag)
mounts=$(home_mounts $blueprint$vmflag)

echo "Using $(blue ${blueprint}) blueprint"
incus init --quiet "${image}" "${args[name]}"

for each in "${profiles[@]}"; do
	exists=$(blincus_profile_exists "${each##*( )}")
	if [[ $exists -eq 0 ]]; then
		echo "$(red_bold Profile "${each##*( )}" is missing!)"
		exit 1
	fi
done

# Add profiles specified by blueprint
for each in "${profiles[@]}"; do
	incus profile --quiet add "${args[name]}" "${each##*( )}"
done

# add cloud-init profile
# TODO : skip if "none"

# if [ ! "$cloudinit" = "none" ]; then
# 	echo "Using $(blue $cloudinit) cloud-init profile"

# 	# ensure profile exists. do this all at once earlier? -- before init to save pain
# 	exists=$(blincus_profile_exists $cloudinit)
# 	if [[ $exists -eq 0 ]]; then
# 		echo "$(red_bold Profile "${cloudinit}" is missing!)"
# 		exit 1
# 	fi

# 	incus profile --quiet add "${args[name]}" "${cloudinit}"
# fi

# if [[ "${vm}" ]]; then
# 	incus config --quiet device add "${args[name]}" cloud disk source=cloud-init:config
# fi

echo "$(yellow_bold Starting instance $name)"
## MOTD
TMPFILE=$(mktemp)
echo " * Blincus instance: $(red $name)" >$TMPFILE
echo " * Template: $(red $blueprint)" >>$TMPFILE
echo " * Image: $(red $image)" >>$TMPFILE
echo " * Host Mounts: $(red Host) <-> $(blue Instance)" >>$TMPFILE

# # TODO - don't mount if scriptdir doesn't exist
# scripts=$(config_get "$blueprint".scripts)
# if [ -z "$scripts" ]; then
# 	scripts=$(config_get default_scripts)
# fi

# scriptdir="${cfgdir}/scripts/${scripts}"
# # mount scripts
# if [ -d "$scriptdir" ]; then
# 	echo "$(yellow Mounting scripts from $HOME/.blincus/scripts)"
# 	#incus file push -r -p "${scriptdir}"/* "$name"/opt/scripts
# 	incus config --quiet device add "${name}" scriptdir disk source="${scriptdir}" path=/opt/scripts
# 	echo "   - $(red ${scriptdir}) <-> $(blue /opt/scripts)" >>$TMPFILE

# fi

# now start it
incus start --quiet "${args[name]}"

# if [[ "${vm}" ]]; then
# 	echo "$(yellow Waiting for instance start...)"
# 	sleeptime=$(config_get "vm_sleep" 30)
# 	sleep $sleeptime
# fi
echo "$(yellow Waiting for cloud init...)"

# wait for cloud-init to create the user
# otherwise the home mount will prevent /etc/skel from being applied
incus exec "${args[name]}" -- command -v cloud-init && cloud-init status --wait

MOTDPROFILE=$(mktemp)
echo "cat /etc/blincus" >$MOTDPROFILE

incus file push $MOTDPROFILE "$name"/etc/profile.d/02-blincus.sh
guid=$(uuid)
echo "Blincus ID: $(yellow $guid)"
incus config set "$name" user.blincusuid=$guid

# mount $HOME at $HOME/host

if [[ ! $nomount ]]; then
	echo "$(yellow Mounting home directory at ~/host)"
	incus config --quiet device add "${args[name]}" myhomedir disk source="$HOME" path=/home/"${USER}"/host/
	echo "   - $(red $HOME) <-> $(blue /home/${USER}/host/)" >>$TMPFILE

fi

if [[ ! -z "${workspace}" ]]; then
	echo "$(yellow Mounting workspace directory)"
	dirname=$(basename "$resolvedworkspace")
	incus config --quiet device add "${args[name]}" workspace disk source="${resolvedworkspace}" path=/workspace/"${dirname}"
	echo "   - $(red $resolvedworkspace) <-> $(blue /workspace)" >>$TMPFILE
fi

OLD_IFS=$IFS
IFS=,
read line <<<$mounts
mountlist=($line)
IFS=${OLD_IFS}

for each in "${mountlist[@]}"; do
	if [ ! "${each}" = "none" ]; then
		echo "$(yellow Mounting directory ${each} at ~/${each})"
		incus config --quiet device add "${args[name]}" "${each##*( )}"mount disk source="$HOME"/"${each##*( )}" path=/home/"${USER}"/"${each##*( )}"
		echo "   - $(red ${each##*( )}) <-> $(blue /home/${USER}/${each##*( )})" >>$TMPFILE
	fi
done

# finish motd
echo " " >>$TMPFILE
incus file push $TMPFILE "$name"/etc/blincus

if [[ ! -z "${DISPLAY}" ]]; then
	echo "$(yellow Allowing X sharing:)"
	xhost +
fi
echo "$(green_bold Instance $name ready)"
echo "Run $(magenta_bold blincus shell $name) to enter"
