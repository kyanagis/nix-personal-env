# Nix bootstrap guide

このリポジトリは `nix-channel` ではなく `flake.lock` を前提に管理します。新しい端末では、まずこのドキュメントどおりに bootstrap を実行し、その後は `just` か `home-manager` / `darwin-rebuild` を使って更新します。

## 先に知っておくこと

- WSL2 Debian は `homeConfigurations.wsl`
- ふつうの Linux は `homeConfigurations.linux`
- Apple Silicon macOS は `darwinConfigurations.mac`
- Linux 側の bootstrap は WSL かどうかを自動判定します
- 初回適用時に既存の shell 設定が見つかった場合は `*.pre-hm` として退避します

## WSL2 Debian / Linux

### 1. 最低限のコマンドを入れる

Debian / Ubuntu 系で `git` がまだない場合:

```bash
sudo apt-get update
sudo apt-get install -y git
```

### 2. リポジトリを clone する

```bash
cd ~
git clone git@github.com:kyanagis/Nix-settings.git settings
cd settings
```

### 3. bootstrap を実行する

```bash
./bootstrap/linux.sh
```

WSL2 上では自動で `.#wsl`、通常 Linux では `.#linux` を適用します。

### 4. 新しいターミナルを開く

初回は shell や PATH の反映のため、いったんターミナルを開き直すのが安全です。

### 5. 確認する

```bash
zsh --version
nvim --version
node --version
npm --version
home-manager --version
gh --version
```

## Apple Silicon macOS

### 1. リポジトリを clone する

```bash
cd ~
git clone git@github.com:kyanagis/Nix-settings.git settings
cd settings
```

### 2. bootstrap を実行する

```bash
./bootstrap/darwin.sh
```

必要なら Xcode Command Line Tools のインストールが始まります。

### 3. 新しいターミナルを開く

`darwin-rebuild` の反映後は、新しいターミナルを開き直します。

### 4. 確認する

```bash
zsh --version
nvim --version
node --version
npm --version
darwin-rebuild --version
gh --version
```

## 日常的によく使うコマンド

```bash
just check
just update
just switch-wsl
just switch-linux
just switch-mac
```

## 手動コマンド

```bash
home-manager switch --impure --flake path:.#wsl
home-manager switch --impure --flake path:.#linux
darwin-rebuild switch --impure --flake path:.#mac
```

## 検証

```bash
nix flake check path:.
home-manager build --impure --flake path:.#wsl
home-manager build --impure --flake path:.#linux
darwin-rebuild build --impure --flake path:.#mac
```

## GitHub CLI を使う場合

この設定では `gh` も入るので、PR 作成までこの環境で完結できます。

```bash
gh auth login
gh auth status
```
