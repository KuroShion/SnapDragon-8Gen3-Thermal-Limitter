#!/system/bin/sh
# Xiaomi MIX Flip (SM8650) Pure Thermal & Frequency Limiter
# Author: Kuro Shion (GitHub: https://github.com/KuroShion | Telegram: https://t.me/KuroShion)

# Wait until device has booted completely
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 3
done

# Wait for HyperOS thermal and perf daemons (Joyose, PowerHAL, mi_thermald) to initialize
sleep 25

log_msg() {
    echo "[Thermal-Limiter] $1" >> /cache/mixflip_thermal_limiter.log 2>/dev/null
}

log_msg "Thermal Limiter active. Initializing SM8650 frequency caps..."

get_safe_freq() {
    local policy_path="$1"
    local target_max="$2"
    local best_freq=""

    if [ -f "$policy_path/scaling_available_frequencies" ]; then
        for f in $(cat "$policy_path/scaling_available_frequencies"); do
            if [ "$f" -le "$target_max" ]; then
                best_freq="$f"
            fi
        done
    fi

    if [ -z "$best_freq" ]; then
        best_freq="$target_max"
    fi
    echo "$best_freq"
}

apply_limits() {
    # 1. Cap Cortex-X4 (cpu7 / policy7) from 3.30 GHz to ~2.80 GHz (Normal Mode)
    for p in /sys/devices/system/cpu/cpufreq/policy7 /sys/devices/system/cpu/cpu7/cpufreq; do
        if [ -d "$p" ]; then
            chmod 644 "$p/scaling_max_freq" 2>/dev/null
            TARGET_X4=$(get_safe_freq "$p" 2803200)
            echo "$TARGET_X4" > "$p/scaling_max_freq" 2>/dev/null
            chmod 444 "$p/scaling_max_freq" 2>/dev/null
            break
        fi
    done

    # 2. Cap Cortex-A720 Big Performance Cores:
    # policy2 (3.15 GHz) -> ~2.61 GHz
    # policy5 (2.96 GHz) -> ~2.47 GHz
    if [ -d /sys/devices/system/cpu/cpufreq/policy2 ]; then
        chmod 644 /sys/devices/system/cpu/cpufreq/policy2/scaling_max_freq 2>/dev/null
        TARGET_P2=$(get_safe_freq /sys/devices/system/cpu/cpufreq/policy2 2611200)
        echo "$TARGET_P2" > /sys/devices/system/cpu/cpufreq/policy2/scaling_max_freq 2>/dev/null
        chmod 444 /sys/devices/system/cpu/cpufreq/policy2/scaling_max_freq 2>/dev/null
    fi

    if [ -d /sys/devices/system/cpu/cpufreq/policy5 ]; then
        chmod 644 /sys/devices/system/cpu/cpufreq/policy5/scaling_max_freq 2>/dev/null
        TARGET_P5=$(get_safe_freq /sys/devices/system/cpu/cpufreq/policy5 2476800)
        echo "$TARGET_P5" > /sys/devices/system/cpu/cpufreq/policy5/scaling_max_freq 2>/dev/null
        chmod 444 /sys/devices/system/cpu/cpufreq/policy5/scaling_max_freq 2>/dev/null
    fi

    # 3. Disable aggressive Qualcomm Touch / Input Boost
    if [ -f /sys/module/cpu_boost/parameters/input_boost_freq ]; then
        chmod 644 /sys/module/cpu_boost/parameters/input_boost_freq 2>/dev/null
        echo "0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0" > /sys/module/cpu_boost/parameters/input_boost_freq 2>/dev/null
    fi

    if [ -f /sys/module/cpu_boost/parameters/input_boost_ms ]; then
        chmod 644 /sys/module/cpu_boost/parameters/input_boost_ms 2>/dev/null
        echo "0" > /sys/module/cpu_boost/parameters/input_boost_ms 2>/dev/null
    fi

    # 4. Tune Qualcomm WALT scheduler
    if [ -f /proc/sys/walt/sched_upmigrate ]; then
        echo "85 95" > /proc/sys/walt/sched_upmigrate 2>/dev/null
    fi
    if [ -f /proc/sys/walt/sched_downmigrate ]; then
        echo "75 85" > /proc/sys/walt/sched_downmigrate 2>/dev/null
    fi
    if [ -f /proc/sys/walt/sched_boost ]; then
        echo "0" > /proc/sys/walt/sched_boost 2>/dev/null
    fi

    # 5. Restrict background cpuset to Little Cores (cpu0-1)
    if [ -d /dev/cpuset/background ]; then
        echo "0-1" > /dev/cpuset/background/cpus 2>/dev/null
    fi
    if [ -d /dev/cpuset/system-background ]; then
        echo "0-1" > /dev/cpuset/system-background/cpus 2>/dev/null
    fi

    # 6. Tune virtual memory pressure for video streaming & pre-caching
    if [ -f /proc/sys/vm/vfs_cache_pressure ]; then
        echo "80" > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
    fi

    # 7. Lock refresh rate to 120Hz system-wide
    settings put system min_refresh_rate 120.0 2>/dev/null
    settings put system peak_refresh_rate 120.0 2>/dev/null
    settings put system user_refresh_rate 120 2>/dev/null
}

apply_limits
log_msg "Initial limits applied successfully."

# Watchdog loop: re-applies if HyperOS resets frequencies
while true; do
    sleep 35
    CUR_X4_MAX=$(cat /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq 2>/dev/null || cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq 2>/dev/null)
    if [ -n "$CUR_X4_MAX" ] && [ "$CUR_X4_MAX" -gt 2900000 ]; then
        log_msg "Reset detected ($CUR_X4_MAX kHz). Restoring limits..."
        apply_limits
    fi
done &
