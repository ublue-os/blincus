root=${args[--root]}
nologin=${args[--no - login]}
container=${args[name]}
#shelluser=${USER}
loginflag="--login"

shelluser=$(incus exec "$container" -- awk -F ':' '$3==1000 {print $1}'  /etc/passwd)

if [[ $root ]]; then
	shelluser="root"
fi
if [[ $nologin ]]; then
	loginflag=""
fi
incus exec "$container" -- su ${loginflag} ${shelluser}
