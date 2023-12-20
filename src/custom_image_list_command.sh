cfgdir=$(dirname "${CONFIG_FILE}")

recipedir="${cfgdir}/build/"

echo "$(red Custom) image build recipes:"
for t in ${recipedir}*.yaml; do
    template=$(basename "${t}" .yaml)
    echo "  $(blue $template)" "- ${t}"
done

echo "$(red Custom) images (built):"
for image in $(incus image list --format json | jq -r '.[] | select(.properties.builder == "blincus") | select(.aliases !=[]) | .aliases[0].name '); do
    echo "  $(blue $image)"
done

