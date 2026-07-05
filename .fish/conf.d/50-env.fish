# Environment variables
set -gx ANDROID_HOME /opt/homebrew/share/android-commandlinetools
set -gx JAVA_HOME /opt/homebrew/opt/openjdk
set -gx EDITOR 'code --new-window'
set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --inline-info'
set -gx RUNEWIDTH_EASTASIAN 0
set -gx SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock

# Java
fish_add_path -g $JAVA_HOME/bin

# Android SDK
fish_add_path -g $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path -g $ANDROID_HOME/emulator
fish_add_path -g $ANDROID_HOME/platform-tools

# User tools
fish_add_path -g /opt/homebrew/bin
fish_add_path -g ~/.local/share/mise/shims
fish_add_path -g ~/go/bin
