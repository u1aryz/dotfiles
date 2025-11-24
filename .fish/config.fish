# plugin settings
# fzfの古いキーバインドは使わない
set -U FZF_LEGACY_KEYBINDINGS 0
# ファイル検索にfdを使用する
set -U FZF_FIND_FILE_COMMAND "fd --type file --no-ignore --follow --hidden --exclude .git"
set -U FZF_OPEN_COMMAND $FZF_FIND_FILE_COMMAND
set -g theme_date_timezone Asia/Tokyo
set -g theme_date_format "+%H:%M:%S"

# keybind
bind \ch __fzf_z
bind \cg __ghq_repository_search
