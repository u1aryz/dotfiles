#!/bin/sh
# dotfilesの各ファイルをホームディレクトリへシンボリックリンクする
# setup-my-osx の Ansible ロール(roles/dotfiles)から実行されるほか、単体でも実行できる
set -eu

dotfiles_dir=$(cd "$(dirname "$0")" && pwd)

# 既に正しいリンクが張られていれば何もしない(変更したリンクのみ出力する)
link() {
	src="$dotfiles_dir/$1"
	dest="$2"
	[ "$(readlink "$dest" 2>/dev/null || true)" = "$src" ] && return 0
	mkdir -p "$(dirname "$dest")"
	ln -sfn "$src" "$dest"
	echo "link: $dest -> $src"
}

link .gitconfig "$HOME/.gitconfig"
link .tmux.conf "$HOME/.tmux.conf"
link .hyper.js "$HOME/.hyper.js"
link .karabiner/karabiner.json "$HOME/.config/karabiner/karabiner.json"
link .zellij/config.kdl "$HOME/.config/zellij/config.kdl"
link .ghostty/config "$HOME/.config/ghostty/config"
link .herdr/config.toml "$HOME/.config/herdr/config.toml"
link .mise/config.toml "$HOME/.config/mise/config.toml"
link .ccstatusline/settings.json "$HOME/.config/ccstatusline/settings.json"
link .claude/settings.json "$HOME/.claude/settings.json"
link .docker/config.json "$HOME/.docker/config.json"
link .vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"

# .fish/ 配下はファイル単位で再帰リンク(~/.config/fish 内でfisher管理のファイルと共存するため)
cd "$dotfiles_dir/.fish"
find . -type f | while IFS= read -r f; do
	link ".fish/${f#./}" "$HOME/.config/fish/${f#./}"
done
