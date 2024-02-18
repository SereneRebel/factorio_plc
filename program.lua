-- file dedicated to the inner workings of the PLC
require "intellisense"

local M = {}
local ifBlock = {
	level = 0,
	executing = {},
	dead = {}
}

---Set parameter output
---@param struct PlcData
---@param command PlcProgramEntry
---@param value number
local function set_output(struct, command, value)
	local link = struct.program.output_links[command.out_param]
	if link.output ~= nil then
		struct.data.variables[struct.program.outputs[link.output].name] = value
	elseif link.variable ~= nil then
		struct.data.variables[struct.program.variables[link.variable].name] = value
	end
end

---Get single parameter value
---@param struct PlcData
---@param command PlcProgramEntry
---@return param_single_value
local function get_single_input(struct, command)
	---@type param_single_value
	local value = { valid = false, value_a = 0 }
	if command.in_param_a == 1 then
		value.value_a = command.in_const_a
		value.valid = true
	else
		local link = struct.program.input_links[command.in_param_a]
		if link.input ~= nil then
			value.value_a = struct.data.variables[struct.program.inputs[link.input].name]
			value.valid = true
		elseif link.output ~= nil then
			value.value_a = struct.data.variables[struct.program.outputs[link.output].name]
			value.valid = true
		elseif link.variable ~= nil then
			value.value_a = struct.data.variables[struct.program.variables[link.variable].name]
			value.valid = true
		end
	end
	return value
end

---Get dual parameter values
---@param struct PlcData
---@param command PlcProgramEntry
---@return param_dual_value
local function get_dual_input(struct, command)
	---@type param_dual_value
	local value = { valid = false, value_a = 0, value_b = 0 }
	if command.in_param_a == 1 then
		value.value_a = command.in_const_a
		value.valid = true
	else
		local link = struct.program.input_links[command.in_param_a]
		if link.input ~= nil then
			value.value_a = struct.data.variables[struct.program.inputs[link.input].name]
			value.valid = true
		elseif link.output ~= nil then
			value.value_a = struct.data.variables[struct.program.outputs[link.output].name]
			value.valid = true
		elseif link.variable ~= nil then
			value.value_a = struct.data.variables[struct.program.variables[link.variable].name]
			value.valid = true
		end
	end
	if not value.valid then
		return value
	end
	value.valid = false
	if command.in_param_b == 1 then
		value.value_b = command.in_const_b
		value.valid = true
	else
		local link = struct.program.input_links[command.in_param_b]
		if link.input ~= nil then
			value.value_b = struct.data.variables[struct.program.inputs[link.input].name]
			value.valid = true
		elseif link.output ~= nil then
			value.value_b = struct.data.variables[struct.program.outputs[link.output].name]
			value.valid = true
		elseif link.variable ~= nil then
			value.value_b = struct.data.variables[struct.program.variables[link.variable].name]
			value.valid = true
		end
	end
	return value
end

local function noop(structure, command)

end


