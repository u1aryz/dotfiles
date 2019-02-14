# plugin settings
# fzfの古いキーバインドは使わない
set -U FZF_LEGACY_KEYBINDINGS 0
set -g theme_date_format "+%H:%M:%S"

function __fzf_z -d "Change directory by z & fzf"
  eval "z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --query (commandline) | sed 's/^[0-9,.]* *//'" | read -l select
  if not test -z "$select"
    cd $select
  end
  commandline -f repaint
end

# keybind
bind \cj '__fzf_z'
bind \cg '__ghq_crtl_g'

# env
set -x ANDROID_HOME ~/Library/Android/sdk
set -x EDITOR 'code --new-window'

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
