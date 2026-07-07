function adb_devices -d "List adb devices with a connected-device count"
    command -q adb
    or begin
        echo "adb: command not found" >&2
        return 127
    end

    set -l lines (command adb devices $argv | string trim | string match -v '' | string match -v 'List of devices attached')

    set -q lines[1]
    and begin
        printf '%s\n' $lines
        echo
    end

    # Only lines whose state is "device" count as connected
    set -l connected (string match -r '^\S+\s+device\b' -- $lines | count)
    set -l others (math (count $lines) - $connected)

    set_color green
    echo -n "$connected connected"
    set_color normal
    test $others -gt 0
    and echo -n " ($others unauthorized/offline)"
    echo
end