local function n_eq(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		local o = input.value_a == input.value_b
		set_output(structure, command, o and 1 or 0)
	end
end


local function n_gt(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		local o = input.value_a > input.value_b
		set_output(structure, command, o and 1 or 0)
	end
end


local function n_gte(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		local o = input.value_a >= input.value_b
		set_output(structure, command, o and 1 or 0)
	end
end


local function n_lt(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		local o = input.value_a < input.value_b
		set_output(structure, command, o and 1 or 0)
	end
end


local function n_lte(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		local o = input.value_a <= input.value_b
		set_output(structure, command, o and 1 or 0)
	end
end


local function l_and(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		local a = input.value_a > 0
		local b = input.value_b > 0
		local o = (a and b)
		set_output(structure, command, o and 1 or 0)
	end
end


local function l_or(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		local a = input.value_a > 0
		local b = input.value_b > 0
		local o = (a or b)
		set_output(structure, command, o and 1 or 0)
	end
end


local function l_not(structure, command)
	local input = get_single_input(structure, command)
	if input.valid then
		local a = input.value_a > 0
		local o = (not a)
		set_output(structure, command, o and 1 or 0)
	end
end


local function l_xor(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		local a = input.value_a > 0
		local b = input.value_b > 0
		local o = (a and not b) or (not a and b)
		set_output(structure, command, o and 1 or 0)
	end
end


local function n_add(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		set_output(structure, command, input.value_a + input.value_b)
	end
end


local function n_sub(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		set_output(structure, command, input.value_a - input.value_b)
	end
end


local function n_mul(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		set_output(structure, command, input.value_a * input.value_b)
	end
end


local function n_div(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		if input.value_b > 0 then
			set_output(structure, command, input.value_a / input.value_b)
		else
			set_output(structure, command, 0)
		end
	end
end


local function n_mod(structure, command)
	local input = get_dual_input(structure, command)
	if input.valid then
		if input.value_b > 0 then
			set_output(structure, command, math.fmod(input.value_a, input.value_b) )
		else
			set_output(structure, command, 0)
		end
	end
end


local function p_if(structure, command)
	-- if (param1>0) then execute the next command otherwise dont
	local input = get_single_input(structure, command)
	if input.valid then
		local exec, dead = true, false
		if ifBlock.level == 0 then
			exec = (input.value_a > 0)
			dead = false
		else
			if ifBlock.executing[ifBlock.level] and not ifBlock.dead[ifBlock.level] then
				exec = (input.value_a > 0)
				dead = false
			else
				exec = false
				dead = true
			end
		end
		ifBlock.level = ifBlock.level + 1
		ifBlock.executing[ifBlock.level] = exec
		ifBlock.dead[ifBlock.level] = dead
	end
end
local function p_else(structure, command)
	if ifBlock.level > 0 and not ifBlock.dead[ifBlock.level] then
		if ifBlock.executing[ifBlock.level] then 
			ifBlock.executing[ifBlock.level] = false
		else
			ifBlock.executing[ifBlock.level] = true
		end
	end
end
local function p_ifend(structure, command)
	if ifBlock.level > 0 then
		ifBlock.level = ifBlock.level - 1
	end
end

---Move input parameter to output parameter
---@param structure PlcData
---@param command PlcProgramEntry
local function n_mov(structure, command)
	local input = get_single_input(structure, command)
	if input.valid then
		set_output(structure, command, input.value_a)
	end
end
-- note: always add new commands to end of list

---@type command_info[]
M.commandList = {
	{disp = "NO-OP", 	func = noop , 	in_a = false, in_b = false, out = false, ov = false},
	{disp = "EQ" , 		func = n_eq , 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "GT" , 		func = n_gt , 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "GTE", 		func = n_gte, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "LT" , 		func = n_lt , 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "LTE", 		func = n_lte, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "AND", 		func = l_and, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "OR" , 		func = l_or , 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "NOT", 		func = l_not, 	in_a = true, in_b = false, out = true,  ov = false},
	{disp = "XOR",	 	func = l_xor, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "ADD", 		func = n_add, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "SUB", 		func = n_sub, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "MUL", 		func = n_mul, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "DIV", 		func = n_div, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "MOD", 		func = n_mod, 	in_a = true, in_b = true, out = true,  ov = false},
	{disp = "IF" , 		func = p_if , 	in_a = true, in_b = false, out = false,  ov = true},
	{disp = "ELSE", 	func = p_else, 	in_a = false, in_b = false, out = false,  ov = true},
	{disp = "IF END", 	func = p_ifend, in_a = false, in_b = false, out = false,  ov = true},
	{disp = "MOVE", 	func = n_mov, 	in_a = true, in_b = false, out = true,  ov = false},
}

---Reads all the signals from incoming curcuit network
---@param struct PlcData
function M.tickProgram(struct)
	for _, command in pairs(struct.program.commands) do
		local cmd = M.commandList[command.command]
		-- we cannot use regular exec = execNext because it would be a reference to the same memory
		if cmd then
			-- level 0 is base level so we execute everything
			if ifBlock.level == 0 then
				cmd.func(struct, command)
			elseif cmd.ov then 
				cmd.func(struct, command)
			elseif ifBlock.executing[ifBlock.level] and not ifBlock.dead[ifBlock.level] then
				cmd.func(struct, command)
			end
		end
	end
end

---Check the program and report any errors
---@param struct PlcData
function M.check_program(struct)
	struct.data.status = { status="ok", msg="Program Ok" }
	-- check input params
	local in_def = false
	for i, p in ipairs(struct.program.inputs) do
		-- any signal has a name and a signal selected
		if p.name ~= nil and p.name ~= "" and p.signal ~= nil then
			in_def = true
		end
	end
	if not in_def then
		struct.data.status = { status="warn", msg="No input signals defined"}
	end
	-- check outputs
	local out_def = false
	for i, p in ipairs(struct.program.outputs) do
		-- any signal has a name and a signal selected
		if p.name ~= nil and p.name ~= "" and p.signal ~= nil then
			out_def = true
		end
	end
	if not out_def then
		struct.data.status = { status="error", msg="No output signals defined"}
		return
	end
	-- check program
	local prog_def = false
	local if_level = 0
	for i, p in ipairs(struct.program.commands) do
		local cmd = M.commandList[p.command]
		if p.command ~= 1 then -- NOOP
			prog_def = true
		end
		-- check params for command
		if cmd.in_a and not cmd.in_b and not cmd.out and p.in_param_a == 1 then -- signle parameter is constant with no output
			struct.data.status = {status="warn", msg="Single parameter command is constant"}
		end
		if cmd.disp == "IF" then
			if_level = if_level + 1
		elseif cmd.disp == "IF END" then
			if_level = if_level - 1
		end
	end
	if not prog_def then
		struct.data.status = {status="warn", msg="No program defined"}
	end
	if if_level > 0 then
		struct.data.status = {status="error", msg="Too many \"IF\" commands without \"IF END\" commands"}
	elseif if_level < 0 then
		struct.data.status = {status="error", msg="Not enough \"IF\" commands without \"IF END\" commands"}
	end
end

return M
