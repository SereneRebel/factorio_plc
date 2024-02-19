
local M = {}

---Creates the GUIs main frame
---@param gui LuaGuiElement
---@return LuaGuiElement
function M.add_main_frame(gui)
	local frame = gui.add {
		type = "frame",
		name = "signal-controller-outer-frame",
		direction = "vertical",
		style = "plc_main_frame",
	}
	frame.auto_center = true
	return frame
end

---Adds a draggable title bar to a frame
---@param parent LuaGuiElement
---@param name string|LocalisedString
---@return LuaGuiElement
function M.add_titlebar(parent, name)
	-- create title bar with dragger
	local titlebar = parent.add {
		type = "flow"
	}
	titlebar.drag_target = parent
	titlebar.add {
		type = "label",
		style = "frame_title",
		caption = name,
		ignored_by_interaction = true,
	}
	local filler = titlebar.add {
		type = "empty-widget",
		style = "draggable_space",
		ignored_by_interaction = true,
	}
	filler.style.height = 24
	filler.style.horizontally_stretchable = true
	titlebar.add {
		type = "sprite-button",
		name = "signal-controller-close",
		style = "frame_action_button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		tooltip = { "gui.close-instruction" },
	}
	return titlebar
end

---Update the status indicator
---@param label LuaGuiElement
---@param struct PlcData
function M.update_status_text(label, struct)
	if struct.data.status.status == "error" then
		label.style.font_color = red_body_text_color
		label.caption = "[color=red][Error] " .. struct.data.status.msg .. "[/color]"
	elseif struct.data.status.status == "warn" then
		label.style.font_color = default_orange_color
		label.caption = "[color=orange][Warning] " .. struct.data.status.msg .. "[/color]"
	else
		label.style.font_color = green_body_text_color
		label.caption = "[color=green]" .. struct.data.status.msg .. "[/color]"
	end
end

