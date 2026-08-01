function pwdcp -d "Copy the absolute path of the current directory to the clipboard (no trailing newline)"
    printf '%s' (realpath .) | pbcopy
end
