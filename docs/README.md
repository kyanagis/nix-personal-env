# Docs

このディレクトリは、このリポジトリをこれから使う人向けのガイド置き場です。

最初に読む順番は次の 4 本がおすすめです。

1. [overview.md](overview.md)
2. [commands.md](commands.md)
3. [adding-packages.md](adding-packages.md)
4. [package-inventory.md](package-inventory.md)

## それぞれ何が書いてあるか

### [overview.md](overview.md)

Nix そのものの考え方と、このリポジトリの全体像を説明します。

- Nix とは何か
- flake とは何か
- `home-manager` と `nix-darwin` の役割
- この repo のファイル構成
- どのファイルを触れば何が変わるか

### [commands.md](commands.md)

このリポジトリで実際に使うコマンドを、初心者向けに説明します。

- 初回 bootstrap の流れ
- `just check`
- `just update`
- `just switch-*`
- `just build-*`
- `build` と `switch` の違い
- `--impure` が付いている理由

### [adding-packages.md](adding-packages.md)

新しいパッケージを入れたいときの実践手順です。

- どのファイルに書くべきか
- `commonPackages` と OS 別 packages の違い
- `flake.nix` に書くものと書かないもの
- 追加後の確認手順
- ありがちなハマりどころ

### [package-inventory.md](package-inventory.md)

今この repo から何が入るのかを、カテゴリごとに全部列挙した一覧です。

- `home.packages` の共通 package
- Linux 専用 package
- macOS 専用 package
- Home Manager で有効化している program
- Neovim plugin
- macOS の system package

## まず一言でいうと

この repo では、普段使う CLI や shell 設定を Nix で宣言的に管理しています。
「何を入れるか」を設定ファイルに書き、`switch` で反映し、`flake.lock` で依存のバージョンを固定する流れです。

Homebrew や手作業の dotfiles に慣れている人は、最初は少し遠回りに見えるかもしれません。
ただし、設定が repo にまとまり、別の端末でも同じ環境を再現しやすくなるのが大きな利点です。
