sanity() {
    local errors;
(grep 'root:1000:1' /etc/subgid) || errors=1;echo "Error: 'root:1000:1' missing from /etc/subgid";
(grep 'root:1000:1' /etc/subuid) || errors=1;echo "Error: 'root:1000:1' missing from /etc/subuid";
(groups $USER | grep -qw 'incus-admin') || errors=1;echo "Error: User does not belong to 'incus-admin' group.";
if [ "$errors" -eq "1" ]; then
   echo "$(red Sanity check failed.)"
   echo "$(yellow See documentation at https://blincus.dev)"
   exit 1;
fi
}