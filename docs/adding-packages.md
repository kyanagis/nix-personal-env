# Adding Packages

## このファイルの目的

新しい package を入れたいときに、どこへ何を書けばいいかを説明します。

この repo では、初心者が最初に迷いやすいのが次の 2 点です。

- どのファイルを編集すればいいのか
- 追加したあと何を実行すればいいのか

このファイルでは、その 2 点に絞って整理します。

## まず最初に覚える結論

普段使う CLI を追加したいだけなら、まずは [modules/home/common.nix](../modules/home/common.nix) を編集します。

特に見るべき list は次の 3 つです。

- `commonPackages`
- `linuxPackages`
- `darwinPackages`

ただし実際の `commonPackages` は、用途ごとの list をまとめて作っています。

- `corePackages`
- `buildPackages`
- `languagePackages`
- `infraPackages`
- `dataPackages`
- `docsPackages`
- `securityPackages`

## どこに書くべきか

### `commonPackages`

Linux / WSL / macOS の全部で使いたい package を入れる場所です。

今の repo では `commonPackages` に直接 1 個ずつ並べるのではなく、用途別 category list に追加して最後にまとめています。
迷ったらまず「その package はどのカテゴリか」を考えると整理しやすいです。

例:

- `jq`
- `fd`
- `gh`
- `tree`

判断基準は単純です。

「この CLI はどの端末でも使いたいか」です。

### `linuxPackages`

Linux と WSL にだけ必要な package を入れる場所です。

例:

- `gdb`
- `strace`
- `patchelf`
- `tcpdump`

Linux 向けの解析ツールや、macOS では不要なものをここに置きます。

### `darwinPackages`

macOS にだけ必要な package を入れる場所です。

例:

- `lldb`
- `coreutils`
- `findutils`
- `iproute2mac`

macOS 固有の補助 CLI や GNU userland 系をここに置きます。

### `modules/darwin/system.nix`

これは「CLI を追加するいつもの場所」ではありません。

ここには次のような、macOS のシステム寄り設定を書きます。

- `environment.systemPackages`
- `programs.zsh.enable`
- `users.users.<name>`
- Finder / Dock defaults

shell やシステム設定を変えたいときはこちらを触ります。

### `flake.nix`

初心者が package 追加のたびに触る場所ではありません。

`flake.nix` は次の役割を持っています。

- input の定義
- output の定義
- Linux / WSL / macOS の配線

普段の package 追加で `flake.nix` を触る必要は、ほとんどありません。

## package 名をどう探すか

### 方法 1. ブラウザで探す

一番わかりやすいのは `search.nixos.org/packages` で探す方法です。

見つけるときのポイントは次のとおりです。

- コマンド名と package attribute 名は一致しないことがある
- `node` のように実際のコマンド名と Nix 側の名前が違うことがある
- 迷ったら package attribute 名を設定ファイルに書く

### 方法 2. `nix search` を使う

bootstrap 後なら、次のように検索できます。

```bash
nix search nixpkgs <keyword>
```

例:

```bash
nix search nixpkgs ripgrep
nix search nixpkgs pandoc
nix search nixpkgs go
```

## 追加の実際の手順

ここでは例として、「全 OS で `httpie` を使いたい」と仮定して説明します。

### 1. 追加先を決める

全 OS で使いたいなら `commonPackages` です。

macOS だけなら `darwinPackages`、Linux / WSL だけなら `linuxPackages` を使います。

### 2. [modules/home/common.nix](../modules/home/common.nix) を編集する

イメージ:

```nix
  commonPackages = with pkgs; [
    age
    bash-language-server
    bat
    bind
    binutils
    binwalk
    btop
    cmake
    curl
    fd
    gh
    httpie
    jq
  ];
```

Nix では、ここに package attribute を並べていきます。

### 3. まず check する

```bash
just check
```

この段階では「構文や配線が壊れていないか」を見ます。

### 4. 対象 OS で build する

macOS なら:

```bash
just build-mac
```

Linux なら:

```bash
just build-linux
```

WSL なら:

```bash
just build-wsl
```

### 5. 問題なければ switch する

macOS なら:

```bash
just switch-mac
```

### 6. 実際にコマンドを確認する

```bash
command -v http
http --version
```

## 追加後にどのコマンドを打つべきか

最小構成なら次で十分です。

### macOS

```bash
just check
just build-mac
just switch-mac
```

### Linux

```bash
just check
just build-linux
just switch-linux
```

### WSL

```bash
just check
just build-wsl
just switch-wsl
```

## 削除したいとき

追加の逆です。

1. 対象 package を list から削除する
2. `just check` を実行する
3. `just build-*` を実行する
4. `just switch-*` を実行する

## ありがちなハマりどころ

### package 名ではなくコマンド名を書いてしまう

Nix では、設定ファイルに書くのは「package attribute 名」です。

たとえばコマンドが `node` でも、package 側は `nodejs_22` のような名前になっていることがあります。

検索結果をそのまま確認してから書くのが安全です。

### `flake.nix` に package を足そうとしてしまう

気持ちは自然ですが、この repo では多くの場合そこではありません。

普段の package 追加は `modules/home/common.nix` が中心です。

### いきなり `switch` してしまう

小さい変更ならそれでもよいですが、不安なら先に `build` を通す方が安心です。

### macOS で shell まで変えたいのに `common.nix` だけ触っている

CLI 追加なら `common.nix` でよいです。
一方で、ログイン shell や Finder の設定は `modules/darwin/system.nix` の担当です。

## どういうときに `common.nix` 以外を見るか

### shell alias や Git 設定を変えたい

[modules/home/common.nix](../modules/home/common.nix) を見ます。

### macOS の defaults を変えたい

[modules/darwin/system.nix](../modules/darwin/system.nix) を見ます。

### Linux と WSL で挙動を分けたい

[modules/home/profiles/linux.nix](../modules/home/profiles/linux.nix) と [modules/home/profiles/wsl.nix](../modules/home/profiles/wsl.nix) を見ます。

## 迷ったときの実践ルール

次のルールでだいたい外しません。

1. CLI 追加なら `modules/home/common.nix`
2. OS 固有なら `linuxPackages` か `darwinPackages`
3. システム設定なら `modules/darwin/system.nix`
4. 追加後は `check` → `build` → `switch`
