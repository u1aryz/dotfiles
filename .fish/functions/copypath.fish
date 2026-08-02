function copypath -d "Copy the absolute path of a file or directory to the clipboard (default: current directory, no trailing newline)"
    if set -q argv[2]
        echo "Usage: copypath [path]" >&2
        return 2
    end

    set -l target .
    if set -q argv[1]
        set target "$argv[1]"
    end

    if not test -e "$target"
        echo "copypath: path does not exist: $target" >&2
        return 1
    end

    set -l absolute_path (realpath -- "$target")
    or return

    printf '%s' "$absolute_path" | pbcopy
    and printf 'Copied: %s\n' "$absolute_path"
end
