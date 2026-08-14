#!/bin/sh
# 現在のタブを左にhunk、右側に上下2つのプロンプトの構成にする
# config.toml の [[keys.command]] から呼ばれる (HERDR_* 環境変数はherdrが渡す)
set -eu

current_pane=$("$HERDR_BIN_PATH" pane get "$HERDR_ACTIVE_PANE_ID")
tab_id=$(printf '%s\n' "$current_pane" | jq -r '.result.pane.tab_id')
workspace_id=$(printf '%s\n' "$current_pane" | jq -r '.result.pane.workspace_id')
workspace_panes=$("$HERDR_BIN_PATH" pane list --workspace "$workspace_id")
pane_count=$(printf '%s\n' "$workspace_panes" |
	jq --arg tab_id "$tab_id" '[.result.panes[] | select(.tab_id == $tab_id)] | length')

[ "$pane_count" -eq 1 ] || exit 0

left_pane_id=$HERDR_ACTIVE_PANE_ID
right_pane=$("$HERDR_BIN_PATH" pane split "$left_pane_id" --direction right --ratio 0.5 --no-focus)
right_top_pane_id=$(printf '%s\n' "$right_pane" | jq -r '.result.pane.pane_id')

"$HERDR_BIN_PATH" pane split "$right_top_pane_id" --direction down --ratio 0.5 --no-focus >/dev/null
"$HERDR_BIN_PATH" pane run "$left_pane_id" "hunk diff --watch --transparent-bg" >/dev/null
"$HERDR_BIN_PATH" pane focus --pane "$left_pane_id" --direction right >/dev/null
