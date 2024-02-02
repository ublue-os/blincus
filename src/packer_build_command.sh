name=${args[name]}

# make sure we have the packer plugin
plugin

# make sure the templates are personalized
personalize

# build the packer image
packer_build $name

for image in $(dangling_images); do
	incus image --quiet delete "${image}"
done
