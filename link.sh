#!/bin/sh
# dotfilesの各ファイルをホームディレクトリへシンボリックリンクする
# setup-my-osx の Ansible ロール(roles/dotfiles)から実行されるほか、単体でも実行できる
set -eu

dotfiles_dir=$(cd "$(dirname "$0")" && pwd)
state_dir=${XDG_STATE_HOME:-"$HOME/.local/state"}/dotfiles
link_state_file="$state_dir/links"

mkdir -p "$state_dir"
current_link_state=$(mktemp "$state_dir/links.XXXXXX")
trap 'rm -f "$current_link_state"' 0

# 既に正しいリンクが張られていれば何もしない(変更したリンクのみ出力する)
link() {
	src="$dotfiles_dir/$1"
	dest="$2"
	printf '%s\t%s\n' "$src" "$dest" >>"$current_link_state"
	[ "$(readlink "$dest" 2>/dev/null || true)" = "$src" ] && return 0
	if [ -e "$dest" ] || [ -L "$dest" ]; then
		echo "error: 既存のファイルまたはリンクがあります: $dest" >&2
		echo "既存の内容を退避または削除してから再実行してください" >&2
		return 1
	fi
	mkdir -p "$(dirname "$dest")"
	ln -s "$src" "$dest"
	echo "link: $dest -> $src"
}

# 前回の管理対象から外れたリンクのうち、リンク先が削除済みのものだけを削除する
cleanup_stale_links() {
	[ -f "$link_state_file" ] || return 0
	tab=$(printf '\t')
	while IFS="$tab" read -r old_src old_dest; do
		old_record=$(printf '%s\t%s' "$old_src" "$old_dest")
		grep -Fqx "$old_record" "$current_link_state" && continue
		case "$old_src" in
			"$dotfiles_dir"/*) ;;
			*) continue ;;
		esac
		case "$old_dest" in
			"$HOME"/*) ;;
			*) continue ;;
		esac
		[ ! -e "$old_dest" ] || continue
		[ "$(readlink "$old_dest" 2>/dev/null || true)" = "$old_src" ] || continue
		rm "$old_dest"
		echo "unlink: $old_dest"
	done <"$link_state_file"
}

link .gitconfig "$HOME/.gitconfig"
link .config/git/ignore "$HOME/.config/git/ignore"
link .karabiner/karabiner.json "$HOME/.config/karabiner/karabiner.json"
link .ghostty/config "$HOME/.config/ghostty/config"
link .herdr/config.toml "$HOME/.config/herdr/config.toml"
link .herdr/nav.sh "$HOME/.config/herdr/nav.sh"
link .herdr/hunk-layout.sh "$HOME/.config/herdr/hunk-layout.sh"
link .hunk/config.toml "$HOME/.config/hunk/config.toml"
link .mise/config.toml "$HOME/.config/mise/config.toml"
link .pi/agent/AGENTS.md "$HOME/.pi/agent/AGENTS.md"
link .pi/agent/settings.json "$HOME/.pi/agent/settings.json"
link .pi/agent/models.json "$HOME/.pi/agent/models.json"
link .pi/agent/agents/readonly-workflow-reviewer.md "$HOME/.pi/agent/agents/readonly-workflow-reviewer.md"
link .pi/agent/extensions/copy-command.ts "$HOME/.pi/agent/extensions/copy-command.ts"
link .pi/agent/extensions/pi-auto-review/config.json "$HOME/.pi/agent/extensions/pi-auto-review/config.json"
link .pi/agent/extensions/pi-permission-system/config.json "$HOME/.pi/agent/extensions/pi-permission-system/config.json"
link .pi/agent/extensions/pi-sandbox/config.json "$HOME/.pi/agent/extensions/pi-sandbox/config.json"
link .pi/agent/extensions/subagent/config.json "$HOME/.pi/agent/extensions/subagent/config.json"
link .ccstatusline/settings.json "$HOME/.config/ccstatusline/settings.json"
link .claude/settings.json "$HOME/.claude/settings.json"
link .docker/config.json "$HOME/.docker/config.json"
link .ssh/config "$HOME/.ssh/config"
link .vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"

# .fish/ 配下はファイル単位で再帰リンク(~/.config/fish 内でfisher管理のファイルと共存するため)
cd "$dotfiles_dir/.fish"
find . -type f ! -name '.DS_Store' | while IFS= read -r f; do
	link ".fish/${f#./}" "$HOME/.config/fish/${f#./}"
done

cleanup_stale_links
mv "$current_link_state" "$link_state_file"
trap - 0
