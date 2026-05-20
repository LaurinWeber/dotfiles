local wezterm = require 'wezterm'
local act = wezterm.action

-- =========================================================
-- ATTENTION STATE (persists across status redraws)
-- =========================================================

wezterm.GLOBAL.attention = wezterm.GLOBAL.attention or {}

local function set_attention(pane_id, val)
  wezterm.GLOBAL.attention[tostring(pane_id)] = val and true or nil
end

local function get_attention(pane_id)
  return wezterm.GLOBAL.attention[tostring(pane_id)] == true
end

-- =========================================================
-- HELPERS
-- =========================================================

local function get_cwd_raw(pane)

  local cwd_uri = pane:get_current_working_dir()
  local cwd = nil

  if cwd_uri then
    cwd = cwd_uri.file_path or cwd_uri.path
  end

  if not cwd or cwd == "" then
    local ok, proc = pcall(function() return pane:get_foreground_process_info() end)
    if ok and proc and proc.cwd then
      cwd = proc.cwd
    end
  end

  if not cwd or cwd == "" then return "" end

  -- Windows URI quirk: /C:/Users/... -> C:/Users/...
  if cwd:match("^/[A-Za-z]:") then cwd = cwd:sub(2) end

  cwd = cwd:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
  cwd = cwd:gsub("[/\\]+$", "")
  return cwd
end

-- Full path with forward slashes (no ~ substitution -- keeps the C:/... prefix)
local function full_path(cwd)
  if cwd == "" then return "" end
  return (cwd:gsub("\\", "/"))
end

-- Per-directory git branch cache: avoids spawning git on every update-status tick.
-- Each unique cwd gets its own entry so multiple panes on different projects
-- always show their own correct branch. Max staleness = GIT_CACHE_TTL seconds.
wezterm.GLOBAL.git_cache = wezterm.GLOBAL.git_cache or {}
local GIT_CACHE_TTL = 5

local function git_branch(cwd)
  if cwd == "" then return nil end

  local now     = os.time()
  local cached  = wezterm.GLOBAL.git_cache[cwd]

  if cached and (now - cached.ts) < GIT_CACHE_TTL then
    return cached.branch  -- may be nil for non-git dirs, that's fine
  end

  local ok, stdout = wezterm.run_child_process({
    "git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"
  })

  local branch = nil
  if ok then
    branch = (stdout or ""):gsub("[\r\n%s]+$", "")
    if branch == "" then branch = nil end
  end

  -- Cache the result (including nil) so non-git dirs don't keep retrying
  wezterm.GLOBAL.git_cache[cwd] = { branch = branch, ts = now }
  return branch
end

-- Pull the claude profile from a user-var set by claudep / claudew.
-- "private" -> "Claude Private", "work" -> "Claude Work", anything else -> "Default".
local function context_name(pane)
  local user_vars = pane:get_user_vars() or {}
  local profile = user_vars["claude_profile"]
  if profile == "private" then return "Claude Private" end
  if profile == "work"    then return "Claude Work"    end
  return "Default"
end

-- =========================================================
-- STATUS BAR
-- =========================================================

wezterm.on("update-status", function(window, pane)

  -- Auto-clear attention when the user navigates TO a waiting pane
  wezterm.GLOBAL.last_active = wezterm.GLOBAL.last_active or {}
  local win_key = tostring(window:window_id())
  local curr_id = pane:pane_id()
  if wezterm.GLOBAL.last_active[win_key] ~= curr_id then
    wezterm.GLOBAL.last_active[win_key] = curr_id
    set_attention(curr_id, false)
  end

  local raw_cwd = get_cwd_raw(pane)
  local cwd     = full_path(raw_cwd)
  local branch  = git_branch(raw_cwd)
  local name    = context_name(pane)
  local pane_id = pane:pane_id()
  local waiting = get_attention(pane_id)

  -------------------------------------------------
  -- LEFT STATUS:  [name | WAITING]  [full path]
  -------------------------------------------------

  local left = {}

  if waiting then
    table.insert(left, { Background = { Color = "#f1c232" } })
    table.insert(left, { Foreground = { Color = "#1a1a1a" } })
    table.insert(left, { Attribute = { Intensity = "Bold" } })
    table.insert(left, { Text = "  WAITING  " })
    table.insert(left, "ResetAttributes")
  else
    table.insert(left, { Foreground = { Color = "#dddddd" } })
    table.insert(left, { Attribute = { Intensity = "Bold" } })
    table.insert(left, { Text = "  " .. name })
    table.insert(left, "ResetAttributes")
  end

  if cwd ~= "" then
    table.insert(left, { Foreground = { Color = "#6fa8dc" } })
    table.insert(left, { Text = "  " .. cwd .. "  " })
  end

  window:set_left_status(wezterm.format(left))

  -------------------------------------------------
  -- RIGHT STATUS:  [branch]
  -------------------------------------------------

  if branch then
    window:set_right_status(wezterm.format({
      { Foreground = { Color = "#6aa84f" } },
      { Text = "  " .. branch .. "  " },
    }))
  else
    window:set_right_status("")
  end
end)

