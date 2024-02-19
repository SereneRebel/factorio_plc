require "intellisense"

local program = require "program"
local M = {}

---@type PlcData[]
global.plc_structures = global.plc_structures or {}

function M.fill_prog_list(struct)
	struct.data.command_dropdown = {strings={},link={}}
	for i, cmd in ipairs(program.commandList) do
		table.insert(struct.data.command_dropdown.strings, i, cmd.disp)
		table.insert(struct.data.command_dropdown.link, i, cmd)
	end
end

---Populates a new empty struct table
---@return PlcData
local function new_structure()
	---@type PlcData
	local struct = {
		entities = {
			main = nil,
			input = nil,
			output = nil,
		},
		program = {
			inputs = {},
			outputs = {},
			variables = {},
			constants = {},
			commands = {},
		},
		data = {
			command_dropdown = { strings = {}, link = {} },
			input_dropdown = { strings = {}, link = {} },
			output_dropdown = { strings = {}, link = {} },
			inputs = {},
			outputs = {},
			variables = {},
			running = false,
			execute_next = true,
			cb_funcs = {},
			cb_keys = {},
			status = { status = "ok", msg = ""},
			live_page = nil,
			alert_holdoff = 0,
		},
	}
	M.fill_prog_list(struct)
	return struct
end



---Get the global table containing all our structure info
---@param index integer|uint -- entity to lookup in the structure table
---@return PlcData
function M.get_structure(index)
	if not global.plc_structures[index] then
		global.plc_structures[index] = new_structure()
	end
	return global.plc_structures[index]
end

---Remove the structure info from the global table containing of structures
---@param index integer -- entity to lookup amd remove from the structure table
function M.remove_structure(index)
	global.plc_structures[index] = nil
end

---Gets the entire structure list for iterating
---@return PlcData[]
function M.get_all_structures()
	return global.plc_structures
end

--- Insert signal into table
---@param container table
---@param signal Signal
local function insertSignal(container, signal)
	if not container[signal.signal.type] then
		container[signal.signal.type] = {}
	end
	if container[signal.signal.type][signal.signal.name] then
		container[signal.signal.type][signal.signal.name].count = container[signal.signal.type][signal.signal.name].count + signal.count
	else
		container[signal.signal.type][signal.signal.name] = { signal = signal.signal, count = signal.count }
	end
end

---Reads all the input signals from incoming curcuit network
---@param struct PlcData
local function readInputs(struct)
	local red_inputs = {}
	local green_inputs = {}
	if struct.entities.input then
		-- get red signals
		local network = struct.entities.input.get_circuit_network(defines.wire_type.red)
		if network and network.signals then
			for _, signal in pairs(network.signals) do
				insertSignal(red_inputs, signal)
			end
		end
		-- get green signals
		network = struct.entities.input.get_circuit_network(defines.wire_type.green)
		if network and network.signals then
			for _, signal in pairs(network.signals) do
				insertSignal(green_inputs, signal)
			end
		end
	end
	-- now we have all the signal inputs and we need to transfer the input definitions to the variables area
	for _, input in pairs(struct.program.inputs) do
		if input and input.signal and input.name then
			local wire = input.wire or "none" -- the wire to get signal from
			local type = input.signal.type
			local name = input.signal.name
			local count = 0
			if wire ~= "left" then -- is this signal getting read from the red wire
				if red_inputs[type] and red_inputs[type][name] then
					-- there is a signal for the given filter - save it
					count = count + red_inputs[type][name].count
				end
			end
			if wire ~= "right" then -- is this signal getting read from the green wire
				if green_inputs[type] and green_inputs[type][name] then
					count = count + green_inputs[type][name].count
				end
			end
			input.value = count
		end
	end
end

---Write all the output signals to outgoing curcuit network
---@param struct PlcData
local function writeOutputs(struct)
	if struct.entities.output and struct.program.outputs then
		local index = 1;
		--- @type LuaConstantCombinatorControlBehavior 
		local behaviour = struct.entities.output.get_or_create_control_behavior()
		if behaviour == nil then
			return
		end
		for _, output in pairs(struct.program.outputs) do
			if output and output.signal and output.name and output.name ~= "" then
				-- there is a signal for the given filter - save it
				behaviour.set_signal(index, { signal = output.signal, count = math.floor(output.value)})
				index = index + 1
			end
		end
	end
end


---comment
---@param event EventData.on_tick
function M.on_tick(event)
	local structures = M.get_all_structures()
	local to_remove = {}
	for key, struct in pairs(structures) do
		if struct.entities and struct.entities.main and struct.entities.main.valid then
			local status = struct.entities.main.status
			local running = struct.data.running
			struct.entities.main.active = running
			if running and status == defines.entity_status.working then
				readInputs(struct) -- first step is sample the inputs
				program.tickProgram(struct)	-- next we process all the code in the unit
				writeOutputs(struct) -- then we output the resulting outputs
			end
			-- check alerts
			struct.data.alert_holdoff = struct.data.alert_holdoff or 0
			if (event.tick - struct.data.alert_holdoff > 200) and (struct.data.alert ~= nil) then
				create_alert(struct.entities.main, struct.data.alert, game.players[1])
				struct.data.alert_holdoff = event.tick
			end
		else
			table.insert(to_remove, key)
		end
	end
	for _, key in ipairs(to_remove) do
		M.remove_structure(key)
	end
end



