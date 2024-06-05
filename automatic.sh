#!/system/bin/sh

get_total_size() {
    local pattern=$1
    local total=0

    for size in $(du -sb $pattern 2>/dev/null | awk '{print $1}'); do
        total=$((total + size))
    done

    echo $total
}

convert_to_bytes() {
    local value=$1
    local unit=${value: -2}
    local number=${value%${unit}}

    case $unit in
        GB)
            echo $((number * 1024 * 1024 * 1024))
            ;;
        MB)
            echo $((number * 1024 * 1024))
            ;;
        *)
            echo $number
            ;;
    esac
}

automatic() {
    local interval=3600
    
    if [ -f /sdcard/CacheCleaner/settings.conf ]; then
        . /sdcard/CacheCleaner/settings.conf
    else
        echo "Threshold=\"1GB\"" > /sdcard/CacheCleaner/settings.conf
        . /sdcard/CacheCleaner/settings.conf
    fi

    local threshold_bytes=$(convert_to_bytes $Threshold)

    while [ ! -f /sdcard/CacheCleaner/disable ]; do
        local size1=$(get_total_size "/data/data/*/cache")
        local size2=$(get_total_size "/data/data/*/code_cache")
        local size3=$(get_total_size "/data/user_de/*/*/cache")
        local size4=$(get_total_size "/data/user_de/*/*/code_cache")
        local size5=$(get_total_size "/sdcard/Android/data/*/cache")

        size1=${size1:-0}
        size2=${size2:-0}
        size3=${size3:-0}
        size4=${size4:-0}
        size5=${size5:-0}

        local total=$((size1 + size2 + size3 + size4 + size5))
        local total_mb=$((total / 1024 / 1024))

        echo "Total cache size: $total bytes ($total_mb MB)"

        if [ $total -gt $threshold_bytes ]; then
            local logs1="[$(date +'%d/%m/%y %H:%M:%S')] Cleaning apps cache (AUTO)..."
            echo $logs1 >> /sdcard/CacheCleaner/logs.txt

            sh /bin/cleaner

            local logs2="[$(date +'%d/%m/%y %H:%M:%S')] Done! The apps cache has been cleaned! (AUTO)\n"
            echo -e $logs2 >> /sdcard/CacheCleaner/logs.txt
        fi

        [ -f /sdcard/CacheCleaner/disable ] && break

        local now=$(date +%s)
        sleep $(( interval - now % interval ))
    done
}

automatic
