
#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Logitech Webcam Pro 9000 (046d:0809) one-shot control applier
#
# Usage:
#   ./webcam-pro9000-oneshot.sh              # uses default device (/dev/video33)
#   ./webcam-pro9000-oneshot.sh /dev/video0  # choose device
#   ./webcam-pro9000-oneshot.sh --dry-run    # print commands only
#
# Notes:
# - Some controls show "flags=inactive" until their corresponding AUTO control
#   is disabled. So we disable auto_exposure and white_balance_automatic first,
#   then set exposure_time_absolute / white_balance_temperature.
# - V4L2 settings are generally shared system-wide for that camera, but they
#   usually reset when the device is unplugged/replugged. [2](https://wiki.archlinux.org/title/Webcam_setup)
# -----------------------------------------------------------------------------

DEV="${1:-/dev/video33}"
DRY_RUN=0

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  DEV="/dev/video33"
fi

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ $*"
  else
    eval "$@"
  fi
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: Missing required command: $1"
    echo "Install with: sudo apt install v4l-utils"
    exit 1
  }
}

need_cmd v4l2-ctl

if [[ ! -e "$DEV" ]]; then
  echo "ERROR: Device not found: $DEV"
  echo "Hint: run 'v4l2-ctl --list-devices' to locate the right /dev/videoX"
  exit 1
fi

# -----------------------------
# (A) Optional: Force format/FPS
# -----------------------------
# Comment this section out if you prefer Edge/WebRTC to negotiate formats itself.
WIDTH=1280
HEIGHT=720
FPS=30
PIX="MJPG"

# -----------------------------
# (B) Tweakable image controls
# -----------------------------
# User Controls

BRIGHTNESS=150         # was 107  (+18)  -> slightly brighter mid-tones
CONTRAST=35            # was 29   (+11)  -> a bit more punch
SATURATION=15          # was 17   (-4)   -> tones down color
GAIN=128               # was 64   (+16)  -> small brightness boost; watch for noise
POWER_LINE=1           # keep 50 Hz
SHARPNESS=50           # (191)keep as-is (already high)
BACKLIGHT_COMP=0       # keep as-is

# White balance
WB_AUTO=0              # 0=manual, 1=auto
WB_TEMP=6500           # 0..10000 step 10 (active only when WB_AUTO=0)

# Camera Controls
AUTO_EXPOSURE=1        # menu: 1=Manual Mode, 3=Aperture Priority Mode
EXPOSURE_ABS=150       # 1..10000 (active only when AUTO_EXPOSURE=1)
EXP_DYN_FR=0           # exposure_dynamic_framerate (bool)

FOCUS_ABS=96           # 0..255 (0 often means infinity on some Logitech cams)

# Logitech extension controls (optional)
LED_MODE=3             # 0 Off, 1 On, 2 Blinking, 3 Auto
DISABLE_VIDEO_PROC=0   # 0/1  (try 1 if you want less internal processing)
RAW_BPP=1              # 0/1  (as reported by your device)

echo "Applying settings to: $DEV"
echo

echo "1) Setting format: ${WIDTH}x${HEIGHT} ${PIX} @ ${FPS}fps"
run "v4l2-ctl -d '$DEV' --set-fmt-video=width=${WIDTH},height=${HEIGHT},pixelformat=${PIX} --set-parm=${FPS}"

echo
echo "2) Disabling auto modes first (to un-inactivate dependent controls)"
# Disable auto WB and set manual temperature afterward
run "v4l2-ctl -d '$DEV' --set-ctrl=white_balance_automatic=${WB_AUTO}"
# Disable auto exposure and set manual exposure afterward
run "v4l2-ctl -d '$DEV' --set-ctrl=auto_exposure=${AUTO_EXPOSURE},exposure_dynamic_framerate=${EXP_DYN_FR}"

echo
echo "3) Applying image controls"
# You can set multiple controls in one --set-ctrl call by separating with commas. [1](https://linuxcommandlibrary.com/man/v4l2-ctl)
run "v4l2-ctl -d '$DEV' --set-ctrl=brightness=${BRIGHTNESS},contrast=${CONTRAST},saturation=${SATURATION},gain=${GAIN},power_line_frequency=${POWER_LINE},sharpness=${SHARPNESS},backlight_compensation=${BACKLIGHT_COMP}"

echo
echo "4) Applying manual WB + manual exposure (now that auto is disabled)"
run "v4l2-ctl -d '$DEV' --set-ctrl=white_balance_temperature=${WB_TEMP}"
run "v4l2-ctl -d '$DEV' --set-ctrl=exposure_time_absolute=${EXPOSURE_ABS}"

echo
echo "5) Optional camera controls"
run "v4l2-ctl -d '$DEV' --set-ctrl=focus_absolute=${FOCUS_ABS},led1_mode=${LED_MODE},disable_video_processing=${DISABLE_VIDEO_PROC},raw_bits_per_pixel=${RAW_BPP}"

echo
echo "Done. Current controls:"
run "v4l2-ctl -d '$DEV' --list-ctrls-menu"
