# SoupaWhisper

A simple push-to-talk voice dictation tool for Linux using faster-whisper with CUDA. Hold Scroll Lock, speak, release — text appears wherever your cursor is.

Works in any X11 window: terminals, browsers, editors, Claude Code — everything.

## Prerequisites

- Linux Mint / Ubuntu / Debian (X11, not Wayland)
- NVIDIA GPU with 6GB+ VRAM (or use CPU mode)
- NVIDIA driver installed
- Python 3.10+
- Microphone

## Quick Setup

### 1. Install system dependencies

```bash
sudo apt install -y xdotool xclip portaudio19-dev alsa-utils python3-venv python3-dev
```

### 2. Clone and install

```bash
cd ~/Dev
git clone https://github.com/bozobit/soupawhisper.git
cd soupawhisper
python3 -m venv .venv
.venv/bin/pip install faster-whisper pynput
.venv/bin/pip install nvidia-cublas-cu12 nvidia-cudnn-cu12
```

### 3. Create the config

```bash
mkdir -p ~/.config/soupawhisper
cp config.example.ini ~/.config/soupawhisper/config.ini
```

Edit `~/.config/soupawhisper/config.ini` for GPU mode:

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

### 4. Run it

```bash
./run.sh
```

You should see:
```
SoupaWhisper v0.1.0
Loading Whisper model (small.en)...
Model loaded. Ready for dictation!
Hold [scroll_lock] to record, release to transcribe.
```

Hold Scroll Lock, speak, release. Text appears in the focused window.

## Toggle Command

Create `~/.local/bin/whisper` to start/stop with a single command:

```bash
#!/bin/bash
if pkill -f "soupawhisper/dictate.py"; then
    echo "SoupaWhisper stopped."
else
    ~/Dev/soupawhisper/run.sh &
    disown
    echo "SoupaWhisper started. Hold Scroll Lock to dictate."
fi
```

```bash
chmod +x ~/.local/bin/whisper
```

Now `whisper` starts it, `whisper` again stops it.

## Keyboard Shortcut (Cinnamon)

Set up Ctrl+Scroll Lock to toggle SoupaWhisper from anywhere:

```bash
gsettings set org.cinnamon.desktop.keybindings custom-list "['custom0']"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ name 'SoupaWhisper Toggle'
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ command "$HOME/.local/bin/whisper"
gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:/org/cinnamon/desktop/keybindings/custom-keybindings/custom0/ binding "['<Primary>Scroll_Lock']"
```

Then restart Cinnamon with Ctrl+Alt+Escape.

## Auto-start on Login (Optional)

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

## How run.sh Works

The `run.sh` launcher sets `LD_LIBRARY_PATH` so that faster-whisper can find the CUDA libraries installed via pip (`nvidia-cublas-cu12`, `nvidia-cudnn-cu12`). This avoids needing a system-wide CUDA toolkit installation.

## Configuration

Edit `~/.config/soupawhisper/config.ini`:

| Setting | Options | Description |
|---------|---------|-------------|
| `model` | `tiny.en`, `base.en`, `small.en`, `medium.en`, `large-v3` | Whisper model size |
| `device` | `cpu`, `cuda` | Processing device |
| `compute_type` | `int8` (CPU), `float16` (GPU) | Computation precision |
| `key` | `f12`, `scroll_lock`, `pause`, etc. | Hold-to-record hotkey |
| `auto_type` | `true`, `false` | Type text into active window |
| `notifications` | `true`, `false` | Show desktop notifications |

## Model Sizes

| Model | Size | VRAM | Speed | Accuracy |
|-------|------|------|-------|----------|
| tiny.en | ~75MB | ~1GB | Fastest | Basic |
| base.en | ~150MB | ~1GB | Fast | Good |
| small.en | ~500MB | ~2GB | Medium | Better |
| medium.en | ~1.5GB | ~5GB | Slower | Great |
| large-v3 | ~3GB | ~6GB | Slowest | Best |

For dictation, `small.en` is the sweet spot on a 6GB GPU.

## Troubleshooting

- **"Library libcublas.so.12 is not found"** — install `nvidia-cublas-cu12` and `nvidia-cudnn-cu12` pip packages, and use `run.sh` (not `python dictate.py` directly)
- **No output when running** — add `PYTHONUNBUFFERED=1` before the python command in run.sh
- **evdev build fails** — install `python3-dev` (`sudo apt install python3-dev`)
- **Model too slow** — downgrade to `base.en` in config.ini
- **Want better accuracy** — upgrade to `medium.en` (uses ~5GB VRAM)
- **No audio recording** — check `arecord -l` and test with `arecord -d 3 test.wav && aplay test.wav`
- **Permission issues with keyboard** — `sudo usermod -aG input $USER` then log out and back in

## License

MIT

## Credits

Originally based on [ksred/soupawhisper](https://github.com/ksred/soupawhisper). This fork adds a CUDA launcher script and setup guide.
