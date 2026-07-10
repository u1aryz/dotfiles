# dotfiles

macOS用の個人dotfiles。fish + Ghostty + herdr を中心とした環境の設定ファイルを管理する。

## セットアップ

このリポジトリを直接cloneして使うのではなく、[setup-my-osx](https://github.com/u1aryz/setup-my-osx) の Ansible ロール(`roles/dotfiles`)が以下を行う。

1. 本リポジトリを `~/.config/dotfiles` にclone
2. `roles/dotfiles/vars/main.yml` の定義に従ってシンボリックリンクを作成

## 含まれる設定

| リポジトリ側 | リンク先(ホーム側) | ツール |
| --- | --- | --- |
| `.gitconfig` | `~/.gitconfig` | git |
| `.fish/` | `~/.config/fish/`(ファイル単位で再帰リンク) | fish |
| `.ghostty/config` | `~/.config/ghostty/config` | Ghostty |
| `.herdr/config.toml` | `~/.config/herdr/config.toml` | herdr |
| `.zellij/config.kdl` | `~/.config/zellij/config.kdl` | zellij |
| `.karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` | Karabiner-Elements |
| `.mise/config.toml` | `~/.config/mise/config.toml` | mise |
| `.claude/settings.json` | `~/.claude/settings.json` | Claude Code |
| `.ccstatusline/settings.json` | `~/.config/ccstatusline/settings.json` | ccstatusline |
| `.docker/config.json` | `~/.docker/config.json` | Docker |
| `.vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` | VS Code |
| `.tmux.conf` | `~/.tmux.conf` | tmux(レガシー) |
| `.hyper.js` | `~/.hyper.js` | Hyper(レガシー) |

`.fish/` 配下はディレクトリごとのリンクではなく、Ansibleが再帰的にファイルを列挙して `~/.config/fish/` 配下へ個別にリンクする(fisher管理のプラグインファイルと共存するため)。

## ファイル追加時の手順

新しい設定ファイルを追加した場合は、setup-my-osx 側の `roles/dotfiles/vars/main.yml` の `dotfiles_files`(配置先ディレクトリが新規なら `dotfiles_directories` も)への追記と、Ansibleの再実行が必要。`.fish/` 配下へのファイル追加は再帰リンクのため vars の追記は不要(Ansible再実行のみ)。

## メンテナンス

設定ファイルの整形は mise のタスクで行う。

```sh
mise run format
```

fish_indent(fish)、taplo(TOML)、prettier(JS/JSON)が対象ファイルを整形する。
