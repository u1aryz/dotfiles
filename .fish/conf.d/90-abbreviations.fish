# abbreviations
# git
abbr -a gst git status
abbr -a ga git add
abbr -a gc git commit
abbr -a gb git branch
abbr -a gco git checkout
abbr -a gd git diff
abbr -a gf git fetch
abbr -a gdc git diff --cached
abbr -a gg git graph
abbr -a gghq GHQ_ROOT=~/go/src ghq

# eza (ls replacement)
abbr -a ls eza
abbr -a l eza -la
abbr -a ll eza -lh

# other modern replacements
abbr -a grep rg
abbr -a cat bat -pP
abbr -a less bat
abbr -a find fd

# misc
abbr -a tmux tmux -u
abbr -a mkdir mkdir -p
abbr -a mr mise run
abbr -a ml mise list
abbr -a mi mise install

# function aliases (keep as alias since they call functions)
alias fco __fzf_checkout
alias fbd __fzf_delete_branch
