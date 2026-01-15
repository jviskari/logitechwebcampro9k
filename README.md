# Logitech Webcam Pro 9000 Control Script

A bash script to configure and optimize settings for the Logitech Webcam Pro 9000 (USB ID: 046d:0809) on Linux systems using V4L2 (Video4Linux2) controls.

---

## Why This Script Might Be Useful (Even If It Won’t Make You Look Better)

Modern video apps often assume you have a recent camera, good lighting, and built‑in “AI” image tweaks. Reality is usually different:

- **Video is mandatory in tools like Microsoft Teams**, but the Linux client (or web version) often exposes *no* camera controls: no sliders for brightness, contrast, saturation, or focus. You just appear how the app decides you should appear.
- **Your face can look noticeably worse on camera than in a mirror**: washed out, overly contrasty, weirdly colored, or noisy. That’s usually not *you*—it’s the combination of old hardware, bad auto-exposure, and questionable defaults.
- **Not everyone has a new webcam or a ring light.** The Logitech Webcam Pro 9000 is perfectly usable, but its automatic settings and factory defaults are tuned for “good enough” under generic conditions, not for your specific desk, room, or monitor glow.

This script is for that situation:

- It **does not make you more attractive** or “fix” your appearance.
- It **does give you technical control** over the camera: exposure, white balance, brightness, contrast, saturation, focus, and more.
- It lets you **dial in a less awful baseline** for how your webcam behaves, *before* Teams (or any other app) touches the video stream.

Think of it as replacing “mystery automatic mode” with a set of **sane, reproducible defaults** for an older webcam. You still have the same face and the same lighting—but at least the camera isn’t making them worse than they need to be.

---

## What It Does

This script applies a comprehensive set of camera controls to your Logitech Webcam Pro 9000, including:

- **Video Format**: Sets resolution (1280x720), pixel format (MJPEG), and frame rate (30fps)
- **Image Quality**: Adjusts brightness, contrast, saturation, gain, and sharpness
- **Exposure Control**: Configures manual exposure settings for consistent lighting
- **White Balance**: Sets manual white balance temperature (6500K by default)
- **Focus**: Sets manual focus position
- **Additional Controls**: Power line frequency (50/60Hz), backlight compensation, LED mode, and more

The script disables automatic modes first (auto-exposure, auto-white-balance) to ensure manual settings take effect properly, as some V4L2 controls remain inactive until their corresponding auto modes are disabled.

## Why Use This Script?

- **Consistency**: V4L2 settings reset when the webcam is unplugged/replugged. This script quickly reapplies your preferred configuration.
- **Quality**: Default auto settings may not be optimal for your lighting conditions. Manual control gives better, more predictable results.
- **Convenience**: One command applies all settings instead of manually adjusting each control.

## Requirements

### Debian/Ubuntu-based Systems

Install the required package:

```bash
sudo apt update
```

```bash
sudo apt install v4l-utils
```

**Package details:**
- `v4l-utils` - Provides `v4l2-ctl` command-line tool for controlling Video4Linux2 devices

### Optional (for testing/verification)

```bash
sudo apt install guvcview
```

This provides a GUI application to preview your webcam and verify settings.

## Usage

### Basic Usage (Default Device)

```bash
./webcam9000.sh
```

Uses `/dev/video33` as the default device.

### Specify Custom Device

```bash
./webcam9000.sh /dev/video0
```

### Dry Run (Preview Commands)

```bash
./webcam9000.sh --dry-run
```

Prints all commands without executing them.

### Find Your Webcam Device

```bash
v4l2-ctl --list-devices
```

Look for "Logitech Webcam Pro 9000" in the output to identify the correct `/dev/videoX` device.

## Configuration

Edit the script to customize settings for your environment:

### Video Format (Lines 68-71)
```bash
WIDTH=1280
HEIGHT=720
FPS=30
PIX="MJPG"
```

### Image Controls (Lines 77-84)
```bash
BRIGHTNESS=150      # 0-255
CONTRAST=35         # 0-64
SATURATION=15       # 0-128
GAIN=128            # 0-255
SHARPNESS=50        # 0-255
BACKLIGHT_COMP=0    # 0-1
```

### White Balance (Lines 87-88)
```bash
WB_AUTO=0           # 0=manual, 1=auto
WB_TEMP=6500        # 0-10000 (Kelvin)
```

### Exposure (Lines 91-93)
```bash
AUTO_EXPOSURE=1     # 1=Manual, 3=Aperture Priority
EXPOSURE_ABS=150    # 1-10000
```

### Focus (Line 95)
```bash
FOCUS_ABS=96        # 0-255 (0 often = infinity)
```

## Troubleshooting

### Device Not Found
```bash
v4l2-ctl --list-devices
```
Use the output to find the correct device path.

### Permission Denied
Add your user to the `video` group:

```bash
sudo usermod -aG video $USER
```

Then log out and log back in.

### Settings Don't Persist
V4L2 settings are system-wide but reset when the camera is unplugged. Consider:
- Running this script at startup
- Creating a udev rule to trigger the script when the camera is connected

### View Current Settings

```bash
v4l2-ctl -d /dev/video33 --list-ctrls-menu
```

## Making It Executable

```bash
chmod +x webcam9000.sh
```

## Auto-Run on Startup (Optional)

Create a systemd user service or add to your desktop environment's startup applications.

## References

- [Arch Linux Webcam Setup Guide](https://wiki.archlinux.org/title/Webcam_setup)
- [v4l2-ctl Manual](https://linuxcommandlibrary.com/man/v4l2-ctl)

## License

This script is provided as-is for configuring Logitech Webcam Pro 9000 devices.

## Notes

- Settings are shared system-wide for the camera
- Settings reset on device reconnection
- Some applications (like browsers) may override certain settings
- Test settings with your specific lighting conditions for best results
