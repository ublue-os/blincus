prompt_create_profile() {
    # create a Prompt profile using dconf given the guid of the instance
    # $1 = guid
    # $2 = name

    # dconf read /org/gnome/Prompt/Profiles/d092b3519698570a3252762c658f7629/
    # /org/gnome/Prompt/Profiles/d092b3519698570a3252762c658f7629/custom-command 
    #   'blincus shell myubuntu'
    # /org/gnome/Prompt/Profiles/d092b3519698570a3252762c658f7629/label 
    #   'myubuntu'
    # /org/gnome/Prompt/Profiles/d092b3519698570a3252762c658f7629/login-shell 
    #   true
    # /org/gnome/Prompt/Profiles/d092b3519698570a3252762c658f7629/use-custom-command 
    #   true

    # if dconf doesn't exist, just return
    if ! command -v dconf >/dev/null; then
        return
    fi

    local guid=$1
    local name=$2

    local profile="/org/gnome/Prompt/Profiles/${guid}/"

    dconf write "${profile}custom-command" "'blincus shell ${name}'"
    dconf write "${profile}label" "'${name}'"
    dconf write "${profile}login-shell" "true"
    dconf write "${profile}use-custom-command" "true"

    prompt_add_profile "$guid"

}

prompt_add_profile(){
    # Read the current value of the array
    CURRENT_VALUE=$(dconf read /org/gnome/Prompt/profile-uuids)
    local guid=$1

    # remove the leading and trailing brackets
    CURRENT_VALUE=${CURRENT_VALUE:1:-1}

    # remove any spaces 
    CURRENT_VALUE=${CURRENT_VALUE// /}

    # split the string into an array
    IFS=',' read -r -a array <<< "$CURRENT_VALUE"

    # add the new value
    array+=("'$guid'")

    # join the array back into a string
    UPDATED_VALUE=$(printf "%s," "${array[@]}")

    # remove the trailing comma
    UPDATED_VALUE=${UPDATED_VALUE%?}

    # add the leading and trailing brackets
    UPDATED_VALUE="[$UPDATED_VALUE]"


    # Write the updated array back to dconf
    dconf write /org/gnome/Prompt/profile-uuids "$UPDATED_VALUE"

}

prompt_reconcile() {
    # ensure that the prompt profiles for deleted instances are removed

    # if dconf doesn't exist, just return
    if ! command -v dconf >/dev/null; then
        return
    fi

    # Read the current value of the array
    CURRENT_VALUE=$(dconf read /org/gnome/Prompt/profile-uuids)

    # remove the leading and trailing brackets
    CURRENT_VALUE=${CURRENT_VALUE:1:-1}

    # remove any spaces
    CURRENT_VALUE=${CURRENT_VALUE// /}

    # split the string into an array
    IFS=',' read -r -a array <<< "$CURRENT_VALUE"

    # loop through the array and remove any that don't exist
    for i in "${!array[@]}"; do
        guid=${array[i]}

        # remove single quotes from guid

        guid=${guid//\'/}

        #echo "Checking profile for $(red $guid)"
        local profile="/org/gnome/Prompt/Profiles/${guid}/"

        custom_shell=$(dconf read "${profile}custom-command")

        if [[ $custom_shell == *"blincus"* ]]; then
            #echo "Profile $(red $guid) is a Blincus profile"
            #echo "Custom shell: $custom_shell"

            # check if the instance exists
            local name=$(dconf read "${profile}label")
            name=${name//\'/}
            #echo --"$name"--
            #echo "Profile $(red $guid) is for instance $(red $name)"
            if ! incus list | grep -qw "$name"; then
                #echo "Instance $(red $name) does not exist. Removing profile $(red $guid)"
                # remove the profile
                dconf reset -f "${profile}"
                # remove the guid from the array
                unset 'array[i]'
                    # join the array back into a string
                UPDATED_VALUE=$(printf "%s," "${array[@]}")

                # remove the trailing comma
                UPDATED_VALUE=${UPDATED_VALUE%?}

                # add the leading and trailing brackets
                UPDATED_VALUE="[$UPDATED_VALUE]"

                #echo "UPDATED_VALUE: $UPDATED_VALUE"

                # Write the updated array back to dconf
                dconf write /org/gnome/Prompt/profile-uuids "$UPDATED_VALUE"
            fi

        fi

    done

    for image in $(blincus_instances); do
            local iprofile="/org/gnome/Prompt/Profiles/${image}/"
            icustom_shell=$(dconf read "${iprofile}custom-command")
            if [ -z "$icustom_shell" ]
            then        
                prompt_create_profile "$image" "$(blincus_instance_name "$image")"
            fi

    done


}