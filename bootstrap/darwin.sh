#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
nix_daemon_profile="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
user_nix_profile="$HOME/.nix-profile/etc/profile.d/nix.sh"

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "Run this script as your normal user, not with sudo."
  echo "It will invoke sudo only for the final nix-darwin activation step."
  exit 1
fi

if ! command -v xcode-select >/dev/null 2>&1 || ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
fi

if ! command -v nix >/dev/null 2>&1 && [ ! -f "$nix_daemon_profile" ] && [ ! -f "$user_nix_profile" ]; then
  sh <(curl -L https://nixos.org/nix/install) --daemon
fi

if [ -f "$nix_daemon_profile" ]; then
  # shellcheck disable=SC1090,SC1091
  . "$nix_daemon_profile"
elif [ -f "$user_nix_profile" ]; then
  # shellcheck disable=SC1090,SC1091
  . "$user_nix_profile"
else
  echo "Nix appears to be installed, but its profile script was not found."
  echo "Open a new terminal and try again."
  exit 1
fi

mkdir -p "$HOME/.config/nix"

if ! grep -Eq '^experimental-features\s*=.*flakes' "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  printf '\nexperimental-features = nix-command flakes\n' >> "$HOME/.config/nix/nix.conf"
fi

sudo HOME=/var/root nix --extra-experimental-features "nix-command flakes" \
  run github:LnL7/nix-darwin/master#darwin-rebuild -- \
  switch --impure --flake "path:${repo_root}#mac"
