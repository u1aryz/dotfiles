# plugin settings
# fzfの古いキーバインドは使わない
set -U FZF_LEGACY_KEYBINDINGS 0
set -g theme_date_format "+%H:%M:%S"

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
bind \cj '__fzf_z'
bind \cg '__ghq_crtl_g'

# env
set -x ANDROID_HOME ~/Library/Android/sdk
set -x PATH $ANDROID_HOME/tools $ANDROID_HOME/platform-tools $PATH
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
