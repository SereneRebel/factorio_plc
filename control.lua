
require "intellisense"

local gui = require "gui"
local structure = require "structure"

script.on_init(gui.on_init)
script.on_event(defines.events.on_tick, structure.on_tick)

local function on_gui_opened(event) 	gui.on_gui_opened(event) end
local function on_gui_closed(event) 	gui.on_gui_closed(event) end
--local function on_gui_confirmed(event) 	gui.on_gui_confirmed(event) end
local function on_gui_click(event) 		gui.on_gui_click(event) end
local function on_gui_changed(event) 	gui.on_gui_changed(event) end

--#region gui related events
script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
--script.on_event(defines.events.on_gui_confirmed, on_gui_confirmed)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_elem_changed, on_gui_changed)
script.on_event(defines.events.on_gui_text_changed, on_gui_changed)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_changed)
script.on_event(defines.events.on_gui_value_changed, on_gui_changed)
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
