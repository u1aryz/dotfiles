function sleep_display -d "Sleep the display after X seconds (default: 2) while keeping the system awake"
    # Default delay is 2 seconds
    set -l delay 2
    if test (count $argv) -gt 0
        set delay $argv[1]
    end

    # Start a single caffeinate keeper if none is running (prevent idle/system/disk sleep, allow display sleep)
    if not pgrep -x caffeinate >/dev/null
        caffeinate -ims &
        disown
    end

    sleep $delay
    pmset displaysleepnow
end
