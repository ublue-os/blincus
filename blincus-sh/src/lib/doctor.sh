has() {
    local found=0
    thing=$1
    if command -v $thing >/dev/null 2>&1; then
        found=1
    fi
    echo $found
}

has_container_engine() {

    printf "$(blue $'\t'- Container Engine)"

    has_docker=$(has docker)
    has_podman=$(has podman)
    if [ $has_docker -eq 1 ] || [ $has_podman -eq 1 ]; then
        echo "$(green ...found)"
    else
        echo "$(red ...not installed)"
        printf "$(red $'\t\t'Podman or Docker is required$'\n')"
    fi
}

has_distrobox() {
    printf "$(blue $'\t'- Distrobox)"

    has_distrobox=$(has distrobox)

    if [ $has_distrobox -eq 1 ]; then
        echo "$(green ...found)"
    else
        echo "$(red ...not installed)"
        printf "$(red $'\t\t'Distrobox is required$'\n')"

    fi
}

has_incus() {

    printf "$(blue $'\t'- Incus client)"

    has_incus=$(has incus)

    if [ $has_incus -eq 1 ]; then
        echo "$(green ...found)"
    else
        echo "$(red ...not found)"
        printf "$(red $'\t\t' Incus client is required$'\n')"

    fi
}
