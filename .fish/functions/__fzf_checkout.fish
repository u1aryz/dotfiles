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