---Add the program run/stop control
---@param parent LuaGuiElement
---@param unit_number integer
---@param value boolean
---@param struct PlcData
---@param callback_index integer
---@return LuaGuiElement
function M.add_run_stop_control(parent, unit_number, value, struct, callback_index)
	local run_stop_sprite = value and "plc-pause-button" or "plc-play-button"
	local frame = parent.add {
		type = "flow",
		name = "signal-controller-run-frame",
	}
	frame.style.vertical_align = "center"
	local label = frame.add {
		type = "label",
		name = "signal-controller-program-run-label",
		caption = value and "[ Program Running ]" or "[ Program Stopped ]",
	}
	local button = frame.add {
		type = "sprite-button",
		name = "signal-controller-program-run",
		sprite = run_stop_sprite.."-white",
		hovered_sprite = run_stop_sprite.."-black",
		clicked_sprite = run_stop_sprite.."-black",
		tooltip = value and "Stop program execution" or "Run program execution",
		tags = {
			["line"] = 1,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	local separator = frame.add {
		type = "line",
		direction = "vertical"
	}
	local status_label = frame.add {
		type = "label",
		name = "signal-controller-program-status",
	}
	status_label.style.rich_text_setting = defines.rich_text_setting.enabled
	M.update_status_text(status_label, struct)
	return frame
end

---Add a tabed pane
---@param parent LuaGuiElement
---@param name string
---@param struct PlcData
---@param callback_index integer
---@return LuaGuiElement
function M.add_tabbed_pane(parent, name, struct, callback_index)
	local pane = parent.add {
		type = "tabbed-pane",
		name = name,
		tags = {
			["line"] = 1,
			["unit_number"] = struct.entities.main.unit_number,
			["callback"] = callback_index,
		},
	}
	return pane
end

---Add a tab to a tabbed pane
---@param parent LuaGuiElement
---@param tab_name string
---@param content_func function
---@param struct PlcData
---@return LuaGuiElement
function M.add_tab(parent, tab_name, content_func, struct)
	local tab = parent.add {
		type = "tab",
		caption = tab_name,
	}
	local pane = parent.add {
		type = "scroll-pane",
		direction = "vertical",
		horizontal_scroll_policy = "never",
		vertical_scroll_policy = "always",
		name = "signal-controller-"..tab_name:lower().."-pane",
	}
	pane.style.maximal_height = 500
	local frame = pane.add {
		type = "frame",
		style = "entity_frame",
		direction = "vertical",
		name = "signal-controller-"..tab_name:lower().."-frame",
	}
	frame.style.vertically_stretchable = true
	content_func(frame, struct)
	tab.tags = {["frame"]=pane}
	parent.add_tab(tab, pane)
	return tab
end


--- Add a row frame to house items
---@param parent LuaGuiElement
---@param name string
---@param index integer
---@return LuaGuiElement
function M.add_row(parent, name, index)
	local element = parent.add { type = "flow", name = "signal-controller-" .. name .. "-row-" .. index}
	element.style.vertical_align = "center"
	element.style.horizontally_stretchable = true
	return element
end

--- Add a simple text label
---@param parent LuaGuiElement
---@param text string
---@return LuaGuiElement
function M.add_label(parent, text)
	local element = parent.add {
		type = "label",
		caption = text,
	}
	return element
end

---comment
---@param parent LuaGuiElement
---@param name string
---@param index integer
---@param unit_number integer
---@param enabled boolean
---@param left_name string
---@param right_name string
---@param value string
---@param callback_index integer
---@return LuaGuiElement
function M.add_switch_button(parent, name, index, unit_number, enabled, left_name, right_name, value, callback_index)
	local element = parent.add {
		type = "switch",
		tooltip = { "plc_tooltip." .. name },
		name = "signal-controller-" .. name .. "-" .. index,
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	element.left_label_caption = left_name
	element.right_label_caption = right_name
	element.allow_none_state = true
	element.switch_state = value
	element.enabled = enabled
	return element
end

--- Add a signal selector with callback fucntion
---@param parent LuaGuiElement
---@param name string
---@param index integer
---@param unit_number integer
---@param enabled boolean
---@param value string|SignalID
---@param callback_index integer
---@return LuaGuiElement
function M.add_signal_button(parent, name, index, unit_number, enabled, value, callback_index)
	local element = parent.add{
		type = "choose-elem-button",
		style = "plc-unit-slot",
		elem_type = "signal",
		name = "signal-controller-" .. name .. "-" .. index,
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	element.elem_value = value
	element.enabled = enabled
	return element
end

--- Add a textbox with callback fucntion
---@param parent LuaGuiElement
---@param name string
---@param text string
---@param index integer
---@param unit_number integer
---@param enabled boolean
---@param callback_index integer
---@return LuaGuiElement
function M.add_textbox(parent, name, text, index, unit_number, enabled, callback_index)
	local element = parent.add{
		text = text,
		type = "textfield",
		tooltip = { "plc_tooltip." .. name },
		name = "signal-controller-" .. name .. "-" .. index,
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	element.enabled = enabled
	return element
end

--- Creates the delete tool button
---@param parent LuaGuiElement
---@param index integer
---@param unit_number integer
---@param enabled boolean
---@param callback_index integer
---@return LuaGuiElement
function M.add_del_button(parent, index, unit_number, enabled, callback_index)
	local element = parent.add {
		type = "sprite-button",
		name = "signal-controller-program-delete-" .. index,
		enabled = enabled,
		sprite = "plc-trash-button-white",
		hovered_sprite = "plc-trash-button-black",
		clicked_sprite = "plc-trash-button-black",
		tooltip = { "plc_tooltip.delete_line" },
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	return element
end

--- Creates the move up tool button
---@param parent LuaGuiElement
---@param index integer
---@param unit_number integer
---@param enabled boolean
---@param callback_index integer
---@return LuaGuiElement
function M.add_up_button(parent, index, unit_number, enabled, callback_index)
	local element = parent.add {
		type = "sprite-button",
		name = "signal-controller-program-up-" .. index,
		enabled = enabled,
		sprite = "plc-up-button-white",
		hovered_sprite = "plc-up-button-black",
		clicked_sprite = "plc-up-button-black",
		tooltip = { "plc_tooltip.move_line_up" },
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	return element
end

--- Creates the move down tool button
---@param parent LuaGuiElement
---@param index integer
---@param unit_number integer
---@param enabled boolean
---@param callback_index integer
---@return LuaGuiElement
function M.add_down_button(parent, index, unit_number, enabled, callback_index)
	local element = parent.add {
		type = "sprite-button",
		name = "signal-controller-program-down-" .. index,
		enabled = enabled,
		sprite = "plc-down-button-white",
		hovered_sprite = "plc-down-button-black",
		clicked_sprite = "plc-down-button-black",
		tooltip = { "plc_tooltip.move_line_down" },
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	return element
end

--- Creates the command selector
---@param parent LuaGuiElement
---@param index integer
---@param unit_number integer
---@param enabled boolean
---@param selected integer
---@param command_list string[]
---@param callback_index integer
---@return LuaGuiElement
function M.add_command_dropdown(parent, index, unit_number, enabled, selected, command_list, callback_index)
	local element = parent.add {
		type = "drop-down",
		name = "signal-controller-command-" .. index,
		style = "plc_dropdown",
		tooltip = { "plc_command_tooltip." .. (command_list[selected]) },
		items = command_list,
		selected_index = selected,
		enabled = enabled,
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	return element
end

--- Creates the command parameter selector
---@param parent LuaGuiElement
---@param index integer
---@param unit_number integer
---@param param_number integer
---@param enabled boolean
---@param visible boolean
---@param value integer
---@param param_list string[]
---@param callback_index integer
---@return LuaGuiElement
function M.add_command_parameter(parent, index, unit_number, param_number, enabled, visible, value, param_list, callback_index)
	local element = parent.add {
		type = "drop-down",
		name = "signal-controller-param" .. param_number .. "-" .. index,
		style = "plc_dropdown",
		tooltip = { "plc_tooltip.parameter" .. param_number },
		items = param_list,
		selected_index = value,
		enabled = enabled,
		visible = visible,
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	return element
end

--- Creates the command constant textbox
---@param parent LuaGuiElement
---@param index integer
---@param unit_number integer
---@param param_number integer
---@param enabled boolean
---@param visible boolean
---@param constant number
---@param callback_index integer
---@return LuaGuiElement
function M.add_command_const(parent, index, unit_number, param_number, enabled, visible, constant, callback_index)
	local element = parent.add {
		type = "textfield",
		name = "signal-controller-const" .. param_number .. "-" .. index,
		style = "plc_textfield",
		tooltip = { "plc_tooltip.constant" .. param_number },
		text = tostring(constant),
		enabled = enabled,
		--visible = selected == 1,
		numeric = true,
		allow_decimal = true,
		allow_negative = true,
		visible = visible,
		tags = {
			["line"] = index,
			["unit_number"] = unit_number,
			["callback"] = callback_index,
		},
	}
	return element
end






return M