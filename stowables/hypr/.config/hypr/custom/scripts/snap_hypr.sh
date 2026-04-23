#!/bin/bash
# snap_hypr.sh - Dynamic window snapping for Hyprland with relative movement
# Usage: snap_hypr.sh <position> [rows] [cols]
# Examples:
#   snap_hypr.sh top          # Snap to top third (3 rows, 1 col)
#   snap_hypr.sh down         # Move down one cell from current position
#   snap_hypr.sh up 2         # Move up 2 cells from current position
#   snap_hypr.sh left         # Move left one cell (or snap to left half)
#   snap_hypr.sh topleft 2 2  # Snap to top-left quarter (2x2 grid)
#   snap_hypr.sh 0 3 3        # Snap to position 0 in 3x3 grid (top-left)
#
# Environment variables:
#   BAR_OVERRIDE=top|right|bottom|left  # Override bar position detection
#   BAR_SIZE=pixels                      # Override bar size (default: 40)
#   DEBUG=1                              # Enable debug output

# State file for tracking current grid position
STATE_DIR="/tmp/hypr_snap"
mkdir -p "$STATE_DIR"

# Check for jq dependency
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed"
  exit 1
fi

# Get the active window address
WIN_ADDR=$(hyprctl activewindow -j | jq -r '.address')
STATE_FILE="$STATE_DIR/${WIN_ADDR}.state"

# Get the focused monitor's info
MON_INFO=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
MON_X=$(echo "$MON_INFO" | jq -r '.x')
MON_Y=$(echo "$MON_INFO" | jq -r '.y')
MON_SCALE=$(echo "$MON_INFO" | jq -r '.scale')
MON_TRANSFORM=$(echo "$MON_INFO" | jq -r '.transform')

# Get reserved space [top, right, bottom, left]
RESERVED=$(echo "$MON_INFO" | jq -r '.reserved')
RESERVED_TOP=$(echo "$RESERVED" | jq -r '.[0]')
RESERVED_RIGHT=$(echo "$RESERVED" | jq -r '.[1]')
RESERVED_BOTTOM=$(echo "$RESERVED" | jq -r '.[2]')
RESERVED_LEFT=$(echo "$RESERVED" | jq -r '.[3]')

# Get physical dimensions
PHYSICAL_WIDTH=$(echo "$MON_INFO" | jq -r '.width')
PHYSICAL_HEIGHT=$(echo "$MON_INFO" | jq -r '.height')

# Manual override for bar position (takes precedence)
if [ -n "$BAR_OVERRIDE" ]; then
  BAR_SIZE=${BAR_SIZE:-40}
  RESERVED_TOP=0
  RESERVED_RIGHT=0
  RESERVED_BOTTOM=0
  RESERVED_LEFT=0

  case $BAR_OVERRIDE in
  top) RESERVED_TOP=$BAR_SIZE ;;
  right) RESERVED_RIGHT=$BAR_SIZE ;;
  bottom) RESERVED_BOTTOM=$BAR_SIZE ;;
  left) RESERVED_LEFT=$BAR_SIZE ;;
  *)
    echo "Error: BAR_OVERRIDE must be top, right, bottom, or left"
    exit 1
    ;;
  esac
fi

# Account for rotation and apply reserved space rotation
# Transform values: 0=normal, 1=90°, 2=180°, 3=270°
# NOTE: Hyprland may report reserved space in physical coordinates
# We need to rotate it to match the logical display orientation
TEMP_TOP=$RESERVED_TOP
TEMP_RIGHT=$RESERVED_RIGHT
TEMP_BOTTOM=$RESERVED_BOTTOM
TEMP_LEFT=$RESERVED_LEFT

case $MON_TRANSFORM in
0)
  # No rotation - but bar might still be misreported
  # If right is reserved but others aren't, likely the bar is actually on top
  if [ $RESERVED_RIGHT -gt 0 ] && [ $RESERVED_TOP -eq 0 ] && [ $RESERVED_BOTTOM -eq 0 ] && [ $RESERVED_LEFT -eq 0 ]; then
    RESERVED_TOP=$RESERVED_RIGHT
    RESERVED_RIGHT=0
  fi
  ;;
