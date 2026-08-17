function adb_clear_browser -d "Clear selected browser app data on all connected Android devices"
    command -q adb
    or begin
        echo "adb: command not found" >&2
        return 127
    end

    command -q fzf
    or begin
        echo "fzf: command not found" >&2
        return 127
    end

    set -l browser_options \
        'Chrome (com.android.chrome)' \
        'Chrome Beta (com.chrome.beta)' \
        'Edge (com.microsoft.emmx)' \
        'Firefox (org.mozilla.firefox)'
    set -l selected_browsers (printf '%s\n' $browser_options | \
        fzf --multi --no-input --reverse \
            --pointer='' --marker='✔ ' --color=marker:white \
            --bind 'space:toggle' \
            --bind 'a:transform([ "$FZF_SELECT_COUNT" -eq "$FZF_MATCH_COUNT" ] && echo deselect-all || echo select-all)' \
            --header 'Space: 選択 / a: 全選択/全解除 / Enter: 実行')

    set -q selected_browsers[1]
    or return 0

    set -l packages (string match -r '\(([^()]*)\)$' --groups-only $selected_browsers)

    # state が "device" の端末シリアルのみ抽出(unauthorized/offline は除外)
    set -l serials (command adb devices | string trim | string match -r '^(\S+)\s+device$' --groups-only)

    set -q serials[1]
    or begin
        echo "no connected devices" >&2
        return 1
    end

    set -l total (count $serials)
    set -l failures 0

    for i in (seq $total)
        set -l serial $serials[$i]
        set -l model (command adb -s $serial shell getprop ro.product.model 2>/dev/null | string trim)

        for package in $packages
            set_color cyan
            printf '[%d/%d] %s (%s) ' $i $total $serial "$model"
            set_color normal
            echo -n "clearing $package... "

            # 未インストールのパッケージはスキップ
            if not command adb -s $serial shell pm path $package &>/dev/null
                set_color yellow
                echo "not installed"
                set_color normal
                continue
            end

            # pm clear は成功時に "Success" を出力する
            if command adb -s $serial shell pm clear $package 2>/dev/null | string match -q 'Success*'
                set_color green
                echo done
            else
                set_color red
                echo failed
                set failures (math $failures + 1)
            end
            set_color normal
        end
    end

    test $failures -eq 0
end
