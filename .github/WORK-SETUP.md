# Work machine setup (Windows + WSL)

Everything lives in the WSL filesystem except one stub file. Total setup is
~10 minutes, most of it downloads.

## 1. Windows side (once)

```powershell
# In PowerShell:
winget install wez.wezterm
wsl --install -d Ubuntu        # if WSL isn't set up yet
wsl -l                         # note the distro name for step 3
```

## 2. WSL side

```sh
sudo apt update && sudo apt install -y git curl zsh build-essential unzip

# yadm (single script, no packaging needed)
curl -fsSLo ~/.local/bin/yadm --create-dirs https://github.com/yadm-dev/yadm/raw/master/yadm
chmod +x ~/.local/bin/yadm
export PATH="$HOME/.local/bin:$PATH"

# SSH key for GitHub (or use HTTPS + gh auth login after bootstrap)
ssh-keygen -t ed25519 -C "erik@eriklorenz.dev"   # add to GitHub

yadm clone git@github.com:erlorenz/dotfiles.git   # bootstrap runs automatically
```

yadm detects WSL and symlinks `os.zsh -> os.zsh##os.WSL` automatically.

## 3. Connect WezTerm to WSL (once)

Copy the stub so WezTerm loads the real (synced) config from WSL:

```powershell
# In PowerShell — adjust distro/user if not Ubuntu/erik:
Copy-Item \\wsl$\Ubuntu\home\erik\.config\wezterm\windows-stub.lua $HOME\.wezterm.lua
```

Launch WezTerm. It reads the config over `\\wsl$` (booting WSL if needed,
~1–2s once per Windows boot) and every pane opens directly in WSL. Panes are
native WezTerm — no tmux, no translation layers.

## 4. Verify

- new pane is a zsh prompt in WSL with the starship prompt
- `nvim` → tokyonight, `<Space>f` picks files, Ctrl+Space completes in code
- `dev claude` splits into the editor/agent/terminal layout
- `dotsync` pushes; at home `dots pull` picks it up

## If something misbehaves

- **Stub can't find config**: check the distro name in `C:\Users\<you>\.wezterm.lua`
  against `wsl -l` output.
- **WSL-domain quirks (panes not spawning, resize weirdness)**: install
  WezTerm **nightly** (`winget install wez.wezterm --version nightly` or from
  GitHub releases) — the stable release is from Feb 2024 and several WSL
  fixes landed after.
- **`wezterm.exe` not found inside WSL** (layout functions fail): Windows
  interop is off, or WezTerm isn't on the Windows PATH — reinstall with
  winget and restart WSL (`wsl --shutdown`).

## SSH dev box (future)

Same as WSL steps minus everything Windows: apt prereqs → yadm → clone.
Terminal stays local (WezTerm on the machine in front of you); the box just
needs the shell/editor/tools, which is exactly what bootstrap installs.
