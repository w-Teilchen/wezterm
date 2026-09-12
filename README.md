# wezterm
This project contains everything concerning my WezTerm settings.

One `.wezterm.lua` for every machine; platform differences are guarded inside it
(`wezterm.target_triple`).

## Setup

Linux (Starfield):

```sh
mkdir -p ~/.config/wezterm
ln -s ~/code/wezterm/.wezterm.lua ~/.config/wezterm/wezterm.lua
```

Install the nightly build (`wezterm-nightly` from the official APT repo, see
https://wezterm.org/install/linux.html). The Flathub build (20240203) crashes on
GNOME Wayland at scale 2 (wezterm/wezterm#7333, fixed in #7746, nightly only).

Windows: point WezTerm at the clone, e.g. set the user environment variable
`WEZTERM_CONFIG_FILE` to `<clone>\.wezterm.lua`.
