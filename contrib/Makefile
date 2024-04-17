# This is just a Makefile to simplify running some of the commands mentioned in the README.

build:
	flatpak run org.flatpak.Builder --repo=repo --user --force-clean build-dir oldmeta/dev.brian.BlincusUI.json

install:
	flatpak run org.flatpak.Builder --repo=repo --user --install --force-clean build-dir oldmeta/dev.brian.BlincusUI.json


buildinstall:
	flatpak run org.flatpak.Builder --force-clean --user --install --install-deps-from=flathub --ccache --mirror-screenshots-url=https://dl.flathub.org/media/ --repo=repo builddir oldmeta/dev.brian.BlincusUI.json

run:
	flatpak run --user dev.brian.BlincusUI

flatpak-vendor:
	go run github.com/dennwc/flatpak-go-mod@latest .

flatpak-validate:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest dev.brian.BlincusUI.yml
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo repo
