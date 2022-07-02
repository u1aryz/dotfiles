# plugin settings
# fzfの古いキーバインドは使わない
set -U FZF_LEGACY_KEYBINDINGS 0
# ファイル検索にagを使用する
set -U FZF_FIND_FILE_COMMAND "ag -l --hidden --ignore .git . \$dir 2> /dev/null"
set -U FZF_OPEN_COMMAND $FZF_FIND_FILE_COMMAND
set -g theme_date_timezone Asia/Tokyo
set -g theme_date_format "+%H:%M:%S"

# color scheme
set -U fish_color_autosuggestion BD93F9
set -U fish_color_cancel \x2dr
set -U fish_color_command F8F8F2
set -U fish_color_comment 6272A4
set -U fish_color_cwd green
set -U fish_color_cwd_root red
set -U fish_color_end 50FA7B
set -U fish_color_error FFB86C
set -U fish_color_escape 00a6b2
set -U fish_color_history_current \x2d\x2dbold
set -U fish_color_host normal
set -U fish_color_match \x2d\x2dbackground\x3dbrblue
set -U fish_color_normal normal
set -U fish_color_operator 00a6b2
set -U fish_color_param FF79C6
set -U fish_color_quote F1FA8C
set -U fish_color_redirection 8BE9FD
set -U fish_color_search_match bryellow\x1e\x2d\x2dbackground\x3dbrblack
set -U fish_color_selection white\x1e\x2d\x2dbold\x1e\x2d\x2dbackground\x3dbrblack
set -U fish_color_user brgreen
set -U fish_color_valid_path \x2d\x2dunderline
set -U fish_pager_color_completion normal
set -U fish_pager_color_description B3A06D\x1eyellow
set -U fish_pager_color_prefix white\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
set -U fish_pager_color_progress brwhite\x1e\x2d\x2dbackground\x3dcyan

function fish_greeting
  fish_logo blue cyan green '[' '@' | lolcat -p 3.0 -F 0.28 -S 1
end

function __fzf_z -d "Change directory by z & fzf"
  eval "z -l 2>&1 | fzf +s --query (commandline) | sed 's/^[0-9,.]* *//'" | read -l select
  if not test -z "$select"
    cd $select
    # clear
    commandline -t ""
  end
  commandline -f repaint
end

function __fzf_checkout -d "Checkout git branch by fzf"
  set -l branches (git branch --all)
  set -l result $status
  if test $result -ne 0
    return $result
  end

  eval "printf '%s\n' \$branches | grep -v HEAD | sed 's/.* //' | sed 's#remotes/[^/]*/##' | awk '!a[\$0]++' | fzf --query \"$argv\"" | read -l select
  if not test -z "$select"
    git checkout $select
  end
end

function __fzf_delete_branch -d "Delete git branch by fzf"
  set -l branches (git branch)
  set -l result $status
  if test $result -ne 0
    return $result
  end

  eval "printf '%s\n' \$branches | sed 's/.* //' | fzf --query \"$argv\"" | read -l select
  if not test -z "$select"
    git branch -d $select
  end
end

# keybind
bind \ch '__fzf_z'
bind \cg '__ghq_repository_search'

# env
set -x ANDROID_HOME ~/Library/Android/sdk
set -x PATH $ANDROID_HOME/tools $ANDROID_HOME/platform-tools ~/go/bin /opt/homebrew/bin $PATH
set -x EDITOR 'code --new-window'
set -x FZF_DEFAULT_OPTS '--height 40% --reverse --inline-info'

# alias
alias gst 'git status'
alias ga 'git add'
alias gc 'git commit'
alias gb 'git branch'
alias gco 'git checkout'
alias gd 'git diff'
alias gf 'git fetch'
alias gdc 'git diff --cached'
alias gg 'git graph'
alias tmux 'tmux -u'
alias l 'ls -la'
alias mkdir 'mkdir -p'
alias fco '__fzf_checkout'
alias fbd '__fzf_delete_branch'
alias gghq 'GHQ_ROOT=~/go/src ghq'
