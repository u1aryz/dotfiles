function __fzf_z -d "Change directory by z & fzf"
    eval "z -l 2>&1 | fzf +s --query (commandline) | sed 's/^[0-9,.]* *//'" | read -l select
    if not test -z "$select"
        cd $select
        # clear
        commandline -t ""
    end
    commandline -f repaint
end
