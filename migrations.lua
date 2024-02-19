
local program = require "program"

---Test if the string is only a number
---@param str string
---@return boolean
local function is_const(str)
	return str ~= nil and str ~= "" and (string.match(str, "^%d+") or string.match(str, "^%-%d+"))
end

---Test if the string is a parameter name
---@param str string
---@return boolean
local function is_variable(str)
	return str ~= nil and str ~= "" and string.match(str, "^%a+")
end

---Find the new parameter entry using the name
---@param name string
---@param struct PlcData
---@return PlcParameter?
local function get_param_or_const(name, struct)
	---@type PlcParameter?
	local parameter = nil
	if is_const(name) then
		parameter = {type = "Constant", name = nil, signal = nil, wire = nil, value = tonumber(name) or 0}
	elseif is_variable(name) then
		for _, param in ipairs(struct.program.variables) do
			if param.name == name then
				parameter = param
				break
			end
		end
		for _, param in ipairs(struct.program.outputs) do
			if param.name == name then
				parameter = param
				break
			end
		end
		for _, param in ipairs(struct.program.inputs) do
			if param.name == name then
				parameter = param
				break
			end
		end
	end
	return parameter
end

function migrate_to_2_0_0()
	local structs = global.plc_structures
	for _, struct in pairs(structs) do
		if struct.program.input_data ~= nil then
			-- fix up the structure for new version
			-- input params need to be moved to new index
			struct.program.inputs = {}
			for i, value in ipairs(struct.program.input_data) do
				---@type PlcParameter
				local new_entry = {type = "input",name = value.name, signal = value.signal, wire = "none", value = 0}
				table.insert(struct.program.inputs, i, new_entry)
			end
			struct.program.input_data = nil
			-- output params need to be moved to new index
			struct.program.outputs = {}
			for i, value in ipairs(struct.program.output_data) do
				---@type PlcParameter
				local new_entry = {type = "output",name = value.name, signal = value.signal, wire = "none", value = 0}
				table.insert(struct.program.outputs, i, new_entry)
			end
			struct.program.output_data = nil
			-- variables need to be moved to new index
			struct.program.variables = {}
			for i, value in ipairs(struct.program.variable_data) do
				---@type PlcParameter
				local new_entry = {type = "variable",name = value.name, signal = value.signal, wire = "none", value = 0}
				table.insert(struct.program.variables, i, new_entry)
			end
			struct.program.variable_data = nil
			-- commands need to checked and re-setup with new info
			struct.program.commands = {}
			for i, value in ipairs(struct.program.program_data) do
				if value.command > 14 then
					value.command = value.command + 1
				end
				local command_info = program.commandList[value.command]
				local param_a = get_param_or_const(value.parameter1, struct)
				local param_b = get_param_or_const(value.parameter2, struct)
				local param_out = get_param_or_const(value.parameter3, struct)
				-- previously the output param may be 2 or 3
				if not command_info.in_b then
					-- this command is missing the 2nd param therefore the output one was param2
					param_out = param_b
					param_b = nil
				end
				---@type PlcProgramEntry
				local new_entry = {
					command = command_info,
					in_param_a = param_a,
					in_param_b = param_b,
					out_param = param_out,
				}
				table.insert(struct.program.commands, i, new_entry)
			end
			struct.program.program_data = nil
			
			if struct.data.running then
				struct.data.running = false
				-- notify player of stopped PLC
				struct.data.alert = "PLC Program has been stopped due to migration"
			end
		end
	end
end