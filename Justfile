lint:
    podman run --rm -v "$PWD:/mnt" -w /mnt docker://koalaman/shellcheck:stable blincus install uninstall

format:
    podman run --rm -v "$PWD:/mnt" -w /mnt docker://mvdan/shfmt:v3 -w blincus install uninstall

install:
    ./install

uninstall:
    ./uninstall

wipe:
    ./empty-incus.sh
