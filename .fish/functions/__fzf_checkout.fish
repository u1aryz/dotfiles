function __fzf_checkout -d "Checkout git branch by fzf"
    git branch --all | read -lz branches
    or return

    printf '%s\n' $branches | grep -v HEAD | sed 's/.* //' | sed 's#remotes/[^/]*/##' | awk '!a[$0]++' | fzf --query "$argv" | read -l select
    and git checkout $select
end
