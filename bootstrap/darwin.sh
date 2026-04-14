#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v xcode-select >/dev/null 2>&1 || ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
fi

if ! command -v nix >/dev/null 2>&1; then
  sh <(curl -L https://nixos.org/nix/install) --daemon
fi

if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  # shellcheck disable=SC1090,SC1091
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

mkdir -p "$HOME/.config/nix"

if ! grep -Eq '^experimental-features\s*=.*flakes' "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  printf '\nexperimental-features = nix-command flakes\n' >> "$HOME/.config/nix/nix.conf"
fi

nix run github:LnL7/nix-darwin/master#darwin-rebuild -- switch --impure --flake "path:${repo_root}#mac"
