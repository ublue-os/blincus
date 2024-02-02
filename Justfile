
generate: 
    docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly generate --upgrade
    docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly render templates/markdown site/src/content/docs/cli
    cp ./completions.bash completions/blincus

format:
    docker run --rm -u "$(id -u):$(id -g)" -v "$PWD:/mnt" -w /mnt mvdan/shfmt:v3 -w .

install: generate
    ./install

build: generate
    docker build -t bketelsen/blincus:latest .
    docker push bketelsen/blincus:latest

docbox: generate
    distrobox enter bluefin-cli

docs: 
    cd site && npm run dev

uninstall:
    ./uninstall

bashly +COMMANDS:
    docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/bashly {{COMMANDS}}

wipe:
    ./empty-incus.sh

sync:
    rsync -azvh `pwd` bjk@debian12.home.arpa:~/