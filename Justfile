
generate:
    docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly generate --upgrade
    docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly render templates/markdown site/src/content/docs/cli
    cp ./completions.bash completions/blincus
install: generate
    ./install

build: generate
    docker build -t bketelsen/blincus:latest .
    docker push bketelsen/blincus:latest

docs: generate
    distrobox enter universal

uninstall:
    ./uninstall
    