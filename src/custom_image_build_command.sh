
cfgdir=$(dirname "${CONFIG_FILE}")
name=${args[name]}
scriptdir=${args[--scripts]}
sourcetemplate=${args[--template]}

recipe="${cfgdir}/build/${name}.yaml"

# ensure distrobuilder is installed
if ! command -v distrobuilder >/dev/null; then
    echo "$(red distrobuilder) is not installed, or is not in your PATH. Please install it and try again."
    exit 1
fi

if ! command -v debootstrap >/dev/null; then
    echo "$(yellow debootstrap) is not installed, or is not in your PATH. Many recipes require it."
fi
# create build directory
builddir="${cfgdir}/build/${name}"
mkdir -p "${builddir}"

# ensure recipe exists
if [ ! -e "${recipe}" ]; then
    echo "Build recipe $(red ${recipe}) does not exist"
    exit 1
fi

echo "Using $(blue ${recipe}) recipe"

sudo distrobuilder build-incus "${recipe}" ${builddir}

# now import it
echo "Importing image"
sudo incus image import "${builddir}/incus.tar.xz" "${builddir}/rootfs.squashfs" builder=blincus --alias "builder-${name}"

echo "Image $(blue builder-${name}) imported"

