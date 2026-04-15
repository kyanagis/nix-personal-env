# Package Inventory

## このファイルの目的

このファイルは、「この repo を適用すると最終的に何が入るのか」を一覧で確認するためのものです。

README には概要だけを書き、完全な一覧はここに寄せています。

## 読み方

- `commonPackages`: Linux / WSL / macOS で共通して入る `home.packages`
- `linuxPackages`: Linux / WSL にだけ入る package
- `darwinPackages`: macOS にだけ入る `home.packages`
- `programs.*`: Home Manager で有効化している program
- `environment.systemPackages`: macOS で system level に入る package

## 共通 package

以下は [modules/home/common.nix](../modules/home/common.nix) の `commonPackages` に入るものです。

### Core

- `coreutils`
- `findutils`
- `gnugrep`
- `gnused`
- `gawk`
- `gnutar`
- `bash-language-server`
- `bat`
- `bind`
- `btop`
- `curl`
- `eza`
- `fd`
- `file`
- `gh`
- `git`
- `git-lfs`
- `gnupg`
- `jq`
- `jqp`
- `just`
- `libressl.nc`
- `ripgrep`
- `ripgrep-all`
- `rsync`
- `socat`
- `tree`
- `unzip`
- `wget`
- `whois`
- `yq`
- `zip`
- `zstd`

### Build / Toolchain / Nix

- `binutils`
- `buf`
- `clang-tools`
- `cmake`
- `deadnix`
- `delve`
- `gcc`
- `gnumake`
- `go`
- `gopls`
- `grpcurl`
- `lua-language-server`
- `nix-output-monitor`
- `nix-tree`
- `nil`
- `nixd`
- `nixpkgs-fmt`
- `pkg-config`
- `protobuf`
- `rust-analyzer`
- `rustc`
- `cargo`
- `shellcheck`
- `shfmt`
- `statix`
- `stylua`
- `taplo`
- `opentofu`
- `terraform-ls`

### Language / Runtime

- `nodejs_22`
- `pipx`
- `pixi`
- `pnpm`
- `pre-commit`
- `pyright`
- `python3`
- `ruff`
- `typescript-language-server`
- `uv`
- `vscode-langservers-extracted`
- `yarn`

### Infra / Cloud / Container

- `actionlint`
- `ansible`
- `ansible-lint`
- `awscli2`
- `docker-client`
- `docker-compose`
- `hadolint`
- `helmfile`
- `k9s`
- `kubectl`
- `kubectx`
- `kubernetes-helm`
- `kustomize`
- `stern`
- `trivy`

### Data / DB / API

- `httpie`
- `mariadb.client`
- `openssl`
- `pgcli`
- `postgresql`
- `sqlite`

### Docs / Writing

- `graphviz`
- `markdownlint-cli`
- `marksman`
- `pandoc`
- `yamllint`

### Security / Analysis / Network

- `age`
- `binwalk`
- `mtr`
- `nmap`
- `radare2`
- `sops`
- `tcpdump`
- `usbutils`
- `wireshark-cli`

## Linux / WSL 専用 package

以下は `linuxPackages` です。

- `gdb`
- `ltrace`
- `patchelf`
- `strace`

## macOS 専用 package

以下は `darwinPackages` です。

- `iproute2mac`
- `lldb`

## Home Manager で有効化している program

以下は「`home.packages` に列挙している package」とは別に、Home Manager の `programs.*` や `services.*` で有効化しているものです。

### Shell / Navigation

- `home-manager`
- `bash`
- `zsh`
- `direnv`
- `nix-direnv`
- `fzf`
- `zoxide`

### Git / Diff

- `git`
- `delta`

### Editor / Terminal

- `neovim`
- `tmux`

### SSH

- `ssh`
- `ssh-agent`

## Neovim plugin

`programs.neovim.plugins` で有効化している plugin は次のとおりです。

- `nvim-lspconfig`
- `nvim-cmp`
- `cmp-nvim-lsp`
- `cmp-path`
- `nvim-autopairs`
- `gruvbox-nvim`

## macOS の system package

以下は [modules/darwin/system.nix](../modules/darwin/system.nix) の `environment.systemPackages` に入るものです。

- `coreutils`
- `findutils`
- `gnugrep`
- `gnused`
- `gawk`
- `gnutar`

## macOS の system 設定

package ではありませんが、`nix-darwin` で次の設定も入ります。

- login shell を `zsh` に設定
- `bash` と `zsh` を `environment.shells` に登録
- `nix-command` と `flakes` を有効化
- `nix.optimise.automatic = true`
- Dock の自動非表示
- Finder の拡張子表示
- Finder の path bar / status bar 表示
- キーリピート設定

## Shell alias

package ではありませんが、共通 alias も入ります。

- `cat = bat --style=plain`
- `ccw = cc -Werror -Wall -Wextra`
- `la = eza -lah --all --group-directories-first`
- `ll = eza -lah --group-directories-first`
- `ls = eza --group-directories-first`

## Session variable

共通の session variable は次のとおりです。

- `COREPACK_ENABLE_AUTO_PIN=0`
- `DOTFILES_PROFILE`
- `EDITOR=nvim`
- `FZF_DEFAULT_COMMAND=fd --type f --hidden --follow --exclude .git`
- `MANPAGER=less -FR`
- `PAGER=less -FR`
- `VISUAL=nvim`

## 注意

- macOS では GNU userland を `home.packages` と `environment.systemPackages` の両方で使っています
- `programs.git.enable = true` と `home.packages` の `git` は役割が少し違います
- GUI アプリはこの repo には含めていません
- secret や SSH 鍵の実体はこの repo では管理していません