-- =========================================================
-- AI AGENT NOTIFICATIONS
-- =========================================================

wezterm.on("bell", function(window, pane)
  set_attention(pane:pane_id(), true)

  local title = pane:get_title()
  if title == nil or title == "" then title = "Terminal" end

  window:toast_notification("Claude needs input", title, nil, 8000)
end)

wezterm.on("user-var-changed", function(window, pane, name, value)
  if name == "claude_status" or name == "ai_status" then
    if value == "waiting" or value == "needs_input" then
      set_attention(pane:pane_id(), true)
      window:toast_notification("Claude needs input", value, nil, 8000)
    else
      set_attention(pane:pane_id(), false)
    end
  end
end)

-- Auto-clear attention when the user ALT+TABs back to WezTerm
wezterm.on("window-focus-changed", function(window, pane)
  if window:is_focused() then
    set_attention(pane:pane_id(), false)
  end
end)

-- Suppress the tab text in the bottom bar (already shown in the top title bar)
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  return ""
end)

-- =========================================================
-- MAIN CONFIG
-- =========================================================

return {

  default_prog = { "pwsh.exe", "-NoLogo" },

  front_end     = "WebGpu",
  max_fps       = 120,
  animation_fps = 1,

  font_size   = 14,
  line_height = 1.1,

  scrollback_lines  = 200000,
  enable_scroll_bar = true,

  audible_bell          = "Disabled",
  notification_handling = "AlwaysShow",

  -- Standard Windows title bar (drag + min / max / close)
  window_decorations = "TITLE | RESIZE",

  adjust_window_size_when_changing_font_size = false,

  window_padding = {
    left   = 8,
    right  = 8,
    top    = 8,
    bottom = 8,
  },

  -- Tab bar at the bottom (tab text suppressed by format-tab-title above)
  use_fancy_tab_bar              = false,
  tab_bar_at_bottom              = true,
  hide_tab_bar_if_only_one_tab   = false,
  show_new_tab_button_in_tab_bar = false,
  tab_max_width                  = 32,

  inactive_pane_hsb = {
    saturation = 0.5,
    brightness = 0.2,
  },

  disable_default_key_bindings = true,

  keys = {

    -- Pane Splits
    { key = "V", mods = "ALT|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "B", mods = "ALT|SHIFT", action = act.SplitVertical   { domain = "CurrentPaneDomain" } },

    -- Pane Navigation
    { key = "h", mods = "ALT", action = act.ActivatePaneDirection "Left"  },
    { key = "j", mods = "ALT", action = act.ActivatePaneDirection "Down"  },
    { key = "k", mods = "ALT", action = act.ActivatePaneDirection "Up"    },
    { key = "l", mods = "ALT", action = act.ActivatePaneDirection "Right" },

    -- Pane Resize
    { key = "h", mods = "CTRL|ALT", action = act.AdjustPaneSize { "Left",  5 } },
    { key = "j", mods = "CTRL|ALT", action = act.AdjustPaneSize { "Down",  3 } },
    { key = "k", mods = "CTRL|ALT", action = act.AdjustPaneSize { "Up",    3 } },
    { key = "l", mods = "CTRL|ALT", action = act.AdjustPaneSize { "Right", 5 } },

    -- Close Pane
    { key = "Q", mods = "ALT|SHIFT", action = act.CloseCurrentPane { confirm = false } },

    -- Tabs
    { key = "T", mods = "ALT|SHIFT", action = act.SpawnTab "CurrentPaneDomain" },
    { key = "N", mods = "ALT|SHIFT", action = act.ActivateTabRelative(1)  },
    { key = "P", mods = "ALT|SHIFT", action = act.ActivateTabRelative(-1) },

    -- Utilities
    { key = "F",     mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "Space", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
    { key = "C",     mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard"   },
    { key = "V",     mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard"},
    { key = "R",     mods = "CTRL|SHIFT", action = act.ReloadConfiguration  },

    -- Clear AI attention indicator on active pane
    {
      key = "K",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        wezterm.GLOBAL.attention[tostring(pane:pane_id())] = nil
        window:toast_notification("AI", "Attention cleared", nil, 1500)
      end),
    },
  },
}