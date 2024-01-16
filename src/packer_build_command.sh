name=${args[name]}

# make sure we have the packer plugin
plugin

# make sure the templates are personalized
personalize

# build the packer image
packer_build $name