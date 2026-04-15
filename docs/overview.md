# Overview

## このガイドの目的

このファイルは、Nix をほぼ触ったことがない人が、このリポジトリを読むための地図です。

この repo では次のものをまとめて管理しています。

- shell
- CLI ツール
- Neovim
- Node.js 周り
- macOS の一部システム設定

ここで大事なのは、「その場で 1 個ずつ入れる」のではなく、「最終的にこういう環境にしたい」という宣言を repo に残すことです。

## Nix をかなりざっくり説明すると

Nix はパッケージマネージャでもあり、設定を再現しやすくする仕組みでもあります。

普段のパッケージ管理では、次のような流れになりがちです。

1. その場で `brew install ...` や `apt install ...` を打つ
2. 何を入れたかあとで忘れる
3. 新しい端末を作ると、また同じ作業を手でやる

Nix では、この逆をやります。

1. 必要なものを設定ファイルに書く
2. Nix がその設定どおりに環境を作る
3. 新しい端末でも同じ設定を適用できる

つまり、「コマンドで環境を変更する」のではなく、「設定を変更してから環境を作り直す」感覚に近いです。

## この repo で使っている主要なもの

### Nix

土台になるパッケージマネージャです。

### flakes

`flake.nix` と `flake.lock` を使って、依存関係と出力を管理する仕組みです。

この repo では flake を使うことで、次の点がわかりやすくなっています。

- どの `nixpkgs` を使っているか
- どの output があるか
- 更新結果が `flake.lock` に残る

### home-manager

ユーザー環境を管理するための仕組みです。

この repo では主に次のものを `home-manager` が担当します。

- `home.packages`
- shell 設定
- Git 設定
- Neovim 設定
- tmux 設定

Linux と WSL では、環境の反映は基本的に `home-manager switch` が中心です。

### nix-darwin

macOS 側のシステム設定を Nix で扱うための仕組みです。

この repo では macOS で次のものを担当します。

- デフォルト shell の設定
- システム全体のパッケージ
- Finder や Dock の一部設定
- その上に載る `home-manager`

macOS では `darwin-rebuild switch` が反映コマンドになります。

## この repo の見取り図

### [flake.nix](../flake.nix)

リポジトリの入口です。

ここでは主に次のことを定義しています。

- 使う入力
- Linux / WSL / macOS の output
- `homeConfigurations.wsl`
- `homeConfigurations.linux`
- `darwinConfigurations.mac`

初心者が最初にここで覚えるべきことは 1 つだけです。

`flake.nix` は「全体の配線図」であって、普段の CLI 追加を毎回ここに書く場所ではない、ということです。

### [modules/home/common.nix](../modules/home/common.nix)

普段もっとも触る可能性が高いファイルです。

ここには次のようなものがあります。

- `corePackages`
- `buildPackages`
- `languagePackages`
- `infraPackages`
- `dataPackages`
- `docsPackages`
- `securityPackages`
- `commonPackages`
- `linuxPackages`
- `darwinPackages`
- shell aliases
- Git 設定
- Neovim 設定
- tmux 設定

CLI ツールを追加したい場合、多くはこのファイルを編集します。
実際には `commonPackages` は複数のカテゴリ list をまとめたものなので、追加先は「どのカテゴリに属するか」で決めると管理しやすいです。

### [modules/home/profiles/darwin.nix](../modules/home/profiles/darwin.nix)
### [modules/home/profiles/linux.nix](../modules/home/profiles/linux.nix)
### [modules/home/profiles/wsl.nix](../modules/home/profiles/wsl.nix)

profile ごとの入口です。

今の構成では、`darwin.nix` / `linux.nix` / `wsl.nix` は薄いファイルで、共通設定を `common.nix` から読み込む形になっています。

今後「WSL だけこの設定を足したい」「macOS だけ別の設定を持ちたい」となった場合は、この profile ファイルを起点に広げていきます。

### [modules/darwin/system.nix](../modules/darwin/system.nix)

macOS のシステム寄りの設定を書く場所です。

ここは「普段使う CLI の追加先」というより、次のようなものを書く場所です。

- macOS の shell
- `environment.systemPackages`
- Finder / Dock などの defaults
- primary user

CLI を追加したいだけなら、まずは `modules/home/common.nix` を見る方が自然です。

### [bootstrap/linux.sh](../bootstrap/linux.sh)
### [bootstrap/darwin.sh](../bootstrap/darwin.sh)

新しい端末を最初に立ち上げるためのスクリプトです。

やっていることは大まかに次のとおりです。

1. 必要な前提を入れる
2. Nix を入れる
3. flakes を有効にする
4. この repo の設定を反映する

### [justfile](../justfile)

日常で使う短いコマンド集です。

`nix` や `darwin-rebuild` を毎回長く打たなくて済むように、よく使う操作を `just` にまとめています。

## この repo の動き方

### Linux / WSL

Linux 系では `home-manager` が中心です。

初回は `./bootstrap/linux.sh` を実行し、その後は必要に応じて次を使います。

- `just build-linux`
- `just build-wsl`
- `just switch-linux`
- `just switch-wsl`

WSL では bootstrap スクリプトが自動で `wsl` profile を選びます。

### macOS

macOS では `nix-darwin` の上に `home-manager` が載る形です。

初回は `./bootstrap/darwin.sh` を実行し、その後は主に次を使います。

- `just build-mac`
- `just switch-mac`

## 初心者が最初に覚えると楽な考え方

### 1. パッケージを入れるときは repo を編集する

`brew install ...` を打つ代わりに、Nix の設定ファイルを編集します。

### 2. まず `build`、問題なければ `switch`

いきなり反映するのが不安なら、まず build して評価だけ通るか確認します。

### 3. `flake.lock` が更新結果を持つ

依存を更新したときに変わるのは、主に `flake.lock` です。

「今どの upstream を使っているか」は lock file を見ればわかります。

### 4. 迷ったら CLI は `common.nix` を見る

最初の迷子ポイントは「どこに書くのか」です。

この repo では、普段使う CLI はたいてい `modules/home/common.nix` に書きます。

## よくある誤解

### `flake.nix` に全部書くのでは

違います。

`flake.nix` は「どう組み立てるか」の定義です。
普段のパッケージ追加は `modules/home/common.nix` の方が中心です。

### Nix を使うと毎回ゼロからインストールし直すのでは

そういうわけではありません。

Nix は store を使って管理するので、必要なものだけを組み合わせて環境を切り替えます。

### macOS でも Linux と同じコマンドを使うのでは

完全には同じではありません。

Linux / WSL は `home-manager`、macOS は `darwin-rebuild` が中心です。
この差は `justfile` が吸収してくれるので、普段は `just switch-mac` のように覚えるのが楽です。
