# env
set -x ANDROID_HOME ~/Library/Android/sdk
set -x EDITOR 'code --new-window'
set -x FZF_DEFAULT_OPTS '--height 40% --reverse --inline-info'
set -x RUNEWIDTH_EASTASIAN 0
set -x SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock
fish_add_path $ANDROID_HOME/tools
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path ~/go/bin
fish_add_path /opt/homebrew/bin
fish_add_path ~/.local/share/mise/shims
