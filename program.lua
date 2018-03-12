-- file dedicated to the inner workings of the PLC

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
local function getParams(structure, command, count)
	local p = {}
	if command.params then
		for ind = 1, count do
			if isVariable(command.params[ind]) then
				p[ind] = structure.data.variables[command.params[ind]] or 0
			elseif isConst(command.params[ind]) then
				p[ind] = tonumber(command.params[ind])
			else
				return nil
			end
		end
	else
		return nil
	end
	return p
end
local function noop(structure, command)
	
end
local function n_eq(structure, command)
	-- param3 = (param1 == param2)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if params[1] == params[2] then
		structure.data.variables[command.params[3]] = 1
	else
		structure.data.variables[command.params[3]] = 0
	end
end
local function n_gt(structure, command)
	-- param3 = (param1 > param2)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if params[1] > params[2] then
		structure.data.variables[command.params[3]] = 1
	else
		structure.data.variables[command.params[3]] = 0
	end
end
local function n_gte(structure, command)
	-- param3 = (param1 >= param2)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if params[1] >= params[2] then
		structure.data.variables[command.params[3]] = 1
	else
		structure.data.variables[command.params[3]] = 0
	end
end
local function n_lt(structure, command)
	-- param3 = (param1 < param2)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if params[1] < params[2] then
		structure.data.variables[command.params[3]] = 1
	else
		structure.data.variables[command.params[3]] = 0
	end
end
local function n_lte(structure, command)
	-- param3 = (param1 == param2)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if params[1] <= params[2] then
		structure.data.variables[command.params[3]] = 1
	else
		structure.data.variables[command.params[3]] = 0
	end
end
local function l_and(structure, command)
	-- param3 = (param1>0 and param2>0)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if (params[1] > 0) and (params[2] > 0) then
		structure.data.variables[command.params[3]] = 1
	else
		structure.data.variables[command.params[3]] = 0
	end
end
local function l_or(structure, command)
	-- param3 = (param1>0 or param2>0)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if (params[1] > 0) or (params[2] > 0) then
		structure.data.variables[command.params[3]] = 1
	else
		structure.data.variables[command.params[3]] = 0
	end
end
local function l_not(structure, command)
	-- param3 = not (param1>0)
	local params = getParams(structure, command, 1)
	if not params then return end
	if not isVariable(command.params[2]) then return end
	if not (params[1] > 0) then
		structure.data.variables[command.params[2]] = 1
	else
		structure.data.variables[command.params[2]] = 0
	end
end
local function l_xor(structure, command)
	-- param3 = (param1>0 and param2>0)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if ((params[1] > 0) and not (params[2] > 0)) or (not (params[1] > 0) and (params[2] > 0)) then
		structure.data.variables[command.params[3]] = 1
	else
		structure.data.variables[command.params[3]] = 0
	end
end
local function n_add(structure, command)
	-- param3 = (param1>0 and param2>0)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	structure.data.variables[command.params[3]] = params[1] + params[2]
end
local function n_sub(structure, command)
	-- param3 = (param1>0 and param2>0)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	structure.data.variables[command.params[3]] = params[1] - params[2]
end
local function n_mul(structure, command)
	-- param3 = (param1>0 and param2>0)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	structure.data.variables[command.params[3]] = params[1] * params[2]
end
local function n_div(structure, command)
	-- param3 = (param1>0 and param2>0)
	local params = getParams(structure, command, 2)
	if not params then return end
	if not isVariable(command.params[3]) then return end
	if params[2] == 0 then 
		structure.data.variables[command.params[3]] = 0 
	else
		structure.data.variables[command.params[3]] = params[1] / params[2]
	end
end
local ifBlock = {
	level = 0,
	executing = {},
	dead = {}
}


local function p_if(structure, command)
	-- if (param1>0) then execute the next command otherwise dont
	local params = getParams(structure, command, 1)
	if not params then return end
	local exec, dead = true, false
	if ifBlock.level == 0 then
		exec = (params[1] > 0)
		dead = false
	else
		if ifBlock.executing[ifBlock.level] and not ifBlock.dead[ifBlock.level] then
			exec = (params[1] > 0)
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
	local params = getParams(structure, command, 1)
	if not params then return end
	if not isVariable(command.params[2]) then return end
		if isVariable(command.params[1]) then
				structure.data.variables[command.params[2]] = structure.data.variables[command.params[1]]
		elseif isConst(command.params[1]) then
				structure.data.variables[command.params[2]] = tonumber(command.params[1])
		end
end

commandList = {
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
function tickProgram(structure)
	for _, command in pairs(structure.program.program) do
		local cmd = commandList[command.cmd]
		-- we cannot use regular exec = execNext because it would be a reference to the same memory
		if cmd then
			-- level 0 is base level so we execute everything
			if ifBlock.level == 0 then
				cmd.func(structure, command)
			elseif cmd.ov then 
				cmd.func(structure, command)
			elseif ifBlock.executing[ifBlock.level] and not ifBlock.dead[ifBlock.level] then
				cmd.func(structure, command)
			end
		end
	end
end