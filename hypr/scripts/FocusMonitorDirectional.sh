#!/usr/bin/env bash
# Focus monitor in direction: h=left, l=right, k=up, j=down
set -u

DIRECTION="${1:-}"
[ -z "$DIRECTION" ] && exit 1

CURRENT_MON=$(hyprctl activewindow -j 2>/dev/null | jq '.monitor // 1')
# Convert to 0-based index
CURRENT_IDX=$((CURRENT_MON - 1))

MONITORS=$(hyprctl monitors -j 2>/dev/null)
NUM_MONS=$(echo "$MONITORS" | jq 'length')
[ "$NUM_MONS" -lt 2 ] && exit 0

# Get current monitor position
CUR_X=$(echo "$MONITORS" | jq ".[$CURRENT_IDX].x")
CUR_Y=$(echo "$MONITORS" | jq ".[$CURRENT_IDX].y")
CUR_W=$(echo "$MONITORS" | jq ".[$CURRENT_IDX].width")

TARGET_IDX=-1
MIN_DIST=999999

for ((i=0; i<NUM_MONS; i++)); do
    [ "$i" -eq "$CURRENT_IDX" ] && continue
    MX=$(echo "$MONITORS" | jq ".[$i].x")
    MY=$(echo "$MONITORS" | jq ".[$i].y")

    case "$DIRECTION" in
        h) # left - monitor must be to the left
            [ "$MX" -ge "$CUR_X" ] && continue
            DIST=$((CUR_X - MX))
            ;;
        l) # right - monitor must be to the right
            [ "$MX" -le "$CUR_X" ] && continue
            DIST=$((MX - CUR_X))
            ;;
        k) # up - monitor must be above
            [ "$MY" -ge "$CUR_Y" ] && continue
            DIST=$((CUR_Y - MY))
            ;;
        j) # down - monitor must be below
            [ "$MY" -le "$CUR_Y" ] && continue
            DIST=$((MY - CUR_Y))
            ;;
        toggle) # just pick any other monitor
            DIST=0
            ;;
        *) exit 1 ;;
    esac

    if [ "$DIST" -lt "$MIN_DIST" ]; then
        MIN_DIST=$DIST
        TARGET_IDX=$i
    fi
done

[ "$TARGET_IDX" -eq -1 ] && exit 0

TARGET_NAME=$(echo "$MONITORS" | jq -r ".[$TARGET_IDX].name")
hyprctl dispatch focusmonitor "$TARGET_NAME"
