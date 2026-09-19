#!/system/bin/sh

PORT="/sys/class/typec/port0"

# Wait for the Type-C controller to become available
until [ -d "$PORT" ]; do
    sleep 1
done

# Give Android time to initialize USB/Type-C
sleep 8

# Prefer receiving power
if [ -w "$PORT/preferred_role" ]; then
    echo sink > "$PORT/preferred_role"
fi

# Request sink mode
if [ -w "$PORT/power_role" ]; then
    echo sink > "$PORT/power_role"
fi

# Keep checking because Android may renegotiate the USB-C role
while true; do

    if [ -r "$PORT/power_role" ]; then
        ROLE="$(cat "$PORT/power_role" 2>/dev/null)"

        case "$ROLE" in
            source)
                echo sink > "$PORT/power_role" 2>/dev/null
                ;;
            *"[source]"*)
                echo sink > "$PORT/power_role" 2>/dev/null
                ;;
        esac
    fi

    if [ -w "$PORT/preferred_role" ]; then
        echo sink > "$PORT/preferred_role" 2>/dev/null
    fi

    sleep 3
done
