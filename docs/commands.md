# Commands

## このファイルの目的

この repo で実際に使うコマンドを、「何のために打つのか」から説明します。

初心者がまず覚えるべきコマンドは多くありません。

- 初回セットアップは `./bootstrap/...`
- 普段の確認は `just check`
- 反映前の確認は `just build-*`
- 実際の反映は `just switch-*`
- upstream 更新は `just update`

## 初回セットアップ

### Linux / WSL

```bash
./bootstrap/linux.sh
```

このスクリプトは次をまとめてやります。

1. `curl`, `git`, `xz-utils`, `ca-certificates` を入れる
2. Nix を入れる
3. flakes を有効にする
4. WSL なら `wsl`、そうでなければ `linux` の設定を反映する

### macOS

```bash
./bootstrap/darwin.sh
```

このスクリプトは次をまとめてやります。

1. Xcode Command Line Tools を確認する
2. Nix を入れる
3. flakes を有効にする
4. `darwinConfigurations.mac` を反映する

## 日常でよく使うコマンド

### `just check`

```bash
just check
```

中身:

```bash
nix flake check path:.
```

何をするか:

- flake の定義が壊れていないかを見る
- outputs が評価できるかを見る
- CI で最低限見たい内容をローカルでも確認する

いつ使うか:

- 設定ファイルを編集した直後
- PR を出す前
- `flake.lock` 更新後

### `just build-linux`
### `just build-wsl`
### `just build-mac`

例:

```bash
just build-mac
```

何をするか:

- 設定をビルドする
- 実際には反映しない

このコマンドは「この設定で通るか」を見るための安全確認です。

初心者はまず次の流れで覚えると安心です。

1. ファイルを編集する
2. `just build-*` を打つ
3. 問題なければ `just switch-*` を打つ

### `just switch-linux`
### `just switch-wsl`
### `just switch-mac`

例:

```bash
just switch-mac
```

何をするか:

- build した設定を現在の環境へ反映する
- macOS では内部で `sudo` を使って system activation まで行う

build と違って、こちらは実際に shell 設定や package の見え方が変わります。

反映後は、新しいターミナルを開き直した方が安全なことがあります。

### `just update`

```bash
just update
```

中身:

```bash
nix flake update
```

何をするか:

- `flake.lock` を更新する
- `nixpkgs`, `home-manager`, `nix-darwin` などの参照先を新しくする

このコマンドは「パッケージを追加するコマンド」ではありません。
「この repo が参照している upstream のバージョンを上げるコマンド」です。

更新後は次をやるのがおすすめです。

1. `just check`
2. 対象 OS の `just build-*`
3. 問題なければ `just switch-*`

## 手で打つ本体コマンド

`just` を使わず、実際の本体コマンドを打つこともできます。

### Linux / WSL

```bash
home-manager build --impure --flake path:.#linux
home-manager switch --impure --flake path:.#linux
home-manager build --impure --flake path:.#wsl
home-manager switch --impure --flake path:.#wsl
```

### macOS

```bash
darwin-rebuild build --impure --flake path:.#mac
sudo HOME=/var/root darwin-rebuild switch --impure --flake path:.#mac
```

## `build` と `switch` の違い

### `build`

- 評価してビルドする
- 現在のログイン環境には反映しない
- 設定ミスの早期確認に向いている

### `switch`

- build した結果を現在の環境に反映する
- shell や PATH や package の見え方が変わる
- 実際の変更を有効にするコマンド

初心者向けには、次の覚え方で十分です。

- まず `build`
- 最後に `switch`

## `--impure` が付いている理由

この repo の `flake.nix` は、現在ログインしているユーザー名やホームディレクトリを環境変数から拾う作りになっています。

たとえば次の値です。

- `USER`
- `HOME`

`--impure` は、そのような外部環境の値を評価時に使うために付いています。

つまり、「この repo は誰の環境にもそのまま載せやすいように、ユーザー名を固定値ではなく実行時に拾っている」ということです。

## よく使う流れ

### 1. パッケージを追加した

```bash
just check
just build-mac
just switch-mac
```

Linux なら `build-linux` / `switch-linux`、WSL なら `build-wsl` / `switch-wsl` に読み替えます。

### 2. upstream を更新した

```bash
just update
just check
just build-mac
just switch-mac
```

### 3. まだ反映したくないが、壊れていないかだけ見たい

```bash
just build-mac
```

## ありがちな使い分け

### `just check` だけで十分なとき

- まだコードレビュー前の軽い確認
- flake の配線が壊れていないかだけ見たいとき

### `build-*` までやった方がいいとき

- 実際に package を追加した
- profile ごとの分岐に触った
- 反映前に安全確認したい

### `switch-*` までやるとき

- その端末で今すぐ設定を使いたい
- shell や package を本当に切り替えたい

## トラブル時に見る場所

### コマンドが見つからない

次を確認します。

1. 対象 package を正しい list に追加したか
2. `build-*` が成功しているか
3. `switch-*` を実行したか
4. ターミナルを開き直したか

### macOS で shell や PATH が変わらない

`darwin-rebuild switch` のあと、新しいターミナルを開き直すと解決することがあります。

### Linux / WSL で設定が反映されない

`home-manager switch --impure --flake path:.#linux` か `.#wsl` を直接打って、エラーをそのまま確認すると原因を追いやすいです。
