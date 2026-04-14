#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="linux"

if grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
  target="wsl"
fi

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y curl git xz-utils ca-certificates
fi

if ! command -v nix >/dev/null 2>&1; then
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  # shellcheck disable=SC1090,SC1091
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

mkdir -p "$HOME/.config/nix"

if ! grep -Eq '^experimental-features\s*=.*flakes' "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  printf '\nexperimental-features = nix-command flakes\n' >> "$HOME/.config/nix/nix.conf"
fi

nix run github:nix-community/home-manager/master -- switch -b pre-hm --impure --flake "path:${repo_root}#${target}"
