function getStructureForEntity(entity)
    if entity.valid and global.unitNumbers then
        local struct_id = global.unitNumbers[entity.unit_number]
        if struct_id then
            return global.structures[struct_id]
        end
    end
end

function unmanageStructure(struct)
    -- this unit is dead
	if struct and struct.entities then
		for _, entity in pairs(struct.entities) do
			if entity.valid and entity.name ~= "plc-unit" then
				if entity.unit_number then
					global.unitNumbers[entity.unit_number] = nil
				end
				entity.destroy()
			end
		end
		global.structures[struct.id] = nil
    end
end


local function onDead(event)
	local struct = getStructureForEntity(event.entity)
	unmanageStructure(struct)
end

local function insertSignal(container, signal, count)
	if not container[signal.type] then
		container[signal.type] = {}
	end
	if container[signal.type][signal.name] then
		container[signal.type][signal.name].count = container[signal.type][signal.name].count + count
	else
		container[signal.type][signal.name] = {signal = signal, count = count}
	end
end

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
	for _, input in pairs(struct.program.inputs) do
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

local function writeOutputs(struct)
	for _, output in pairs(struct.program.outputs) do
		if output and output.signal and output.name and output.name ~= "" then
			if struct.data.variables[output.name] ~= nil then 
				-- there is a signal for the given filter - save it
				insertSignal(struct.data.outputs, output.signal, math.floor(struct.data.variables[output.name]))
			end
		end
	end	
	if struct.entities.output and struct.data.outputs then
        local parameters = {}
        local index = 1;
        for _, signals in pairs(struct.data.outputs) do	-- for each type of signal
			for _, signal in pairs(signals) do			-- then each of the signals in those types
				if signal and signal.signal and signal.count then
					parameters[index] = {index=index, signal=signal.signal, count= math.floor(signal.count)}
					index = index + 1
				end
			end
        end
        struct.entities.output.get_control_behavior().parameters = {parameters = parameters}
    end
end

local function runProgramTick(struct)
	tickProgram(struct)
end

function tickStructure(struct)
	if struct.entities.power.energy >= 10 and struct.data.runMode then 
		readInputs(struct)			-- first step is sample the inputs
		runProgramTick(struct)		-- next we process all the code in the unit
		writeOutputs(struct)		-- then we output the resulting outputs
	end
end

local function createSubentity(mainEntity, subEntityType, xOffset, yOffset)
	position = {x = mainEntity.position.x + xOffset,y = mainEntity.position.y + yOffset}
	local area = {
		{position.x - 1.5, position.y - 1.5}, 
		{position.x + 1.5, position.y + 1.5}
	}
    -- position MUST be in area for revive return to work
    local ghost = false
    local ghosts = mainEntity.surface.find_entities_filtered { area = area, name = "entity-ghost", force = mainEntity.force }
    for _, each_ghost in pairs(ghosts) do
        if each_ghost.valid and each_ghost.ghost_name == subEntityType then
            if ghost then
                -- can't have two of the same type
                each_ghost.destroy()
            else
                each_ghost.revive()
                if not each_ghost.valid then 
					ghost = true		-- revive was successful
                else 
					each_ghost.destroy()						-- revive failed
                end
            end
        end
    end

    if ghost then
        local entity = mainEntity.surface.find_entities_filtered{area = area, name = subEntityType, force = mainEntity.force, limit = 1 }[1]
        if entity then
            entity.direction = defines.direction.south
            entity.teleport(position)
			entity.destructible = false
			entity.operable = false
            return entity
        end
    else
        return mainEntity.surface.create_entity{name = subEntityType, position = position, force = mainEntity.force, fast_replace = false, destructible = false, operable = false}
    end
end

function manageNewStructure(entity)
    if entity.backer_name then entity.backer_name = "" end
	entity.operable = false
	entity.energy = 0
	local structId = global.nextStructId
	local structure = {
		id = structId,
		entities = {
			main = entity,
			input = createSubentity(entity, "plc-input", -1.0, -1.0),
			output = createSubentity(entity, "plc-output", 1.0, -1.0),
			power = createSubentity(entity, "plc-power", 0.0, 0.0)
		},
		-- TODO: different for other tiers of structure
		program = {
			inputCount = 8,
			inputs = {},
			outputCount = 8,
			outputs = {},
			programCount = 100,
			program = {}
		},
		data = {
			inputs = {},
			outputs = {},
			variables = {},
			runMode = false,
			execNext = true
		}
	}
	global.unitNumbers[structure.entities.main.unit_number] = structId
	global.unitNumbers[structure.entities.input.unit_number] = structId
	global.unitNumbers[structure.entities.output.unit_number] = structId
	global.unitNumbers[structure.entities.power.unit_number] = structId
	
	global.structures[structId] = structure
	
	global.nextStructId = global.nextStructId + 1
	for line = 1, structure.program.programCount do
		structure.program.program[line] = {cmd = 1, params = {}}
	end
	for line = 1, structure.program.inputCount do
		structure.program.inputs[line] = {signal = nil, name = ""}
	end
	for line = 1, structure.program.outputCount do
		structure.program.outputs[line] = {signal = nil, name = ""}
	end
end

local function onBuiltEntity(event)
    local entity = event.created_entity
    if entity.name == "plc-unit" then
		manageNewStructure(entity) 
	end 
	if entity.name == "entity-ghost" and entity.ghost_name == "plc-unit" then
		-- add ghost to list for future handling
		global.ghosts[entity.unit_number] = { 
			struct_type = _, 
			entity = entity, 
			position = {x = entity.position.x, y = entity.position.y}, 
			surface = entity.surface, 
			force = entity.force
		}
	end
end


script.on_event(defines.events.on_built_entity, onBuiltEntity)
script.on_event(defines.events.on_robot_built_entity, onBuiltEntity)

script.on_event(defines.events.on_pre_player_mined_item, onDead)
script.on_event(defines.events.on_robot_pre_mined, onDead)
script.on_event(defines.events.on_entity_died, onDead)
