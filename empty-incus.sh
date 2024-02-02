#!/bin/sh -eu
if ! command -v jq >/dev/null 2>&1; then
    echo "This tool requires: jq"
    exit 1
fi

## Delete anything that's tied to a project
for project in $(incus query "/1.0/projects?recursion=1" | jq .[].name -r); do
    echo "==> Deleting all containers for project: ${project}"
    for container in $(incus query "/1.0/containers?recursion=1&project=${project}" | jq .[].name -r); do
        incus delete --project "${project}" -f "${container}"
    done

    echo "==> Deleting all images for project: ${project}"
    for image in $(incus query "/1.0/images?recursion=1&project=${project}" | jq .[].fingerprint -r); do
        incus image delete --project "${project}" "${image}"
    done
done

for project in $(incus query "/1.0/projects?recursion=1" | jq .[].name -r); do
    echo "==> Deleting all profiles for project: ${project}"
    for profile in $(incus query "/1.0/profiles?recursion=1&project=${project}" | jq .[].name -r); do
        if [ "${profile}" = "default" ]; then
            printf 'config: {}\ndevices: {}' | incus profile edit --project "${project}" default
            continue
        fi
        incus profile delete --project "${project}" "${profile}"
    done

    if [ "${project}" != "default" ]; then
        echo "==> Deleting project: ${project}"
        incus project delete "${project}"
    fi
done

