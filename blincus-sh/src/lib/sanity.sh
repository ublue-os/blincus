sanity() {
	local errors

	if ! grep -q 'root:1000:1' /etc/subgid; then
		errors=1
		echo "Error: 'root:1000:1' missing from /etc/subgid"
		echo "To resolve run:"
		echo 'echo "root:1000:1" | sudo tee -a /etc/subuid /etc/subgid'
	fi

	if ! grep -q 'root:1000:1' /etc/subuid; then
		errors=1
		echo "Error: 'root:1000:1' missing from /etc/subuid"
		echo "To resolve run:"
		echo 'echo "root:1000:1" | sudo tee -a /etc/subuid /etc/subgid'
	fi

	if ! groups $USER | grep -qw 'incus-admin'; then
		errors=1
		echo "Error: User does not belong to 'incus-admin' group."
		echo "To resolve run:"
		echo 'sudo usermod -aG incus-admin $USER'
	fi
	if ((errors > 0)); then
		echo "$(red Sanity check failed.)"
		echo "$(yellow See documentation at https://blincus.dev)"
		exit 1
	fi
}

profiles() {
	cfgdir=$(dirname "${CONFIG_FILE}")
	done=$(config_get "profilescreated" "0")
	if [ $done -eq 1 ]; then
		return
	fi
	initpath="${cfgdir}/cloud-init"
	profilepath="${cfgdir}/profiles"

	shopt -s globstar
	for file in $initpath/*.yaml; do
		name="$(basename "${file}" .yaml)"
		exists=$(blincus_profile_exists "${name}")
		if [[ $exists -eq 0 ]]; then
			echo "$(red_bold Profile "${name}" is missing. Creating...)"
			incus profile --quiet create "${name}"
			# now personalize it
			personalize_file "${file}"
			incus profile --quiet edit "${name}" <"${file}"

		fi
	done

	for file in $profilepath/*.yaml; do
		name="$(basename "${file}" .yaml)"
		exists=$(blincus_profile_exists "${name}")
		if [[ $exists -eq 0 ]]; then
			echo "$(red_bold Profile "${name}" is missing. Creating...)"
			incus profile --quiet create "${name}"

			# now personalize it
			personalize_file "${file}"
			incus profile --quiet edit "${name}" <"${file}"

		fi
	done

	config_set "profilescreated" "1"

}
