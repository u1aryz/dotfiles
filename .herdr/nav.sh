#!/bin/sh
# option+矢印キーのハイブリッド移動 (zellij の MoveFocusOrTab 相当)
# その方向にペインがあればペイン移動、なければ左右=タブ / 上下=ワークスペース移動
# config.toml の [[keys.command]] から呼ばれる (HERDR_* 環境変数はherdrが渡す)
set -eu

dir=$1
out=$("$HERDR_BIN_PATH" pane focus --direction "$dir" --current)
case "$out" in *'"changed":true'*) exit 0 ;; esac

case "$dir" in
left | right)
	[ "$dir" = left ] && o=-1 || o=1
	id=$("$HERDR_BIN_PATH" tab list --workspace "$HERDR_ACTIVE_WORKSPACE_ID" |
		jq -r --argjson o "$o" '.result.tabs | sort_by(.number) as $t |
			($t | map(.focused) | index(true)) as $i | $t[($i + $o + length) % length].tab_id')
	exec "$HERDR_BIN_PATH" tab focus "$id"
	;;
up | down)
	[ "$dir" = up ] && o=-1 || o=1
	id=$("$HERDR_BIN_PATH" workspace list |
		jq -r --argjson o "$o" '.result.workspaces | sort_by(.number) as $w |
			($w | map(.focused) | index(true)) as $i | $w[($i + $o + length) % length].workspace_id')
	exec "$HERDR_BIN_PATH" workspace focus "$id"
	;;
esac
