# plugin settings (fzfプラグインのconf.dより先に読まれる必要がある)
# fzfの古いキーバインドは使わない
set -g FZF_LEGACY_KEYBINDINGS 0
# ファイル検索にfdを使用する
set -g FZF_FIND_FILE_COMMAND "fd --type file --no-ignore --follow --hidden --exclude .git"
set -g FZF_OPEN_COMMAND $FZF_FIND_FILE_COMMAND
