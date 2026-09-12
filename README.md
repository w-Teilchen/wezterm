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

## Cheat sheet

Most keys start with the **leader, Ctrl+a**: press Ctrl+a, let go, then press the
key within one second. While the leader is waiting, the cursor turns orange.

### Panes

| Keys | What it does |
|---|---|
| Ctrl+a `<` | split side by side |
| Ctrl+a `-` | split top / bottom |
| Ctrl+a ←↑→↓ | move to the pane in that direction |
| Ctrl+a, then **keep Ctrl held** + ←↑→↓ | resize the pane — tap or hold the arrows; stops after 1 s idle or Esc |
| Ctrl+a `z` | zoom the pane to the full window, and back |
| Ctrl+a `q` | show a letter on each pane, press one to jump there |
| Ctrl+a `s` | show letters, press one to swap that pane with the current one |
| Ctrl+a `x` | close the pane — **no confirmation**, whatever runs in it is gone |
| Ctrl+a Ctrl+a | a real Ctrl+a for the shell (jump to start of line) |

### Copying, searching, scrolling

| Keys | What it does |
|---|---|
| select with the mouse | copies straight to the clipboard (double-click: word, triple-click: line) |
| Ctrl+Shift+C / Ctrl+Shift+V | copy / paste |
| Ctrl+Shift+F | search the scrollback |
| Ctrl+a `v` | copy mode: move with the arrows or vim keys, `v` select, `V` select lines, `y` copy and leave, `q` / Esc leave |
| click / Ctrl+click | open a link; inside apps that capture the mouse, only Ctrl+click works |
| Shift+PageUp / PageDown, mouse wheel | scroll back (20,000 lines per pane) |

### Window and more

| Keys | What it does |
|---|---|
| Super+drag | move the window (there is no title bar) |
| Super+middle-drag | resize the window |
| Ctrl+`+` / Ctrl+`-` / Ctrl+`0` | font bigger / smaller / reset |
| Ctrl+Shift+P | command palette: search every WezTerm action by name |
| Ctrl+Shift+T | new tab — the tab bar appears once there are two |

### Remote

| Keys | What it does |
|---|---|
| Ctrl+a `h` | open a split with a tmux session on the `hermes` server (needs `ssh hermes` to work). Closing the pane or losing the network keeps the session alive; Ctrl+a `h` again returns to it. Each local user gets their own session. |

Inside that tmux session the tmux prefix is **Ctrl+b** (not Ctrl+a): Ctrl+b `<` /
`-` split, Ctrl+b `x` closes, the mouse wheel scrolls, Ctrl+b `d` detaches.
