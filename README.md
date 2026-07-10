# dotfiles

macOS用の個人dotfiles。fish + Ghostty + herdr を中心とした環境の設定ファイルを管理する。

## セットアップ

cloneして `link.sh` を実行する。冪等なので何度実行しても安全(変更したリンクのみ出力する)。

```sh
git clone git@github.com:u1aryz/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
sh link.sh
```

## リンクのマッピング

何をどこへリンクするかは `link.sh` が唯一の定義。`.fish/` 配下はディレクトリごとのリンクではなく、`link.sh` が再帰的にファイルを列挙して `~/.config/fish/` 配下へ個別にリンクする(fisher管理のプラグインファイルと共存するため)。

## ファイル追加時の手順

新しい設定ファイルを追加した場合は、`link.sh` へのマッピング追記と `sh link.sh` の再実行が必要。`.fish/` 配下へのファイル追加はマッピング追記が不要(`sh link.sh` の再実行のみ)。

## メンテナンス

設定ファイルの整形は mise のタスクで行う。

```sh
mise run format
```

fish_indent(fish)、taplo(TOML)、prettier(JS/JSON)が対象ファイルを整形する。
