-- file dedicated to the inner workings of the PLC
require "intellisense"

local M = {}
local ifBlock = {
	level = 0,
	executing = {},
	dead = {}
}

local function isVariable(str)
	if str and string.match(str, "^(%a+)") then
		return true
	else
		return false
	end
end
local function isConst(str)
	if str and (string.match(str, "^(%d+)") or string.match(str, "^-(%d+)")) then
		return true
	else
		return false
	end
end
local function check_param(structure, parameter)
	if isVariable(parameter) then
		return true, structure.data.variables[parameter] or 0
	elseif isConst(parameter) then
		return true, tonumber(parameter)
	else
		return false, nil
	end
end
local function check_triplet(structure, command)
	local good, p1, p2
	good, p1 = check_param(structure, command.parameter1)
	if not good then
		return false, nil, nil
	end
	good, p2 = check_param(structure, command.parameter2)
	if not good then
		return false, nil, nil
	end
	if not isVariable(command.parameter3) then
		return false, nil, nil
	end
	return true, p1, p2
end
local function check_tuple(structure, command)
	local good, p1
	good, p1 = check_param(structure, command.parameter1)
	if not good then
		return false, nil
	end
	if not isVariable(command.parameter2) then
		return false, nil
	end
	return true, p1
end
local function check_single(structure, command)
	local good
	good, p1 = check_param(structure, command.parameter1)
	if not good then
		return false, nil
	end
	return true, p1
end
local function noop(structure, command)

end
local function n_eq(structure, command)
	-- param3 = (param1 == param2)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if p1 == p2 then
			structure.data.variables[command.parameter3] = 1
		else
			structure.data.variables[command.parameter3] = 0
		end
	end
end
local function n_gt(structure, command)
	-- param3 = (param1 > param2)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if p1 > p2 then
			structure.data.variables[command.parameter3] = 1
		else
			structure.data.variables[command.parameter3] = 0
		end
	end
end
local function n_gte(structure, command)
	-- param3 = (param1 >= param2)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if p1 >= p2 then
			structure.data.variables[command.parameter3] = 1
		else
			structure.data.variables[command.parameter3] = 0
		end
	end
end
local function n_lt(structure, command)
	-- param3 = (param1 < param2)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if p1 < p2 then
			structure.data.variables[command.parameter3] = 1
		else
			structure.data.variables[command.parameter3] = 0
		end
	end
end
local function n_lte(structure, command)
	-- param3 = (param1 == param2)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if p1 <= p1 then
			structure.data.variables[command.parameter3] = 1
		else
			structure.data.variables[command.parameter3] = 0
		end
	end
end
local function l_and(structure, command)
	-- param3 = (param1>0 and param2>0)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if (p1 > 0) and (p2 > 0) then
			structure.data.variables[command.parameter3] = 1
		else
			structure.data.variables[command.parameter3] = 0
		end
	end
end
local function l_or(structure, command)
	-- param3 = (param1>0 or param2>0)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if (p1 > 0) or (p2 > 0) then
			structure.data.variables[command.parameter3] = 1
		else
			structure.data.variables[command.parameter3] = 0
		end
	end
end
local function l_not(structure, command)
	-- param3 = not (param1>0)
	local good, p1 = check_tuple(structure, command)
	if good then
		if not (p1 > 0) then
			structure.data.variables[command.parameter2] = 1
		else
			structure.data.variables[command.parameter2] = 0
		end
	end
end
local function l_xor(structure, command)
	-- param3 = (param1>0 and param2>0)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if ((p1 > 0) and not (p2 > 0)) or (not (p1 > 0) and (p2 > 0)) then
			structure.data.variables[command.parameter3] = 1
		else
			structure.data.variables[command.parameter3] = 0
		end
	end
end
local function n_add(structure, command)
	-- param3 = (param1>0 and param2>0)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		structure.data.variables[command.parameter3] = p1 + p2
	end
end
local function n_sub(structure, command)
	-- param3 = (param1>0 and param2>0)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		structure.data.variables[command.parameter3] = p1 - p2
	end
end
local function n_mul(structure, command)
	-- param3 = (param1>0 and param2>0)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		structure.data.variables[command.parameter3] = p1 * p2
	end
end
local function n_div(structure, command)
	-- param3 = (param1>0 and param2>0)
	local good, p1, p2 = check_triplet(structure, command)
	if good then
		if p2 == 0 then
			structure.data.variables[command.parameter3] = 0
		else
			structure.data.variables[command.parameter3] = p1 / p2
		end
	end
end
local function p_if(structure, command)
	-- if (param1>0) then execute the next command otherwise dont
	local good, p1 = check_single(structure, command)
	if good then
		local exec, dead = true, false
		if ifBlock.level == 0 then
			exec = (p1 > 0)
			dead = false
		else
			if ifBlock.executing[ifBlock.level] and not ifBlock.dead[ifBlock.level] then
				exec = (p1 > 0)
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
local function n_mov(structure, command)
	-- param2 = param1
	local good, p1 = check_tuple(structure, command)
	if good then
		if isVariable(command.parameter1) then
				structure.data.variables[command.parameter2] = structure.data.variables[command.parameter1]
		elseif isConst(command.parameter1) then
				structure.data.variables[command.parameter2] = tonumber(command.parameter1)
		end
	end
end

M.commandList = {
	{disp = "NO-OP", 	func = noop , 	params = 0, ov = false},
	{disp = "EQ" , 		func = n_eq , 	params = 3, ov = false},
	{disp = "GT" , 		func = n_gt , 	params = 3, ov = false},
	{disp = "GTE", 		func = n_gte, 	params = 3, ov = false},
	{disp = "LT" , 		func = n_lt , 	params = 3, ov = false},
	{disp = "LTE", 		func = n_lte, 	params = 3, ov = false},
	{disp = "AND", 		func = l_and, 	params = 3, ov = false},
	{disp = "OR" , 		func = l_or , 	params = 3, ov = false},
	{disp = "NOT", 		func = l_not, 	params = 2, ov = false},
	{disp = "XOR",	 	func = l_xor, 	params = 3, ov = false},
	{disp = "ADD", 		func = n_add, 	params = 3, ov = false},
	{disp = "SUB", 		func = n_sub, 	params = 3, ov = false},
	{disp = "MUL", 		func = n_mul, 	params = 3, ov = false},
	{disp = "DIV", 		func = n_div, 	params = 3, ov = false},
	{disp = "IF" , 		func = p_if , 	params = 1, ov = true},
	{disp = "ELSE", 	func = p_else, 	params = 0, ov = true},
	{disp = "IF END", 	func = p_ifend, params = 0, ov = true},
	{disp = "MOVE", 	func = n_mov, 	params = 2, ov = false},
}

---Reads all the signals from incoming curcuit network
---@param struct structure_table
function M.tickProgram(struct)
	for _, command in pairs(struct.program.program_data) do
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

return M
