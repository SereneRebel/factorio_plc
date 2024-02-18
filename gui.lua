require "util"
require "intellisense"

local M = {}
local structure = require "structure"
local program = require "program"
local gui_parts = require "gui.parts"

---Install a callback and return the index to it
---@param struct PlcData
---@param callback function
---@return integer
local function register_callback(struct, callback)
	struct.data.cb_funcs = struct.data.cb_funcs or {}
	for index, cb in ipairs(struct.data.cb_funcs) do
		if cb == callback then
			return index
		end
	end
	local index = #struct.data.cb_funcs + 1
	struct.data.cb_funcs[index] = callback
	return index
end

---Get the callback for the index
---@param struct PlcData
---@param index integer
---@return function
local function get_callback(struct, index)
	return struct.data.cb_funcs[index]
end

--=================================================================================================
-- Local utility functions
--=================================================================================================
--- Updates text and such from the program data
---@param gui_program_row LuaGuiElement
---@param program_data PlcProgramEntry
---@param enabled boolean
---@param top_row boolean?
---@param bot_row boolean?
local function update_program_line(gui_program_row, program_data, enabled, top_row, bot_row)
	local command = program.commandList[program_data.command]
	program_data.in_param_a = program_data.in_param_a or 1
	program_data.in_param_b = program_data.in_param_b or 1
	program_data.out_param = program_data.out_param or 1
	program_data.in_const_a = program_data.in_const_a or 0
	program_data.in_const_b = program_data.in_const_b or 0

	gui_program_row.children[1].enabled = enabled										-- trash
	gui_program_row.children[2].enabled = enabled and top_row ~= true					-- up
	gui_program_row.children[3].enabled = enabled and bot_row ~= true					-- down
	gui_program_row.children[4].enabled = enabled										-- command
	gui_program_row.children[4].tooltip = { "plc_command_tooltip." .. (command.disp) }	-- command
	gui_program_row.children[4].selected_index = program_data.command					-- command
	gui_program_row.children[5].enabled = enabled										-- param 1
	gui_program_row.children[5].visible = command.in_a									-- param 1
	gui_program_row.children[5].selected_index = program_data.in_param_a				-- param 1
	gui_program_row.children[6].enabled = enabled										-- const 1
	gui_program_row.children[6].visible = command.in_a and program_data.in_param_a == 1	-- const 1
	gui_program_row.children[6].text = tostring(program_data.in_const_a)				-- const 1
	gui_program_row.children[7].enabled = enabled										-- param 2
	gui_program_row.children[7].visible = command.in_b									-- param 2
	gui_program_row.children[7].selected_index = program_data.in_param_b				-- param 2
	gui_program_row.children[8].enabled = enabled										-- const 2
	gui_program_row.children[8].visible = command.in_b and program_data.in_param_b == 1	-- const 2
	gui_program_row.children[8].text = tostring(program_data.in_const_b)				-- const 2
	gui_program_row.children[9].enabled = enabled										-- output
	gui_program_row.children[9].visible = command.out									-- output
	gui_program_row.children[9].selected_index = program_data.out_param					-- output
end



