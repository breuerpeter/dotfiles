local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	if mux then
		local tab, pane, window = mux.spawn_window(cmd or {})
		window:gui_window():maximize()
	end
end)

-- Simple session manager (tabs only: cwd and name)
local session_dir = wezterm.home_dir .. "/.local/state/wezterm/"

local function get_session_path(workspace)
	return session_dir .. workspace .. ".json"
end

local function save_session(window)
	local workspace = window:active_workspace()
	local tabs = {}

	for _, mux_win in ipairs(mux.all_windows()) do
		if mux_win:get_workspace() == workspace then
			for _, tab in ipairs(mux_win:tabs()) do
				local pane = tab:active_pane()
				local cwd_url = pane:get_current_working_dir()
				table.insert(tabs, {
					name = tab:get_title(),
					cwd = cwd_url and cwd_url.file_path or wezterm.home_dir,
				})
			end
			break
		end
	end

	os.execute("mkdir -p " .. session_dir)
	local file = io.open(get_session_path(workspace), "w")
	if file then
		file:write(wezterm.json_encode(tabs))
		file:close()
	end

	window:toast_notification("Session", "Saved: " .. workspace, nil, 3000)
end

local function restore_session(window)
	local workspace = window:active_workspace()
	local file = io.open(get_session_path(workspace), "r")
	if not file then
		window:toast_notification("Session", "No saved session for: " .. workspace, nil, 3000)
		return
	end

	local data = file:read("*a")
	file:close()
	local ok, tabs = pcall(wezterm.json_parse, data)
	if not ok or not tabs or #tabs == 0 then
		window:toast_notification("Session", "Failed to parse session", nil, 3000)
		return
	end

	local mux_win = window:mux_window()
	local old_tab_ids = {}
	for _, tab in ipairs(mux_win:tabs()) do
		table.insert(old_tab_ids, tab:tab_id())
	end

	-- Spawn all new tabs
	for _, tab_data in ipairs(tabs) do
		local cwd = tab_data.cwd or wezterm.home_dir
		local tab, _, _ = mux_win:spawn_tab({ cwd = cwd })
		tab:set_title(tab_data.name or "")
	end

	-- Close old tabs by activating and closing each one
	for _, old_id in ipairs(old_tab_ids) do
		for _, tab in ipairs(mux_win:tabs()) do
			if tab:tab_id() == old_id then
				tab:activate()
				window:perform_action(wezterm.action.CloseCurrentTab({ confirm = false }), tab:active_pane())
				break
			end
		end
	end

	-- Activate first tab
	local current_tabs = mux_win:tabs()
	if #current_tabs > 0 then
		current_tabs[1]:activate()
	end

	window:toast_notification("Session", "Restored: " .. workspace, nil, 3000)
end

local function get_saved_sessions()
	local sessions = {}
	local ok, files = pcall(wezterm.read_dir, session_dir)
	if ok and files then
		for _, file in ipairs(files) do
			local name = file:match("([^/]+)%.json$")
			if name then
				table.insert(sessions, name)
			end
		end
		table.sort(sessions)
	end
	return sessions
end

wezterm.on("save_session", function(window)
	local ok, err = pcall(save_session, window)
	if not ok then
		window:toast_notification("Session", "Save error: " .. tostring(err), nil, 5000)
	end
end)
wezterm.on("restore_session", function(window)
	restore_session(window)
end)

local config = wezterm.config_builder()

config.font_size = 11
config.color_scheme = "Night Owl (Gogh)"
config.window_background_opacity = 0.8
--config.window_decorations = "NONE"
config.default_cursor_style = "SteadyBar"
config.enable_wayland = true
config.tab_bar_at_bottom = true

local act = wezterm.action
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- splitting
	{
		mods = "LEADER",
		key = "v",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "h",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
	-- rotate panes
	{
		mods = "LEADER",
		key = "Space",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	-- show the pane selection mode, but have it swap the active and selected panes
	{
		mods = "LEADER",
		key = "0",
		action = wezterm.action.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	{
		key = "E",
		mods = "CTRL|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			initial_value = "",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ key = "S", mods = "LEADER", action = wezterm.action({ EmitEvent = "save_session" }) },
	{ key = "R", mods = "LEADER", action = wezterm.action({ EmitEvent = "restore_session" }) },
	{
		key = "S",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			-- get existing workspaces
			local workspaces = wezterm.mux.get_workspace_names()
			table.sort(workspaces)

			-- get saved sessions
			local saved_sessions = get_saved_sessions()

			-- build selector list
			local choices = {
				{ label = "+ New workspace...", id = "__NEW__" },
			}

			for _, name in ipairs(workspaces) do
				table.insert(choices, { label = name, id = name })
			end

			-- add saved sessions section
			if #saved_sessions > 0 then
				table.insert(choices, { label = "── Saved ──", id = "__SEPARATOR__" })
				for _, name in ipairs(saved_sessions) do
					table.insert(choices, { label = "[saved] " .. name, id = "__SAVED__:" .. name })
				end
				table.insert(choices, { label = "× Delete saved session...", id = "__DELETE__" })
			end

			window:perform_action(
				act.InputSelector({
					title = "Switch Workspace",
					choices = choices,
					fuzzy = true,
					action = wezterm.action_callback(function(window, pane, id)
						if not id then
							return -- cancelled
						end

						if id == "__NEW__" then
							-- prompt for name
							window:perform_action(
								act.PromptInputLine({
									description = "Enter name for new workspace",
									action = wezterm.action_callback(function(window, pane, line)
										if not line or line == "" then
											return
										end

										window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
									end),
								}),
								pane
							)
						elseif id == "__SEPARATOR__" then
							-- do nothing for separator
							return
						elseif id == "__DELETE__" then
							-- show delete selector
							local delete_choices = {}
							for _, name in ipairs(saved_sessions) do
								table.insert(delete_choices, { label = name, id = name })
							end
							window:perform_action(
								act.InputSelector({
									title = "Delete Saved Session",
									choices = delete_choices,
									fuzzy = true,
									action = wezterm.action_callback(function(inner_window, inner_pane, delete_id)
										if not delete_id then
											return
										end
										os.remove(get_session_path(delete_id))
										inner_window:toast_notification("Session", "Deleted: " .. delete_id, nil, 3000)
									end),
								}),
								pane
							)
						elseif id:match("^__SAVED__:") then
							-- restore saved session
							local session_name = id:gsub("^__SAVED__:", "")
							window:perform_action(act.SwitchToWorkspace({ name = session_name }), pane)
							-- defer restore to allow workspace switch to complete
							wezterm.time.call_after(0.5, function()
								-- find window in the new workspace
								for _, mux_win in ipairs(mux.all_windows()) do
									if mux_win:get_workspace() == session_name then
										local gui_win = mux_win:gui_window()
										if gui_win then
											restore_session(gui_win)
										end
										break
									end
								end
							end)
						else
							-- switch to existing workspace
							window:perform_action(act.SwitchToWorkspace({ name = id }), pane)
						end
					end),
				}),
				pane
			)
		end),
	},
}

return config
