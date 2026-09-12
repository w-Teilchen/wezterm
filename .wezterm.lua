local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Shared between the Windows machine (WSL) and Linux (Starfield).
local is_windows = wezterm.target_triple:find 'windows' ~= nil
local is_linux = wezterm.target_triple:find 'linux' ~= nil

if is_windows then
  config.default_domain = 'WSL:Ubuntu'
end

if is_linux then
  -- GNOME Wayland: a borderless native-Wayland window can't be moved or resized
  -- (wezterm/wezterm#5332; fix pending in PR #7095). Run on XWayland until then.
  config.enable_wayland = false
end

----------------------------------------------------------------------------
-- Look
----------------------------------------------------------------------------

config.color_scheme = 'tokyonight_night' -- alternative: 'Catppuccin Mocha'
config.font = wezterm.font 'JetBrains Mono' -- bundled, Nerd Font symbols built in
config.font_size = is_linux and 12.0 or 11.0 -- Starfield runs GNOME at scale 2
config.line_height = 1.1

-- No title bar. On Linux, move the window with Super+drag and resize with
-- Super+middle-drag. 'RESIZE' still shows a title bar on X11 under GNOME
-- (wezterm/wezterm#3936), so Linux gets 'NONE'.
config.window_decorations = is_linux and 'NONE' or 'RESIZE'
-- The tab bar only appears once a second tab exists (Ctrl+Shift+T), so a new
-- tab is never invisible.
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = '1cell', right = '1cell', top = '0.5cell', bottom = '0.5cell' }

-- Without tabs, the dimmed inactive panes are what shows focus.
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.6 }
config.default_cursor_style = 'SteadyBar'
config.colors = {
  -- The cursor turns orange while the leader (Ctrl+a) is armed: the stand-in
  -- for the status area that went away with the tab bar.
  compose_cursor = '#ff9e64',
}

config.scrollback_lines = 20000

----------------------------------------------------------------------------
-- Mouse
----------------------------------------------------------------------------

-- When an app (e.g. OpenCode) enables mouse reporting, WezTerm normally passes
-- all mouse events to it. bypass_mouse_reporting_modifiers makes WezTerm
-- intercept the event itself when CTRL is held, so Ctrl+Click still opens links.
config.bypass_mouse_reporting_modifiers = 'CTRL'

-- Open hyperlinks with Ctrl+Click
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

----------------------------------------------------------------------------
-- Keys: tmux-style, leader Ctrl+a
----------------------------------------------------------------------------

config.key_map_preference = 'Mapped'
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- tmux-style repeatable resize (tmux `bind -r C-Arrow`): Leader, then keep Ctrl
-- held and tap or hold the arrows. The first press resizes and enters the
-- resize_pane table; each further Ctrl+arrow within 1s resizes again and
-- restarts the timer. No until_unknown: it would also end the mode on a bare
-- Ctrl press, i.e. when you re-grip. Other keys pass through to the shell.
local function resize(direction)
  return act.Multiple {
    act.AdjustPaneSize { direction, 1 },
    act.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
      timeout_milliseconds = 1000,
    },
  }
end

local arrows = {
  LeftArrow = 'Left',
  RightArrow = 'Right',
  UpArrow = 'Up',
  DownArrow = 'Down',
}

config.keys = {
  {
    key = 'mapped:<',
    mods = 'LEADER',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'mapped:-',
    mods = 'LEADER',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'x',
    mods = 'LEADER',
    action = act.CloseCurrentPane { confirm = false },
  },
  -- Zoom the current pane to the full window and back (tmux prefix z)
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  -- Show pane labels, jump to one by letter (tmux prefix q)
  { key = 'q', mods = 'LEADER', action = act.PaneSelect },
  -- Pick a pane by label and swap it with the current one
  { key = 's', mods = 'LEADER', action = act.PaneSelect { mode = 'SwapWithActive' } },
  -- Copy mode (tmux prefix [, which is AltGr+8 on a German layout)
  { key = 'v', mods = 'LEADER', action = act.ActivateCopyMode },
  -- Persistent shell on the hermes VM: split and attach tmux session 'main',
  -- creating it if needed. Own tmux server (-L soeren), so the agent's tmux
  -- use on the VM can't take it down. Inside, the tmux prefix is Ctrl+b.
  {
    key = 'h',
    mods = 'LEADER',
    action = act.SplitHorizontal {
      args = { 'ssh', '-t', 'hermes', 'tmux', '-L', 'soeren', 'new', '-A', '-s', 'main' },
    },
  },
  -- Ctrl+a twice sends a literal Ctrl+a (beginning of line in the shell)
  {
    key = 'a',
    mods = 'LEADER|CTRL',
    action = act.SendKey { key = 'a', mods = 'CTRL' },
  },
}

config.key_tables = {
  resize_pane = {
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
}

for key, direction in pairs(arrows) do
  -- Leader, arrow: move to the neighbouring pane
  table.insert(config.keys, {
    key = key,
    mods = 'LEADER',
    action = act.ActivatePaneDirection(direction),
  })
  -- Leader, Ctrl+arrow: resize (repeatable)
  table.insert(config.keys, {
    key = key,
    mods = 'LEADER|CTRL',
    action = resize(direction),
  })
  table.insert(config.key_tables.resize_pane, {
    key = key,
    mods = 'CTRL',
    action = act.AdjustPaneSize { direction, 1 },
  })
end

return config
