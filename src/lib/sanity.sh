sanity() {
    local errors;

if ! grep -q 'root:1000:1' /etc/subgid; then 
 errors=1;
 echo "Error: 'root:1000:1' missing from /etc/subgid";
fi

if ! grep -q 'root:1000:1' /etc/subuid; then 
    errors=1;
    echo "Error: 'root:1000:1' missing from /etc/subuid";
fi

if ! groups $USER | grep -qw 'incus-admin' ; then
    errors=1;
    echo "Error: User does not belong to 'incus-admin' group.";
fi
if (( errors > 0 )); then
   echo "$(red Sanity check failed.)"
   echo "$(yellow See documentation at https://blincus.dev)"
   exit 1;
fi
}