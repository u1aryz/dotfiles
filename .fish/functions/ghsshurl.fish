function ghsshurl -d "GitHub SSH URLのホストをSSH設定のエイリアスへ置換"
    set -l url $argv[1]

    if test -z "$url"
        set url (pbpaste)
    end

    if not string match -q 'git@github.com:*' -- "$url"
        echo "GitHub SSH URLではありません: $url" >&2
        return 1
    end

    set -l hosts (
        awk '
            tolower($1) == "host" {
                delete aliases
                for (i = 2; i <= NF; i++) {
                    aliases[i] = $i
                }
            }

            tolower($1) == "hostname" && tolower($2) == "github.com" {
                for (i in aliases) {
                    if (aliases[i] !~ /[*?!]/) {
                        print aliases[i]
                    }
                }
            }
        ' ~/.ssh/config
    )

    if test (count $hosts) -eq 0
        echo "HostName github.com のSSH設定が見つかりません" >&2
        return 1
    end

    set -l host (printf '%s\n' $hosts | fzf --prompt="GitHub SSH host> " --height=40% --reverse)
    or return

    set -l replaced (string replace 'git@github.com:' "git@$host:" -- "$url")

    printf '%s' "$replaced" | pbcopy
    echo "$replaced"
end
