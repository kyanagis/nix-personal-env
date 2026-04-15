set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
  @just --list

check:
  nix flake check path:.

update:
  nix flake update

switch-wsl:
  home-manager switch --impure --flake path:.#wsl

switch-linux:
  home-manager switch --impure --flake path:.#linux

switch-mac:
  sudo HOME=/var/root darwin-rebuild switch --impure --flake path:.#mac

build-wsl:
  home-manager build --impure --flake path:.#wsl

build-linux:
  home-manager build --impure --flake path:.#linux

build-mac:
  darwin-rebuild build --impure --flake path:.#mac
