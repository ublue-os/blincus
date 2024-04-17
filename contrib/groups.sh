#!/bin/env bash
incus_socket="/var/lib/incus/unix.socket"

if [ -e "${incus_socket}" ]; then
	printf "distrobox: Confirming incus socket group mapping...\n"
	# get the group name and GID for the incus socket
	socket_group=$(stat -c '%G' -t "${incus_socket}")
	socket_gid=$(stat -c '%g' -t "${incus_socket}")

	# is there already a known group permission on the socket?
	if [ -z "${socket_group}" ]; then
		# if `stat` isn't present, we'll end up here
		printf "Warning: Unable to get permissions assigned to Incus socket"
	elif [ "${socket_group}" == "incus-admin" ]; then
		printf "Incus socket group already mapped."
	elif [ "${socket_group}" != "UNKNOWN" ]; then
		printf "Warning: Incus socket already has incorrect known group %s\n" "${socket_group}"
	elif [ -z "${socket_gid}" ]; then
		echo "Warning: Unable to get GID of Incus socket group"
	else
		# incus-admin group isn't known by the system, map the GID to the 'incus-admin' name
		if ! groupadd --gid ${socket_gid} incus-admin; then
			# `groupadd` isn't present, so add it manually
			printf "%s:x:%s:" "incus-admin" "${socket_gid}" >> /etc/group
		fi
	fi
fi