1)
  # 90° clockwise: Physical right becomes logical top
  TEMP=$PHYSICAL_WIDTH
  PHYSICAL_WIDTH=$PHYSICAL_HEIGHT
  PHYSICAL_HEIGHT=$TEMP

  RESERVED_TOP=$TEMP_RIGHT
  RESERVED_RIGHT=$TEMP_BOTTOM
  RESERVED_BOTTOM=$TEMP_LEFT
  RESERVED_LEFT=$TEMP_TOP
  ;;
2)
  # 180°: top→bottom, right→left, bottom→top, left→right
  RESERVED_TOP=$TEMP_BOTTOM
  RESERVED_RIGHT=$TEMP_LEFT
  RESERVED_BOTTOM=$TEMP_TOP
  RESERVED_LEFT=$TEMP_RIGHT
  ;;
3)
  # 270° clockwise: Physical right becomes logical bottom
  TEMP=$PHYSICAL_WIDTH
  PHYSICAL_WIDTH=$PHYSICAL_HEIGHT
  PHYSICAL_HEIGHT=$TEMP

  RESERVED_TOP=$TEMP_LEFT
  RESERVED_RIGHT=$TEMP_TOP
  RESERVED_BOTTOM=$TEMP_RIGHT
  RESERVED_LEFT=$TEMP_BOTTOM
  ;;
esac

# Calculate logical dimensions (accounting for scaling)
MON_WIDTH=$(awk "BEGIN {print int($PHYSICAL_WIDTH / $MON_SCALE)}")
MON_HEIGHT=$(awk "BEGIN {print int($PHYSICAL_HEIGHT / $MON_SCALE)}")

# Apply reserved space to usable area
# Reserved space doesn't change the starting position (USABLE_X/Y)
# It only reduces the available width/height
USABLE_X=$((MON_X + RESERVED_LEFT))
USABLE_Y=$((MON_Y + RESERVED_TOP))
USABLE_WIDTH=$((MON_WIDTH - RESERVED_LEFT - RESERVED_RIGHT))
USABLE_HEIGHT=$((MON_HEIGHT - RESERVED_TOP - RESERVED_BOTTOM))

# Parse arguments
POSITION=$1
ROWS=${2:-3}      # Default to 3 rows
COLS=${3:-1}      # Default to 1 column
DEBUG=${DEBUG:-0} # Set DEBUG=1 to enable debug output

# Make window floating if it isn't already
IS_FLOATING=$(hyprctl activewindow -j | jq -r '.floating')
if [ "$IS_FLOATING" = "false" ]; then
  hyprctl dispatch togglefloating
fi

# Pre-calculate cell dimensions for default grid
CELL_WIDTH=$((USABLE_WIDTH / COLS))
CELL_HEIGHT=$((USABLE_HEIGHT / ROWS))

# Load current state if it exists
if [ -f "$STATE_FILE" ]; then
  source "$STATE_FILE"
else
  CURRENT_ROW=0
  CURRENT_COL=0
  CURRENT_ROWS=3
  CURRENT_COLS=1
fi

# Debug output
if [ "$DEBUG" = "1" ]; then
  echo "Monitor: $MON_X,$MON_Y ${MON_WIDTH}x${MON_HEIGHT} (scale: $MON_SCALE, transform: $MON_TRANSFORM)"
  echo "Reserved: T:$RESERVED_TOP R:$RESERVED_RIGHT B:$RESERVED_BOTTOM L:$RESERVED_LEFT"
  echo "Usable: $USABLE_X,$USABLE_Y ${USABLE_WIDTH}x${USABLE_HEIGHT}"
  echo "Grid: ${ROWS}x${COLS} (${CELL_WIDTH}x${CELL_HEIGHT} per cell)"
  echo "Current state: Row $CURRENT_ROW, Col $CURRENT_COL (Grid: ${CURRENT_ROWS}x${CURRENT_COLS})"
fi

# Function to save state
save_state() {
  local row=$1
  local col=$2
  local rows=$3
  local cols=$4

  cat >"$STATE_FILE" <<EOF
CURRENT_ROW=$row
CURRENT_COL=$col
CURRENT_ROWS=$rows
CURRENT_COLS=$cols
EOF
}