---Run/Stop button pressed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function on_run_stop_pressed(element, gui, struct, line)
	-- Set the updated run/stop info
	local run_stop_button = gui["signal-controller-run-frame"]["signal-controller-program-run"]
	local run_stop_label = gui["signal-controller-run-frame"]["signal-controller-program-run-label"]
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]

	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
	if struct.data.status.status == "error" then
		return
	end

	if struct.data.running then
		struct.data.running = false
		run_stop_button.sprite = "plc-play-button-white"
		run_stop_button.hovered_sprite = "plc-play-button-black"
		run_stop_button.clicked_sprite = "plc-play-button-black"
		run_stop_label.caption = "[ Program Stopped ]"
	else
		struct.data.running = true
		run_stop_button.sprite = "plc-pause-button-white"
		run_stop_button.hovered_sprite = "plc-pause-button-black"
		run_stop_button.clicked_sprite = "plc-pause-button-black"
		run_stop_label.caption = "[ Program Running ]"
	end
	local enabled = not struct.data.running
	-- Update enabled setting for other things
	local input_frame = gui["signal-controller-tabbed-pane"]["signal-controller-inputs-pane"].children[1]
	for i = 1, #struct.program.inputs do
		input_frame.children[i].children[2].enabled = enabled -- name
		input_frame.children[i].children[3].enabled = enabled -- signal
		input_frame.children[i].children[4].enabled = enabled -- wire
	end
	local output_frame = gui["signal-controller-tabbed-pane"]["signal-controller-outputs-pane"].children[1]
	for i = 1, #struct.program.outputs do
		output_frame.children[i].children[2].enabled = enabled -- name
		output_frame.children[i].children[3].enabled = enabled -- signal
	end
	local variable_frame = gui["signal-controller-tabbed-pane"]["signal-controller-variables-pane"].children[1]
	for i = 1, #struct.program.variables do
		variable_frame.children[i].children[2].enabled = enabled -- name
	end
	local program_frame = gui["signal-controller-tabbed-pane"]["signal-controller-program-pane"].children[1]
	for i = 1, #struct.program.commands do
		update_program_line(program_frame.children[i], struct.program.commands[i], enabled, i == 1, i == #struct.program.commands)
	end
end

---comment
---@param parent LuaGuiElement
---@param line integer
---@param entry PlcParameter
---@param enabled any
---@param direction any
---@param struct any
---@param funcs table
---@return LuaGuiElement
function add_named_signal_row(parent, line, entry, enabled, direction, struct, funcs)
	local unit_number = struct.entities.main.unit_number
	local page_flow = gui_parts.add_row(parent, direction, line)
	local label = gui_parts.add_label(page_flow, "Slot " .. line .. ":")
	local name_box = gui_parts.add_textbox(page_flow, direction .. "-name", entry.name, line, unit_number, enabled,
		funcs.on_name_changed)
	if direction ~= "variable" then
		local signal_button = gui_parts.add_signal_button(page_flow, direction .. "-signal", line, unit_number, enabled,
			entry.signal, funcs.on_signal_changed)
	end
	if direction == "input" then
		local wire_button = gui_parts.add_switch_button(page_flow, direction .. "-wire", line, unit_number, enabled,
			"Green", "red", entry.wire or "none", funcs.on_switch_changed)
	end
	return page_flow
end


---Command down button pressed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function del_button_pressed(element, gui, struct, line)
	-- empty the program line
	struct.program.commands[line] = { command = 1, in_param_a = 1, in_const_a = 0, in_param_b = 1, in_const_b = 0,
		out_param = 1, }
	-- update the gui line
	local gui_line = element.parent
	if gui_line ~= nil then
		update_program_line(gui_line, struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
	end
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Command up button pressed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function up_button_pressed(element, gui, struct, line)
	if line == 1 then
		return
	end
	-- swap this line with the one above it
	local tmp1 = struct.program.commands[line]
	local tmp2 = struct.program.commands[line - 1]
	struct.program.commands[line] = tmp2
	struct.program.commands[line - 1] = tmp1
	-- update both lines
	local program_frame = element.parent.parent
	if program_frame ~= nil then
		update_program_line(program_frame.children[line], struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
		update_program_line(program_frame.children[line - 1], struct.program.commands[line - 1], not struct.data.running, line-1 == 1, line-1 == #struct.program.commands)
	end
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Command down button pressed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function dn_button_pressed(element, gui, struct, line)
	if line == #struct.program.commands then
		return
	end
	-- swap this line with the one below it
	local tmp1 = struct.program.commands[line]
	local tmp2 = struct.program.commands[line + 1]
	struct.program.commands[line] = tmp2
	struct.program.commands[line + 1] = tmp1
	-- update both lines
	local program_frame = element.parent.parent
	if program_frame ~= nil then
		update_program_line(program_frame.children[line], struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
		update_program_line(program_frame.children[line + 1], struct.program.commands[line + 1], not struct.data.running, line+1 == 1, line+1 == #struct.program.commands)
	end
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Command changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function command_changed(element, gui, struct, line)
	local new_value = element.selected_index
	struct.program.commands[line].command = new_value
	update_program_line(element.parent, struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Parameter 1 changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function param_1_changed(element, gui, struct, line)
	local new_value = element.selected_index
	struct.program.commands[line].in_param_a = new_value
	update_program_line(element.parent, struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Constant 1 changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function const_1_changed(element, gui, struct, line)
	local new_value = tonumber(element.text)
	struct.program.commands[line].in_const_a = new_value or 0
	update_program_line(element.parent, struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Parameter 2 changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function param_2_changed(element, gui, struct, line)
	local new_value = element.selected_index
	struct.program.commands[line].in_param_b = new_value
	update_program_line(element.parent, struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Constant 2 changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function const_2_changed(element, gui, struct, line)
	local new_value = tonumber(element.text)
	struct.program.commands[line].in_const_b = new_value or 0
	update_program_line(element.parent, struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Parameter 3 changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function param_3_changed(element, gui, struct, line)
	local new_value = element.selected_index
	struct.program.commands[line].out_param = new_value
	update_program_line(element.parent, struct.program.commands[line], not struct.data.running, line == 1, line == #struct.program.commands)
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Create program selection page
---@param frame LuaGuiElement
---@param struct PlcData
function programPage(frame, struct)
	local command_list = {}
	for ind, command in pairs(program.commandList) do command_list[ind] = command.disp end
	-- program information
	local running = struct.data.running
	local count = #struct.program.commands
	local prog = struct.program.commands
	local unit_number = struct.entities.main.unit_number
	update_param_lists(struct)
	if unit_number == nil then
		return
	end
	local prog_status_label = frame.parent.parent.parent.children[2].children[4]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
	for line = 1, count do -- process the program
		prog[line] = prog[line] or { cmd = 1, params = {} }
		local code = prog[line]
		local command = program.commandList[code.command]
		code.in_param_a = code.in_param_a or 1
		code.in_param_b = code.in_param_b or 1
		code.out_param = code.out_param or 1
		code.in_const_a = code.in_const_a or 0
		code.in_const_b = code.in_const_b or 0
		local line_frame = gui_parts.add_row(frame, "program", line)
		local del_button = gui_parts.add_del_button(line_frame, line, unit_number, not running, register_callback(struct, del_button_pressed))
		local up_button = gui_parts.add_up_button(line_frame, line, unit_number, line ~= 1 and not running, register_callback(struct, up_button_pressed))
		local down_button = gui_parts.add_down_button(line_frame, line, unit_number, line ~= count and not running, register_callback(struct, dn_button_pressed))
		local cmd_dropdown = gui_parts.add_command_dropdown(line_frame, line, unit_number, not running, code.command, command_list, register_callback(struct, command_changed))
		local cmd_param1 = gui_parts.add_command_parameter(line_frame, line, unit_number, 1, not running, command.in_a, code.in_param_a, struct.program.input_list, register_callback(struct, param_1_changed))
		local cmd_const1 = gui_parts.add_command_const(line_frame, line, unit_number, 1, not running, command.in_a and code.in_param_a == 1, code.in_const_a, register_callback(struct, const_1_changed))
		local cmd_param2 = gui_parts.add_command_parameter(line_frame, line, unit_number, 2, not running, command.in_b, code.in_param_b, struct.program.input_list, register_callback(struct, param_2_changed))
		local cmd_const2 = gui_parts.add_command_const(line_frame, line, unit_number, 2, not running, command.in_b and code.in_param_b == 1, code.in_const_b, register_callback(struct, const_2_changed))
		local cmd_param3 = gui_parts.add_command_parameter(line_frame, line, unit_number, 3, not running, command.out, code.out_param, struct.program.output_list, register_callback(struct, param_3_changed))

	end
end

---Input name changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function on_input_name_changed(element, gui, struct, line)
	struct.program.inputs[line].name = element.text
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Input signal changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function on_input_signal_changed(element, gui, struct, line)
	struct.program.inputs[line].signal = element.elem_value
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Input wire changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function on_input_wire_changed(element, gui, struct, line)
	struct.program.inputs[line].wire = element.switch_state
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Create input selection page
---@param frame LuaGuiElement
---@param struct PlcData
function inputPage(frame, struct)
	local count = #struct.program.inputs
	local unit_number = struct.entities.main.unit_number
	local enabled = (struct.data.running == false)
	if unit_number == nil then
		return
	end
	for line = 1, count do
		local entry = struct.program.inputs[line]
		local page_flow = gui_parts.add_row(frame, "input", line)
		local label = gui_parts.add_label(page_flow, "Slot " .. line .. ":")
		local name_box = gui_parts.add_textbox(page_flow, "input-name", entry.name, line, unit_number, enabled,
			register_callback(struct, on_input_name_changed))
		local signal_button = gui_parts.add_signal_button(page_flow, "input-signal", line, unit_number, enabled,
			entry.signal, register_callback(struct, on_input_signal_changed))
		local wire_button = gui_parts.add_switch_button(page_flow, "input-wire", line, unit_number, enabled, "Green",
			"red", entry.wire or "none", register_callback(struct, on_input_wire_changed))
	end
end

---Output name changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function on_output_name_changed(element, gui, struct, line)
	struct.program.outputs[line].name = element.text
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Output signal changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function on_output_signal_changed(element, gui, struct, line)
	struct.program.outputs[line].signal = element.elem_value
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Create output selection page
---@param frame LuaGuiElement
---@param struct PlcData
function outputPage(frame, struct)
	local count = #struct.program.outputs
	local unit_number = struct.entities.main.unit_number
	local enabled = (struct.data.running == false)
	if unit_number == nil then
		return
	end
	for line = 1, count do
		local entry = struct.program.outputs[line]
		local page_flow = gui_parts.add_row(frame, "output", line)
		local label = gui_parts.add_label(page_flow, "Slot " .. line .. ":")
		local name_box = gui_parts.add_textbox(page_flow, "output-name", entry.name, line, unit_number, enabled,
			register_callback(struct, on_output_name_changed))
		local signal_button = gui_parts.add_signal_button(page_flow, "output-signal", line, unit_number, enabled,
			entry.signal, register_callback(struct, on_output_signal_changed))
	end
end

---Output name changed callback
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function on_variable_name_changed(element, gui, struct, line)
	struct.program.variables[line].name = element.text
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---Create variables selection page
---@param frame LuaGuiElement
---@param struct PlcData
function variablePage(frame, struct)
	local unit_number = struct.entities.main.unit_number
	local enabled = (struct.data.running == false)
	if unit_number == nil then
		return
	end
	for line, entry in ipairs(struct.program.variables) do
		local page_flow = gui_parts.add_row(frame, "variable", line)
		local label = gui_parts.add_label(page_flow, "Slot " .. line .. ":")
		local name_box = gui_parts.add_textbox(page_flow, "variable-name", entry.name, line, unit_number, enabled,
			register_callback(struct, on_variable_name_changed))
	end
end

---Update the dropdown info for all commands
---@param struct PlcData
---@param program_pane LuaGuiElement
local function update_dropdown_values(struct, program_pane)
	for line, cmd in ipairs(struct.program.commands) do
		local row = program_pane.children[1].children[line]
		row.children[5].items = struct.program.input_list
		row.children[5].selected_index = cmd.in_param_a or 1
		row.children[7].items = struct.program.input_list
		row.children[7].selected_index = cmd.in_param_b or 1
		row.children[9].items = struct.program.output_list
		row.children[9].selected_index = cmd.out_param or 1
	end
end

---Fired when the player changes gui tabs
---@param element LuaGuiElement
---@param gui LuaGuiElement
---@param struct PlcData
---@param line integer
local function on_gui_tab_changed(element, gui, struct, line)
	local selected_tab = element.tabs[element.selected_tab_index].content
	if element.selected_tab_index == 1 then
		update_param_lists(struct)
		update_dropdown_values(struct, selected_tab)
	end
	local prog_status_label = gui["signal-controller-run-frame"]["signal-controller-program-status"]
	program.check_program(struct) -- update the program status
	gui_parts.update_status_text(prog_status_label, struct)
end

---================================================================================================
--- Events
---================================================================================================

---A GUI Item changed/clicked
---@param event EventData.on_gui_click
function M.on_gui_interaction(event)
	-- minimum stuff check
	if not event or not event.element or not event.element.name or not event.player_index then
		return
	end
	local element = event.element
	if element.name == "signal-controller-close" then
		element.parent.parent.destroy()
		return
	end
	-- is this for us?
	if string.match(element.name, "^signal%-controller") ~= "signal-controller" then
		return
	end
	if not element.tags then
		return
	end
	local player = game.players[event.player_index]
	local unit_number = tonumber(element.tags["unit_number"])
	local callback_index = tonumber(event.element.tags["callback"])
	local line = event.element.tags["line"]
	if not player or not unit_number then
		return
	end
	local gui = player.gui.screen["signal-controller-outer-frame"]
	local struct = structure.get_structure(unit_number)
	if gui and struct and callback_index then
		callback = get_callback(struct, callback_index)
		if callback ~= nil then
			callback(element, gui, struct, line)
		end
		return
	end
	player.print("Unhandled event onClick - element.name = " .. element.name)
	player.print("element.type = " .. element.type)
end

---GUI Initialization event
function M.on_init()
	global.gui = global.gui or {}
end

---GUI Close event
---@param event EventData.on_gui_closed
function M.on_gui_closed(event)
	if event.gui_type == defines.gui_type.custom then
		if event and event.element and event.element.name then
			if event.element.name == "signal-controller-outer-frame" then
				event.element.destroy()
			end
		end
	end
end

---GUI Opened event
---@param event EventData.on_gui_opened
function M.on_gui_opened(event)
	local entity = event.entity
	if event.gui_type == defines.gui_type.entity and entity and entity.valid and entity.name == "plc-unit" and entity.unit_number then
		local player = game.get_player(event.player_index)
		local struct = structure.get_structure(entity.unit_number)
		if player ~= nil and struct ~= nil then
			local gui = player.gui.screen
			local running = struct.data.running
			program.check_program(struct) -- update the program status
			-- Destroy any old versions
			if gui["signal-controller-outer-frame"] then
				gui["signal-controller-outer-frame"].destroy()
			end
			-- create main panel
			local main_frame = gui_parts.add_main_frame(gui)
			-- create titlebar
			local titlebar = gui_parts.add_titlebar(main_frame, entity.localised_name)
			-- add run/stop frame
			local run_frame = gui_parts.add_run_stop_control(main_frame, entity.unit_number, running, struct, register_callback(struct, on_run_stop_pressed))
			-- separator
			local sep1 = main_frame.add { type = "line", direction = "horizontal", }
			-- add tabbed pane
			local tabbed_pane = gui_parts.add_tabbed_pane(main_frame, "signal-controller-tabbed-pane", struct, register_callback(struct, on_gui_tab_changed))
			-- add the program panel
			local program_tab = gui_parts.add_tab(tabbed_pane, "Program", programPage, struct)
			-- add the variables panel
			local variables_tab = gui_parts.add_tab(tabbed_pane, "Variables", variablePage, struct)
			-- add the inputs panel
			local inputs_tab = gui_parts.add_tab(tabbed_pane, "Inputs", inputPage, struct)
			-- add the outputs panel
			local outputs_tab = gui_parts.add_tab(tabbed_pane, "Outputs", outputPage, struct)
			-- make the gui active
			player.opened = main_frame
		end
	end
end

-- return as table
return M