local pos_offsets = {
	[defines.direction.north] = {
		input = { x = -1, y = 0, direction = defines.direction.west },
		output = { x = 1, y = 0, direction = defines.direction.east },
		search = { x1 = 1.2, x2 = -1.2, y1 = 0.2, y2 = -0.2 },
	},
	[defines.direction.south] = {
		input = { x = 1, y = 0, direction = defines.direction.east },
		output = { x = -1, y = 0, direction = defines.direction.west },
		search = { x1 = 1.2, x2 = -1.2, y1 = 0.2, y2 = -0.2 },
	},
	[defines.direction.east] = {
		input = { x = 0, y = -1, direction = defines.direction.north },
		output = { x = 0, y = 1, direction = defines.direction.south },
		search = { x1 = 0.2, x2 = -0.2, y1 = 1.2, y2 = -1.2 },
	},
	[defines.direction.west] = {
		input = { x = 0, y = 1, direction = defines.direction.south },
		output = { x = 0, y = -1, direction = defines.direction.north},
		search = { x1 = 0.2, x2 = -0.2, y1 = 1.2, y2 = -1.2 },
	},
}

---Creates the sub-entities and sets up the main entity
---@param entity LuaEntity
function on_build_structure(entity)
	-- Determine the location of the sub entities
	local offsets = pos_offsets[entity.direction]
	local search_area = {
		{ entity.position.x + offsets.search.x1,  entity.position.y + offsets.search.y1 },
		{ entity.position.x + offsets.search.x2,  entity.position.y + offsets.search.y2 }
	}
	-- create the entities
	local input = nil
	local output = nil
	-- handle blueprint ghosts and existing IO entities preserving circuit connections
	local ghosts = entity.surface.find_entities(search_area)
	for _, ghost in pairs(ghosts) do
		if ghost.valid then
			if ghost.name == "entity-ghost" then
				if ghost.ghost_name == "plc-input" then
					_, input = ghost.revive()
				elseif ghost.ghost_name == "plc-output" then
					_, output = ghost.revive()
				end
			elseif ghost.name == "plc-input" then
				input = ghost
			elseif ghost.name == "plc-output" then
				output = ghost
			end
		end
	end
	-- create if not existing
	if input == nil then
		input = entity.surface.create_entity {
			name = "plc-input",
			position = { entity.position.x + offsets.input.x,  entity.position.y + offsets.input.y },
			direction = offsets.input.direction,
			force = entity.force,
			fast_replace = false,
			destructible = false,
		}
		input.operable = false
	end
	-- create if not existing
	if output == nil then
		output = entity.surface.create_entity {
			name = "plc-output",
			position = { entity.position.x + offsets.output.x,  entity.position.y + offsets.output.y },
			direction = offsets.output.direction,
			force = entity.force,
			fast_replace = false,
			destructible = false,
		}
		output.operable = false
	end
	-- if the sub-entities were not both created we just destroy it all and bail
	if input == nil or output == nil then
		if input then input.destroy() end
		if output then output.destroy() end
		M.remove_structure(entity.unit_number) -- remove it if it exists
		entity.destroy()
		return
	end
	-- get and setup structure object
	local structure = M.get_structure(entity.unit_number)
	if not structure then
		entity.destroy()
		return
	end
	structure.entities = {main = entity, input = input, output = output, }
	for line = 1, 8 do
		structure.program.inputs[line] = { type = "invalid", value = 0 }
	end
	for line = 1, 8 do
		structure.program.outputs[line] = { type = "invalid", value = 0 }
	end
	for line = 1, 8 do
		structure.program.variables[line] = { type = "invalid", value = 0 }
	end
	for line = 1, 100 do
		structure.program.commands[line] = { command = program.commandList[1] }
	end
	update_param_lists(structure)
	structure.data.running = false
	structure.data.execute_next = true
end

---comment
---@param event EventData.on_built_entity|EventData.on_robot_built_entity|EventData.script_raised_built|EventData.script_raised_revive
function M.on_built_entity(event)
    local entity = event.created_entity or event.entity
    if entity and entity.name == "plc-unit" then
		on_build_structure(entity)
	end
end

---comment
---@param event EventData.on_entity_cloned
function M.on_entity_cloned(event)
    local source_entity = event.source
	local dest_entity = event.destination
	if dest_entity.name == "plc-unit" and source_entity.name == "plc-unit" then
		-- allow the build to proceed
		on_build_structure(dest_entity)
		-- overwrite settings
		local old_struct = M.get_structure(source_entity.unit_number)
		local new_struct = M.get_structure(dest_entity.unit_number)
		if old_struct and new_struct then
			new_struct.program = table.deepcopy(old_struct.program)
			new_struct.data = table.deepcopy(old_struct.data)
		end
	end
end

---comment
---@param event EventData.on_robot_pre_mined|EventData.on_pre_player_mined_item|EventData.on_entity_died
function M.on_entity_removed(event)
	if not event.entity or not event.entity.valid or event.entity.name ~= "plc-unit" then
		return
	end
	local parts = event.entity.surface.find_entities_filtered{
		area = {
			{event.entity.position.x - 1.5, event.entity.position.y - 1.5},
			{event.entity.position.x + 1.5, event.entity.position.y + 1.5}
		},
		name = {"plc-input", "plc-output"},
	}
	for _, part in pairs(parts) do
		part.destroy()
	end
	M.remove_structure(event.entity.unit_number)
end


return M
