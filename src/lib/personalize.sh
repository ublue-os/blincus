personalize() {

cfgdir=$(dirname "${CONFIG_FILE}")

template_path="${cfgdir}/templates"

for file in $template_path/*.config.yaml; do

    fullname=$(getent passwd "$USER" | cut -d ':' -f 5)
    sed -i "s/BLINCUSUSER/$USER/g" "$file"
    sed -i "s/BLINCUSFULLNAME/$fullname/g" "$file"

# I don't know a better way to get the first file
    for i in "$HOME"/.ssh/id*.pub; do
        [ -f "$i" ] || break
        contents=$(cat "$i")
        sed -i "s|SSHKEY|$contents|g" "$file"
        break

    done
done
}