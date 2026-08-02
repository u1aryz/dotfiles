complete -c copypath -f
complete -c copypath -n '__fish_is_nth_token 1' -a '(__fish_complete_path (commandline -ct) Path)'
