require "intellisense"

local program = require "program"
local M = {}

---Get the global table containing all our structure info
---@param index integer|uint -- entity to lookup in the structure table
---@return nil|structure_table
function M.get_structure(index)
	if not global.plc_structures then
		global.plc_structures = {}
	end
	if not global.plc_structures[index] then
		global.plc_structures[index] = {
			entities = {
				main = nil,
				input = nil,
				output = nil,
			},
			program = {
				input_count = 0,
				input_data = {},
				output_count = 0,
				output_data = {},
				variable_count = 0,
				variable_data = {},
				program_count = 0,
				program_data = {}
			},
			data = {
				inputs = {},
				outputs = {},
				variables = {},
				running = false,
				execute_next = true,
			},
		}
	end
	return global.plc_structures[index]
end

---Remove the structure info from the global table containing of structures
---@param index LuaEntity -- entity to lookup amd remove from the structure table
function M.remove_structure(index)
	global.plc_structures[index] = nil
end

---Gets the entire structure list for iterating
---@return structure_table
function M.get_all_structures()
	if not global.plc_structures then
		global.plc_structures = {}
	end
	return global.plc_structures
end


local function insertSignal(container, signal, count)
	if not container[signal.type] then
		container[signal.type] = {}
	end
	if container[signal.type][signal.name] then
		container[signal.type][signal.name].count = container[signal.type][signal.name].count + count
	else
		container[signal.type][signal.name] = { signal = signal, count = count }
	end
end

---Reads all the input signals from incoming curcuit network
---@param struct structure_table
local function readInputs(struct)
	if struct.entities.input then
		struct.data.inputs = {}
		struct.data.outputs = {}
		local network = struct.entities.input.get_circuit_network(defines.wire_type.red)
		if network and network.signals then
			for _, signal_count in pairs(network.signals) do
				insertSignal(struct.data.inputs, signal_count.signal, signal_count.count)
			end
		end
		network = struct.entities.input.get_circuit_network(defines.wire_type.green)
		if network and network.signals then
			for _, signal_count in pairs(network.signals) do
				insertSignal(struct.data.inputs, signal_count.signal, signal_count.count)
			end
		end
	end
	for _, input in pairs(struct.program.input_data) do
		if input and input.signal and input.name then
			if struct.data.inputs[input.signal.type] and struct.data.inputs[input.signal.type][input.signal.name] then
				-- there is a signal for the given filter - save it
				struct.data.variables[input.name] = struct.data.inputs[input.signal.type][input.signal.name].count
			else
				struct.data.variables[input.name] = 0
			end
		end
	end
end

---Write all the output signals to outgoing curcuit network
---@param struct structure_table
local function writeOutputs(struct)
	for _, output in pairs(struct.program.output_data) do
		if output and output.signal and output.name and output.name ~= "" then
			if struct.data.variables[output.name] ~= nil then
				-- there is a signal for the given filter - save it
				insertSignal(struct.data.outputs, output.signal, math.floor(struct.data.variables[output.name]))
			end
		end
	end
	if struct.entities.output and struct.data.outputs then
		local index = 1;
		local behaviour = struct.entities.output.get_or_create_control_behavior()
		for _, signals in pairs(struct.data.outputs) do -- for each type of signal
			for _, signal in pairs(signals) do          -- then each of the signals in those types
				behaviour.set_signal(index, signal)
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
			if struct.entities.main.active and struct.data.running then
				readInputs(struct) -- first step is sample the inputs
				program.tickProgram(struct)	-- next we process all the code in the unit
				writeOutputs(struct) -- then we output the resulting outputs
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
		M.remove_structure(entity) -- remove it if it exists
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
	structure.program.input_count = 8
	for line = 1, 8 do
		structure.program.input_data[line] = { signal = nil, name = "" }
	end
	structure.program.output_count = 8
	for line = 1, 8 do
		structure.program.output_data[line] = { signal = nil, name = "" }
	end
	structure.program.variable_count = 8
	for line = 1, 8 do
		structure.program.variable_data[line] = { name = "" }
	end
	structure.program.program_count = 100
	for line = 1, 100 do
		structure.program.program_data[line] = { command = 1, parameter1 = "", parameter2 = "", parameter3 = "", }
	end
	structure.data.inputs = {}
	structure.data.outputs = {}
	structure.data.variables = {}
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
	if not event.entity or not event.entity.valid then
		return
	end
	local parts = event.entity.surface.find_entities_filtered{
		area = {
			{event.entity.position.x - 1.5, event.entity.position.y - 1.5},
			{event.entity.position.x + 1.5, event.entity.position.y + 1.5}
		},
		name = "plc-unit",
		invert = true,
	}
	for _, part in pairs(parts) do
		part.destroy()
	end
	M.remove_structure(event.entity.unit_number)
end


return M
