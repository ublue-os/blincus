personalize() {

cfgdir=$(dirname "${CONFIG_FILE}")

template_path="${cfgdir}/templates"
packer_path="${cfgdir}/packer"

shopt -s globstar


for file in $template_path/*.config.yaml; do

    fullname=$(getent passwd "$USER" | cut -d ':' -f 5)
    sed -i "s/BLINCUSUSER/$USER/g" "$file"
    sed -i "s/BLINCUSFULLNAME/$fullname/g" "$file"

    # if we're running on WSL we need to remove the gecos line from the config
    # https://wsl.dev/wslblincus/
    if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ; then
        sed -i 's/gecos/#gecos/g' "$file"
    fi


# I don't know a better way to get the first file
    for i in "$HOME"/.ssh/id*.pub; do
        [ -f "$i" ] || break
        contents=$(cat "$i")
        sed -i "s|SSHKEY|$contents|g" "$file"
        break

    done
done

for file in $packer_path/* $packer_path/**/*; do

# if it's not a directory
if ! [ -d "$file" ]; then
    fullname=$(getent passwd "$USER" | cut -d ':' -f 5)
    sed -i "s/BLINCUSUSER/$USER/g" "$file"
    sed -i "s/BLINCUSFULLNAME/$fullname/g" "$file"

    # if we're running on WSL we need to remove the gecos line from the config
    # https://wsl.dev/wslblincus/
    if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ; then
        sed -i 's/gecos/#gecos/g' "$file"
    fi


# I don't know a better way to get the first file
    for i in "$HOME"/.ssh/id*.pub; do
        [ -f "$i" ] || break
        contents=$(cat "$i")
        sed -i "s|SSHKEY|$contents|g" "$file"
        break

    done
fi
done


}