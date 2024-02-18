
require "intellisense"

local gui = require "gui"
local structure = require "structure"
local program = require "program"
require "params"

---Find the index of the parameter we want
---@param inputs string[]
---@param name string
---@return integer?
function get_param_index(inputs, name)
	for i, str in ipairs(inputs) do
		if str ~= nil and name ~= nil and string.lower(str) == string.lower(name) then
			return i
		end
	end
	return nil
end
---Migrate things between versions
---@param event ConfigurationChangedData
function on_configuration_changed(event)
	local changes = event.mod_changes["SignalController"]
	if changes ~= nil then
		local old = changes.old_version
		local new = changes.new_version
		if new == "2.0.0" then
			local structs = global.plc_structures
			for _, struct in pairs(structs) do
				-- fix up the structure for new version
				struct.program.inputs = struct.program.input_data or struct.program.inputs
				struct.program.outputs = struct.program.output_data or struct.program.outputs
				struct.program.variables = struct.program.variable_data or struct.program.variables
				struct.program.commands = struct.program.program_data or struct.program.commands
				update_param_lists(struct, false)
				for _, prog in ipairs(struct.program.commands) do
					-- new command was inserted
					if prog.command > 14 then
						prog.command = prog.command + 1
					end
					local command_info = program.commandList[prog.command]
					if command_info.in_a then
						if prog.parameter1 and (string.match(prog.parameter1, "^(%d+)") or string.match(prog.parameter1, "^-(%d+)")) then
							prog.in_param_a = 1
							prog.in_const_a = tonumber(prog.parameter1)
						elseif prog.parameter1 and string.match(prog.parameter1, "^(%a+)") then
							prog.in_param_a = get_param_index(struct.program.input_list, prog.parameter1)
						end
						if command_info.in_b then 
							if prog.parameter2 and (string.match(prog.parameter2, "^(%d+)") or string.match(prog.parameter2, "^-(%d+)")) then
								prog.in_param_b = 1
								prog.in_const_b = tonumber(prog.parameter2)
							elseif prog.parameter2 and string.match(prog.parameter2, "^(%a+)") then
								prog.in_param_b = get_param_index(struct.program.input_list, prog.parameter2)
							end
							if command_info.out then
								prog.out_param = get_param_index(struct.program.output_list, prog.parameter3)
							end
						else
							if command_info.out then
								prog.out_param = get_param_index(struct.program.output_list, prog.parameter2)
							end
						end
					end
				end
			end
		end
	end
end

script.on_init(gui.on_init)
script.on_event(defines.events.on_tick, structure.on_tick)
script.on_configuration_changed(on_configuration_changed)

--#region gui related events
script.on_event(defines.events.on_gui_opened, gui.on_gui_opened)
script.on_event(defines.events.on_gui_closed, gui.on_gui_closed)
script.on_event(defines.events.on_gui_click, gui.on_gui_interaction)
script.on_event(defines.events.on_gui_elem_changed, gui.on_gui_interaction)
script.on_event(defines.events.on_gui_text_changed, gui.on_gui_interaction)
script.on_event(defines.events.on_gui_selection_state_changed, gui.on_gui_interaction)
script.on_event(defines.events.on_gui_value_changed, gui.on_gui_interaction)
script.on_event(defines.events.on_gui_selected_tab_changed, gui.on_gui_interaction)
--#endregion

--#region entity related events
local filter = { { filter = "ghost", invert = true } }
script.on_event(defines.events.on_built_entity, structure.on_built_entity, filter)
script.on_event(defines.events.on_robot_built_entity, structure.on_built_entity, filter)
script.on_event(defines.events.script_raised_built, structure.on_built_entity, filter)
script.on_event(defines.events.script_raised_revive, structure.on_built_entity, filter)
script.on_event(defines.events.on_entity_cloned, structure.on_entity_cloned, filter)
script.on_event(defines.events.on_pre_player_mined_item, structure.on_entity_removed)
script.on_event(defines.events.on_robot_pre_mined, structure.on_entity_removed)
script.on_event(defines.events.on_entity_died, structure.on_entity_removed)
--#endregion
