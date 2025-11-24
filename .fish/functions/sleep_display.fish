function sleep_display -d "Sleep the display after X seconds (default: 2) while keeping the system awake"
    # Default delay is 2 seconds
    set -l delay $argv[1]
    test -z "$delay"; and set delay 2

    # Start a single caffeinate keeper if none is running (prevent idle/system/disk sleep, allow display sleep)
    pgrep -x caffeinate >/dev/null
    or begin
        caffeinate -ims &
        disown
    end

    sleep $delay
    pmset displaysleepnow
end
