uuid() {
	uuid=$(cat /proc/sys/kernel/random/uuid)
	echo $uuid | sed 's/-//g'
}
