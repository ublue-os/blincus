root=${args[--root]}
nologin=${args[--no-login]}
container=${args[name]}
shelluser=${USER}
loginflag="--login"

if [[  $root ]]; then
    shelluser="root"
fi
if [[  $nologin ]]; then
    loginflag=""
fi


incus exec "$container" -- su ${loginflag} ${shelluser}
