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

## SSH

SSH認証には1Password SSH AgentとSSH Bookmarksを使用する。1Passwordへサインインし、SSH Agentと「ブックマークしたホストを含むSSH設定ファイルを生成」を有効にする。

SSH KeyとBookmarksは1Passwordから同期され、公開鍵ファイルと鍵の割り当てが `~/.ssh/1Password/` に自動生成される。ホスト固有の追加設定のみ `~/.ssh/config.local` で管理し、リポジトリには含めない。

GitHubでは接続先のエイリアスによって鍵を切り替える。

```sh
# 個人用
git clone git@github-personal:OWNER/REPOSITORY.git

# 仕事用
git clone git@github-work:ORGANIZATION/REPOSITORY.git
```

既存リポジトリは `git remote set-url origin` で同様の接続先へ変更できる。OrbStackのSSH設定は `~/.orbstack/ssh/config` から自動的に読み込む。

## メンテナンス

設定ファイルの整形は mise のタスクで行う。

```sh
mise run format
```

fish_indent(fish)、taplo(TOML)、prettier(JS/JSON)が対象ファイルを整形する。
