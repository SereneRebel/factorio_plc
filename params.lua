
require "intellisense"

--- Gets a list of the input/output/variable names to select from as well as the constant entry
---@param struct PlcData
---@param process_program boolean?
function update_param_lists(struct, process_program)
	if process_program == nil then
		process_program = true
	end
	-- create cross-reference table
	local in_cross_ref = {}
	local var_cross_ref = {}
	local out_cross_ref = {}
	-- clear the new parameter lists
	input_list = { "Constant" }
	input_links = { { input = nil, output = nil, variable = nil } }
	output_list = {}
	output_links = {}
	-- recalculate the defined inputs into the input parameters
	local in_index = 2
	local out_index = 1
	for line, entry in ipairs(struct.program.inputs) do
		if entry ~= nil and entry.name ~= nil and entry.name ~= "" then
			table.insert(in_cross_ref, line, { input = in_index })
			in_index = in_index + 1
			table.insert(input_list, entry.name)
			table.insert(input_links, { input = line, output = nil, variable = nil })
		end
	end
	-- recalculate the defined outputs into the input and output parameters
	for line, entry in ipairs(struct.program.outputs) do
		if entry ~= nil and entry.name ~= nil and entry.name ~= "" then
			table.insert(out_cross_ref, line, { output = out_index, input = in_index })
			in_index = in_index + 1
			out_index = out_index + 1
			table.insert(input_list, entry.name)
			table.insert(input_links, { input = nil, output = line, variable = nil })
			table.insert(output_list, entry.name)
			table.insert(output_links, { input = nil, output = line, variable = nil })
		end
	end
	-- recalculate the variables into the input and output parameters
	for line, entry in ipairs(struct.program.variables) do
		if entry ~= nil and entry.name ~= nil and entry.name ~= "" then
			table.insert(var_cross_ref, line, { output = out_index, input = in_index })
			in_index = in_index + 1
			out_index = out_index + 1
			table.insert(input_list, entry.name)
			table.insert(input_links, { input = nil, output = nil, var_param = line })
			table.insert(output_list, entry.name)
			table.insert(output_links, { input = nil, output = nil, var_param = line })
		end
	end
	-- now we check all the commands to see if a used index has changed
	if process_program then
		for _, prog in ipairs(struct.program.commands) do
			local linka = struct.program.input_links[prog.in_param_a]
			if linka then
				if linka.input then
					prog.in_param_a = in_cross_ref[linka.input].input
				elseif linka.output then
					prog.in_param_a = out_cross_ref[linka.output].output
				elseif linka.variable then
					prog.in_param_a = var_cross_ref[linka.variable].variable
				else
					prog.in_param_a = 1
				end
			end
			local linkb = struct.program.input_links[prog.in_param_b]
			if linkb then
				if linkb.input then
					prog.in_param_b = in_cross_ref[linkb.input].input
				elseif linkb.output then
					prog.in_param_b = out_cross_ref[linkb.output].output
				elseif linkb.variable then
					prog.in_param_b = var_cross_ref[linkb.variable].variable
				else
					prog.in_param_b = 1
				end
			end
			local linko = struct.program.output_links[prog.out_param]
			if linko then
				if linko.output then
					prog.out_param = out_cross_ref[linko.output].output
				elseif linko.variable then
					prog.out_param = var_cross_ref[linko.variable].variable
				else
					prog.out_param = 1
				end
			end
		end
	end
	-- if the outputs are empty we add a fake one
	if #output_list == 0 then
		output_list = { "None Defined" }
		output_links = { { io_param = nil, var_param = nil, variable = nil } }
	end
	struct.program.input_links = input_links
	struct.program.output_links = output_links
	struct.program.input_list = input_list
	struct.program.output_list = output_list
end
