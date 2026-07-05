# Environment variables
set -gx ANDROID_HOME /opt/homebrew/share/android-commandlinetools
set -gx JAVA_HOME /opt/homebrew/opt/openjdk
set -gx EDITOR 'code --new-window'
set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --inline-info'
set -gx RUNEWIDTH_EASTASIAN 0
set -gx SSH_AUTH_SOCK ~/.bitwarden-ssh-agent.sock

# Java
fish_add_path $JAVA_HOME/bin

# Android SDK
fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $ANDROID_HOME/tools

# User tools
fish_add_path /opt/homebrew/bin
fish_add_path ~/.local/share/mise/shims
fish_add_path ~/go/bin
