
generate:
    docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly generate
    docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly render templates/markdown site/src/content/docs/cli

install: generate
    ./install

build: generate
    docker build -t bketelsen/blincus:latest .
    docker push bketelsen/blincus:latest