function adb_clear_chrome -d "Clear Chrome and Chrome Beta app data on all connected Android devices"
    command -q adb
    or begin
        echo "adb: command not found" >&2
        return 127
    end

    # state が "device" の端末シリアルのみ抽出(unauthorized/offline は除外)
    set -l serials (command adb devices | string trim | string match -r '^(\S+)\s+device$' --groups-only)

    set -q serials[1]
    or begin
        echo "no connected devices" >&2
        return 1
    end

    set -l packages com.android.chrome com.chrome.beta
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
