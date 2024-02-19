
require "intellisense"

---Get the dropdown index for the io type/index
---@param dropdown_link PlcDropdownInfo
---@param entry	PlcParameter
---@return integer
function dropdown_indexof(dropdown_link, entry)
	for i, l in ipairs(dropdown_link.link) do
		if entry.type == l.type and i == l.index then
			return i
		end
	end
	return 0
end

--- Gets a list of the input/output/variable names to select from as well as the constant entry
---@param struct PlcData
function update_param_lists(struct)
	-- clear the dropdown lists
	struct.data.input_dropdown = {
		strings = {
			"Nothing",
			"Constant",
		},
		link = {
			{ type = "invalid", value = 0},
			{ type = "invalid", value = 0},
		},
	}
	struct.data.output_dropdown = {
		strings = {},
		link = {},
	}
	-- recalculate the defined inputs into the input parameters
	for line, entry in ipairs(struct.program.inputs) do
		if entry ~= nil and entry.name ~= nil and entry.name ~= "" then
			table.insert(struct.data.input_dropdown.link, entry)
			table.insert(struct.data.input_dropdown.strings, entry.name)
		end
	end
	-- recalculate the defined outputs into the input and output parameters
	for line, entry in ipairs(struct.program.outputs) do
		if entry ~= nil and entry.name ~= nil and entry.name ~= "" then
			table.insert(struct.data.input_dropdown.link, entry)
			table.insert(struct.data.input_dropdown.strings, entry.name)
			table.insert(struct.data.output_dropdown.link, entry)
			table.insert(struct.data.output_dropdown.strings, entry.name)
		end
	end
	-- recalculate the variables into the input and output parameters
	for line, entry in ipairs(struct.program.variables) do
		if entry ~= nil and entry.name ~= nil and entry.name ~= "" then
			table.insert(struct.data.input_dropdown.link, entry)
			table.insert(struct.data.input_dropdown.strings, entry.name)
			table.insert(struct.data.output_dropdown.link, entry)
			table.insert(struct.data.output_dropdown.strings, entry.name)
		end
	end
	-- if the outputs are empty we add a fake one
	if #struct.data.output_dropdown.link == 0 then
		table.insert(struct.data.output_dropdown.link, { type = "invalid", value = 0 })
		table.insert(struct.data.output_dropdown.strings, "None Defined")
	end
end
