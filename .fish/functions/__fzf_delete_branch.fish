function __fzf_delete_branch -d "Delete git branch by fzf"
    git branch | read -lz branches
    or return

    printf '%s\n' $branches | sed 's/.* //' | fzf --query "$argv" | read -l select
    and git branch -d $select
end
