# Nix-settings

`nix flake` + `home-manager` + `nix-darwin` で、WSL2 Debian / Linux / Apple Silicon macOS をそろえるための設定リポジトリです。

このリポジトリを使うと、shell、CLI ツール、Neovim、Node.js 周りをまとめて Nix で入れられます。普段の開発環境に加えて、`gh` も入るので GitHub 上の branch / PR 作業にもそのまま使えます。

## まず知っておくこと

- WSL2 用の設定は `homeConfigurations.wsl`
- 普通の Linux 用の設定は `homeConfigurations.linux`
- macOS 用の設定は `darwinConfigurations.mac`
- `bootstrap` と `just switch-*` は `--impure` で動き、今ログインしているユーザー名とホームディレクトリを自動で使います
- 既存の `~/.bashrc` や `~/.zshrc` などがあれば、初回適用時に `*.pre-hm` という名前で退避されます
- macOS は Apple Silicon 前提です

## WSL の人へ

### 1. WSL2 の Debian を開く

まだ入れていない場合は、Windows 側で WSL2 と Debian を用意してから Debian のターミナルを開きます。最初は Debian に入った直後の素の bash のままで大丈夫です。

### 2. Git を使える状態にする

Debian を入れたばかりで `git` がない場合は先に入れます。

```bash
sudo apt-get update
sudo apt-get install -y git
```

### 3. このリポジトリを clone する

```bash
cd ~
git clone git@github.com:kyanagis/Nix-settings.git settings
cd settings
```

### 4. bootstrap を実行する

```bash
./bootstrap/linux.sh
```

このスクリプトは WSL を自動検出して、`wsl` 用の設定を適用します。

### 5. ターミナルを開き直す

初回適用後は、新しいターミナルを開き直すのが一番安全です。

### 6. 動作確認をする

```bash
zsh --version
nvim --version
node --version
npm --version
home-manager --version
gh --version
```

### 7. GitHub CLI を使うならログインする

```bash
gh auth login
```

## macOS の人へ

### 1. ターミナルを開く

Apple Silicon の macOS を前提にしています。

### 2. このリポジトリを clone する

```bash
cd ~
git clone git@github.com:kyanagis/Nix-settings.git settings
cd settings
```

### 3. bootstrap を実行する

```bash
./bootstrap/darwin.sh
```

必要なら Xcode Command Line Tools のインストールが始まります。

### 4. ターミナルを開き直す

`darwin-rebuild` の反映後は、新しいターミナルを開き直してください。

### 5. 動作確認をする

```bash
zsh --version
nvim --version
node --version
npm --version
darwin-rebuild --version
gh --version
```

### 6. GitHub CLI を使うならログインする

```bash
gh auth login
```

## よく使うコマンド

```bash
just check
just update
just switch-wsl
just switch-linux
just switch-mac
```

手動で実行する場合:

```bash
home-manager switch --impure --flake path:.#wsl
home-manager switch --impure --flake path:.#linux
darwin-rebuild switch --impure --flake path:.#mac
```

## この設定で入るもの

- `zsh`, `git`, `tmux`, `direnv`, `fzf`
- `neovim` と LSP / 補完 / Telescope
- `node`, `npm`, `npx`, `pnpm`, `yarn`
- `gh` と `git-lfs`
- 開発用 CLI とセキュリティ調査向けの基本ツール
- macOS では GNU userland

## 注意

- `tcpdump` / `tshark` は入りますが、権限や capability がない状態ではキャプチャに失敗することがあります
- GUI アプリや Homebrew 連携は含めていません
