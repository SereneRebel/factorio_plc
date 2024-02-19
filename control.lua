
require "intellisense"
require "migrations"

local gui = require "gui"
local structure = require "structure"

require "params"


---Migrate things between versions
---@param event ConfigurationChangedData
function on_configuration_changed(event)
	local changes = event.mod_changes["SignalController"]
	if changes ~= nil then
		local old = changes.old_version
		local new = changes.new_version
		if new == "2.0.0" then
			migrate_to_2_0_0()
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
