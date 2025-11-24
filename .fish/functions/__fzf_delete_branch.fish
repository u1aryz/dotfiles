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
