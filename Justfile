buildui:
    go build -trimpath -o blincusui

docs: 
    cd site && npm run dev

flatpak-vendor:
	go run github.com/dennwc/flatpak-go-mod@latest .

wipe:
    ./hack/empty-incus.sh

docker:
    docker build -f contrib/Dockerfile.blincusui . -t bketelsen/blincusui

docker-push: docker
    docker push bketelsen/blincusui

# create blincusui distrobox
distrobox:
    distrobox assemble create --replace --file contrib/blincusui.ini

# remove blincusui distrobox
distrobox-rm: 
    distrobox assemble rm --file contrib/blincusui.ini




# bash alias:
# alias bashly='docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly'