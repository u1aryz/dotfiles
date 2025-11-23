# plugin settings
# fzfの古いキーバインドは使わない
set -U FZF_LEGACY_KEYBINDINGS 0
# ファイル検索にfdを使用する
set -U FZF_FIND_FILE_COMMAND "fd --type file --no-ignore --follow --hidden --exclude .git"
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

function tag_from_version -d "Create git tag from package.json or deno.json version with v prefix"
    set -l pkg_version ''

    if test -f package.json
        set pkg_version (node -p "require('./package.json').version || ''" 2>/dev/null)
    end

    if test -z "$pkg_version" -a -f deno.json
        set pkg_version (node -p "require('./deno.json').version || ''" 2>/dev/null)
    end

    if test -z "$pkg_version"
        echo "Failed to retrieve version from package.json or deno.json" >&2
        return 1
    end

    set -l tag
    if string match -rq '^v' -- $pkg_version
        set tag $pkg_version
    else
        set tag v$pkg_version
    end

    if git rev-parse --quiet --verify "$tag" >/dev/null
        echo "Tag $tag already exists" >&2
        return 1
    end
    git tag "$tag"
end

function sleep_display -d "Sleep the display after X seconds (default: 2) while keeping the system awake"
    # Default delay is 2 seconds
    set -l delay 2
    if test (count $argv) -gt 0
        set delay $argv[1]
    end

    # Start a single caffeinate keeper if none is running (prevent idle/system/disk sleep, allow display sleep)
    if not pgrep -x caffeinate >/dev/null
        caffeinate -ims &
        disown
    end

    sleep $delay
    pmset displaysleepnow
end

# keybind
bind \ch __fzf_z
bind \cg __ghq_repository_search

# env
set -x ANDROID_HOME ~/Library/Android/sdk
set -x EDITOR 'code --new-window'
set -x FZF_DEFAULT_OPTS '--height 40% --reverse --inline-info'
set -x RUNEWIDTH_EASTASIAN 0
set -x SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock
fish_add_path $ANDROID_HOME/tools
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path ~/go/bin
fish_add_path /opt/homebrew/bin
fish_add_path ~/.local/share/mise/shims

# abbreviations
abbr -a gst git status
abbr -a ga git add
abbr -a gc git commit
abbr -a gb git branch
abbr -a gco git checkout
abbr -a gd git diff
abbr -a gf git fetch
abbr -a gdc git diff --cached
abbr -a gg git graph
abbr -a tmux tmux -u
abbr -a l ls -la
abbr -a mkdir mkdir -p
abbr -a gghq GHQ_ROOT=~/go/src ghq
abbr -a ls eza
abbr -a grep rg
abbr -a cat bat -pP
abbr -a less bat
abbr -a find fd
abbr -a mr mise run
abbr -a ml mise list
abbr -a mi mise install

# function aliases (keep as alias since they call functions)
alias fco __fzf_checkout
alias fbd __fzf_delete_branch