# Function to snap to a specific grid position
snap_to_position() {
  local row=$1
  local col=$2
  local row_span=${3:-1}
  local col_span=${4:-1}
  local rows=${5:-$ROWS}
  local cols=${6:-$COLS}

  # Recalculate cell dimensions for this grid
  local cell_w=$((USABLE_WIDTH / cols))
  local cell_h=$((USABLE_HEIGHT / rows))

  local x=$((USABLE_X + col * cell_w))
  local y=$((USABLE_Y + row * cell_h))
  local width=$((cell_w * col_span))
  local height=$((cell_h * row_span))

  hyprctl --batch "dispatch moveactive exact $x $y ; dispatch resizeactive exact $width $height"

  # Save state
  save_state $row $col $rows $cols
}

# Function to move relatively from current position
move_relative() {
  local row_delta=$1
  local col_delta=$2
  local rows=${3:-$CURRENT_ROWS}
  local cols=${4:-$CURRENT_COLS}

  # Calculate new position
  local new_row=$((CURRENT_ROW + row_delta))
  local new_col=$((CURRENT_COL + col_delta))

  # Smart grid transitions for smoother workflow
  # If we're in a 3x1 grid and moving sideways, switch to 2x2
  if [ $CURRENT_ROWS -eq 3 ] && [ $CURRENT_COLS -eq 1 ] && [ $col_delta -ne 0 ]; then
    rows=2
    cols=2
    # Map 3x1 position to 2x2 position
    if [ $CURRENT_ROW -eq 0 ]; then
      new_row=0 # top -> top
    elif [ $CURRENT_ROW -eq 1 ]; then
      new_row=0 # mid -> top
    else
      new_row=1 # bottom -> bottom
    fi
    new_col=$((col_delta > 0 ? 1 : 0))
  fi

  # If we're in a 1x2 grid and moving vertically, switch to 2x2
  if [ $CURRENT_ROWS -eq 1 ] && [ $CURRENT_COLS -eq 2 ] && [ $row_delta -ne 0 ]; then
    rows=2
    cols=2
    # Map 1x2 position to 2x2 position
    if [ $CURRENT_COL -eq 0 ]; then
      new_col=0 # left -> left
    else
      new_col=1 # right -> right
    fi
    new_row=$((row_delta > 0 ? 1 : 0))
  fi

  # If we're in a 2x2 grid and moving to edge, consider switching to simpler layout
  # Moving left from left column -> switch to 1x2 left half
  if [ $CURRENT_ROWS -eq 2 ] && [ $CURRENT_COLS -eq 2 ] && [ $col_delta -lt 0 ] && [ $CURRENT_COL -eq 0 ]; then
    rows=1
    cols=2
    new_row=0
    new_col=0
    snap_to_position $new_row $new_col 1 1 $rows $cols
    return
  fi

  # Moving right from right column -> switch to 1x2 right half
  if [ $CURRENT_ROWS -eq 2 ] && [ $CURRENT_COLS -eq 2 ] && [ $col_delta -gt 0 ] && [ $CURRENT_COL -eq 1 ]; then
    rows=1
    cols=2
    new_row=0
    new_col=1
    snap_to_position $new_row $new_col 1 1 $rows $cols
    return
  fi

  # Moving up from top row -> switch to 3x1 top
  if [ $CURRENT_ROWS -eq 2 ] && [ $CURRENT_COLS -eq 2 ] && [ $row_delta -lt 0 ] && [ $CURRENT_ROW -eq 0 ]; then
    rows=3
    cols=1
    new_row=0
    new_col=0
    snap_to_position $new_row $new_col 1 1 $rows $cols
    return
  fi

  # Moving down from bottom row -> switch to 3x1 bottom
  if [ $CURRENT_ROWS -eq 2 ] && [ $CURRENT_COLS -eq 2 ] && [ $row_delta -gt 0 ] && [ $CURRENT_ROW -eq 1 ]; then
    rows=3
    cols=1
    new_row=2
    new_col=0
    snap_to_position $new_row $new_col 1 1 $rows $cols
    return
  fi

  # Clamp to grid bounds
  if [ $new_row -lt 0 ]; then new_row=0; fi
  if [ $new_row -ge $rows ]; then new_row=$((rows - 1)); fi
  if [ $new_col -lt 0 ]; then new_col=0; fi
  if [ $new_col -ge $cols ]; then new_col=$((cols - 1)); fi

  snap_to_position $new_row $new_col 1 1 $rows $cols
}

