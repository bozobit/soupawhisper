# SoupaWhisper Setup Guide

Push-to-talk voice dictation for Linux using faster-whisper with CUDA. Hold Scroll Lock, speak, release — text appears wherever your cursor is.

## Prerequisites

- Linux Mint / Ubuntu (X11, not Wayland)
- NVIDIA GPU with 6GB+ VRAM
- NVIDIA driver installed
- Microphone

## Step 1: Install system dependencies

```bash
sudo apt install -y xdotool xclip portaudio19-dev alsa-utils python3-venv python3-dev
```

## Step 2: Clone and set up SoupaWhisper

```bash
cd ~/Dev
git clone https://github.com/ksred/soupawhisper.git
cd soupawhisper
python3 -m venv .venv
.venv/bin/pip install faster-whisper pynput
.venv/bin/pip install nvidia-cublas-cu12 nvidia-cudnn-cu12
```

## Step 3: Create the launcher script

Create `~/Dev/soupawhisper/run.sh`:

```bash
#!/bin/bash
VENV="/home/$USER/Dev/soupawhisper/.venv"
NVIDIA_LIBS="$VENV/lib/python3.12/site-packages/nvidia"
export LD_LIBRARY_PATH="$NVIDIA_LIBS/cublas/lib:$NVIDIA_LIBS/cudnn/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$VENV/bin/python" "/home/$USER/Dev/soupawhisper/dictate.py" "$@"
```

```bash
chmod +x ~/Dev/soupawhisper/run.sh
```

## Step 4: Configure for CUDA + small.en model

```bash
mkdir -p ~/.config/soupawhisper
```

Create `~/.config/soupawhisper/config.ini`:

```ini
[whisper]
model = small.en
device = cuda
compute_type = float16

[hotkey]
key = scroll_lock

[behavior]
auto_type = true
notifications = true
```

## Step 5: Test it

```bash
~/Dev/soupawhisper/run.sh
```

You should see:
```
SoupaWhisper v0.1.0
Loading Whisper model (small.en)...
Model loaded. Ready for dictation!
Hold [scroll_lock] to record, release to transcribe.
```

Hold Scroll Lock, speak, release. Text should appear in the focused window.

## Step 6: Create toggle command

Create `~/.local/bin/whisper`:

```bash
#!/bin/bash
if pkill -f "soupawhisper/dictate.py"; then
    echo "SoupaWhisper stopped."
else
    /home/$USER/Dev/soupawhisper/run.sh &
    disown
    echo "SoupaWhisper started. Hold Scroll Lock to dictate."
fi
```

```bash
chmod +x ~/.local/bin/whisper
```

Now `whisper` starts it, `whisper` again stops it.

## Step 7: Keyboard shortcut (Ctrl+Scroll Lock toggle)

For Cinnamon desktop:

```bash
# Check existing custom shortcuts
gsettings get org.cinnamon.desktop.keybindings custom-list

# If empty (@as []), use custom0:
gsettings set org.cinnamon.desktop.keybindings custom-list "['custom0']"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name 'SoupaWhisper Toggle'
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command "$HOME/.local/bin/whisper"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding "['<Primary>Scroll_Lock']"
```

Then restart Cinnamon with Ctrl+Alt+Escape.

## Step 8: Auto-start on login (optional)

Create `~/.config/autostart/soupawhisper.desktop`:

```ini
[Desktop Entry]
Type=Application
Name=SoupaWhisper
Comment=Push-to-talk voice dictation
Exec=/home/YOUR_USERNAME/Dev/soupawhisper/run.sh
Terminal=false
X-GNOME-Autostart-enabled=true
```

## Troubleshooting

- **"Library libcublas.so.12 is not found"** — the nvidia-cublas-cu12 and nvidia-cudnn-cu12 pip packages aren't installed, or run.sh isn't setting LD_LIBRARY_PATH
- **No output when running** — add `PYTHONUNBUFFERED=1` before the python command
- **Model too slow** — downgrade to `base.en` in config.ini (faster, less accurate)
- **Want better accuracy** — upgrade to `medium.en` in config.ini (uses ~5GB VRAM)
- **evdev build fails** — install `python3-dev` (`sudo apt install python3-dev`)
