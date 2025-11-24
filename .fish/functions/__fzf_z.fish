function __fzf_z -d "Change directory by z & fzf"
    z -l 2>&1 | fzf +s --query (commandline) | sed 's/^[0-9,.]* *//' | read -l select
    and begin
        cd $select
        commandline -t ""
    end
    commandline -f repaint
end