# Handle named positions and numeric positions
case $POSITION in
# Relative movements (work with current grid)
up)
  STEPS=${2:-1}
  move_relative -$STEPS 0 $CURRENT_ROWS $CURRENT_COLS
  ;;
down)
  STEPS=${2:-1}
  move_relative $STEPS 0 $CURRENT_ROWS $CURRENT_COLS
  ;;
left)
  # Check if already in a multi-column grid
  if [ $CURRENT_COLS -gt 1 ]; then
    STEPS=${2:-1}
    move_relative 0 -$STEPS $CURRENT_ROWS $CURRENT_COLS
  else
    # Snap to left half (create 1x2 grid)
    ROWS=1
    COLS=2
    snap_to_position 0 0 1 1 $ROWS $COLS
  fi
  ;;
right)
  # Check if already in a multi-column grid
  if [ $CURRENT_COLS -gt 1 ]; then
    STEPS=${2:-1}
    move_relative 0 $STEPS $CURRENT_ROWS $CURRENT_COLS
  else
    # Snap to right half (create 1x2 grid)
    ROWS=1
    COLS=2
    snap_to_position 0 1 1 1 $ROWS $COLS
  fi
  ;;

# Absolute positions - Thirds (vertical)
top)
  snap_to_position 0 0 1 1 3 1
  ;;
mid | middle | center)
  snap_to_position 1 0 1 1 3 1
  ;;
bottom)
  snap_to_position 2 0 1 1 3 1
  ;;

# Quarters (2x2 grid)
topleft | tl)
  snap_to_position 0 0 1 1 2 2
  ;;
topright | tr)
  snap_to_position 0 1 1 1 2 2
  ;;
bottomleft | bl)
  snap_to_position 1 0 1 1 2 2
  ;;
bottomright | br)
  snap_to_position 1 1 1 1 2 2
  ;;

# Fullscreen
full | fullscreen | max | maximize)
  snap_to_position 0 0 $ROWS $COLS $ROWS $COLS
  ;;

# Numeric position (0-indexed grid position)
[0-9]*)
  POS=$POSITION
  ROW=$((POS / COLS))
  COL=$((POS % COLS))

  if [ $ROW -ge $ROWS ]; then
    echo "Error: Position $POS out of bounds for ${ROWS}x${COLS} grid"
    exit 1
  fi

  snap_to_position $ROW $COL 1 1 $ROWS $COLS
  ;;

# Help
help | --help | -h)
  cat <<EOF
Usage: snap_hypr.sh <position> [rows] [cols]

Relative movements (work with current grid):
  up [steps]     - Move up N cells (default: 1)
  down [steps]   - Move down N cells (default: 1)
  left [steps]   - Move left N cells or snap to left half
  right [steps]  - Move right N cells or snap to right half

Absolute positions:
  top, mid/middle/center, bottom  - Vertical thirds
  topleft/tl, topright/tr         - Quarters
  bottomleft/bl, bottomright/br   - Quarters
  full/fullscreen/max/maximize    - Full screen

Numeric positions:
  0-N [rows] [cols] - Grid position (0-indexed, left to right, top to bottom)
  
Examples:
  snap_hypr.sh top          # Snap to top third
  snap_hypr.sh down         # Move down one cell from current position
  snap_hypr.sh down 2       # Move down 2 cells
  snap_hypr.sh up           # Move up one cell
  snap_hypr.sh left         # Snap to left half (or move left in multi-column grid)
  snap_hypr.sh 0 3 3        # Position 0 in 3x3 grid (top-left)
  snap_hypr.sh down         # Now move to position 3 (one down)

The script tracks your current position and grid, allowing relative movements.
State is stored per window in $STATE_DIR
EOF
  exit 0
  ;;

*)
  echo "Error: Unknown position '$POSITION'"
  echo "Run 'snap_hypr.sh help' for usage information"
  exit 1
  ;;
esac