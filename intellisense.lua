-- this fie is purely for vscode intellisense for my structures(tables)

do
	---The entities used to make up the controller
	---@class PlcEntities
	---Main entity of the structure
	---@field main		LuaEntity?
	---Signal input entity of the structure
	---@field input		LuaEntity?
	---Signal output entity of the structure
	---@field output	LuaEntity?
	local PlcEntities = { }
end

do
	---The programs validity status
	---@class PlcProgramStatus
	---Status
	---@field status	"ok"|"warn"|"error"
	---Message
	---@field msg		string
	local PlcProgramStatus = { }
end

do
	---Command information
	---@class PlcCommand
	---Command display string
	---@field disp string
	---Input A required
	---@field in_a boolean
	---Input B required
	---@field in_b boolean
	---Output required
	---@field out boolean
	---Override for interrupting none execution
	---@field ov boolean
	local PlcCommand = { }
end
do
	---Command information
	---@class PlcCommandDef
	---Command display string
	---@field disp string
	---Command function pointer
	---@field func function
	---Input A required
	---@field in_a boolean
	---Input B required
	---@field in_b boolean
	---Output required
	---@field out boolean
	---Override for interrupting none execution
	---@field ov boolean
	local PlcCommandDef = { }
end

do
	---The program data
	---@class PlcProgramEntry
	---Command index
	---@field command			PlcCommand
	---Input A Parameter
	---@field in_param_a		PlcParameter?
	---Input B Parameter
	---@field in_param_b		PlcParameter?
	---Output Parameter
	---@field out_param			PlcParameter?
	local PlcProgramEntry = { }
end

do
	---The parameter data
	---@class PlcParameter
	---Parameter Type
	---@field	type		"input"|"output"|"variable"|"constant"|"invalid"
	---I/O name
	---@field	name		string?
	---Signal
	---@field	signal		SignalID?
	---Wire type of input
	---@field	wire		string?
	---Current value
	---@field	value		number
	local PlcParameter = { }
end

do
	---The entities used to make up the controller
	---@class PlcProgram
	---The input definitions
	---@field inputs			PlcParameter[]
	---The output definitions
	---@field outputs			PlcParameter[]
	---The variable definitions
	---@field variables			PlcParameter[]
	---The program instructions
	---@field commands			PlcProgramEntry[]
	local PlcProgram = { }
end

do
	---Info used for GUI dropdowns <-> params
	---@class PlcDropdownInfo
	---Text for dropdown.items
	---@field strings	string[]
	---Parameter info linked to this item
	---@field link		PlcParameter[]
	local PlcDropdownInfo = {}
end

do
	---Info used for GUI dropdowns <-> params
	---@class PlcDropdownInfoCmd
	---Text for dropdown.items
	---@field strings	string[]
	---Parameter info linked to this item
	---@field link		PlcCommand[]
	local PlcDropdownInfo = {}
end

do
	---Current run-time state variables
	---@class PlcRuntimeVars
	---Is the program running?
	---@field running			boolean
	---Should we execute the lext line?
	---@field execute_next		boolean
	---GUI Callback registration
	---@field cb_funcs			function[]
	---Current program status
	---@field status			PlcProgramStatus
	---Input parameter dropdown box info
	---@field input_dropdown	PlcDropdownInfo
	---Input parameter dropdown box info
	---@field output_dropdown	PlcDropdownInfo
	---Command dropdown box info
	---@field command_dropdown	PlcDropdownInfoCmd
	---Live values display page
	---@field live_page			LuaGuiElement?
	---Alarms for when migrations stop a plc
	---@field alert				string?
	---Tick number to re-check alerts
	---@field alert_holdoff		integer
	local PlcRuntimeVars = { }
end

do
	---Structure data table
	---@class PlcData
	---Entities making up the structure
	---@field entities		PlcEntities
	---Configuration data table
	---@field program		PlcProgram
	---Current run-time data table
	---@field data			PlcRuntimeVars
	local PlcData = { }
end






do
	---Single parameter value return
	---@class param_single_value
	---Is param valid
	---@field valid boolean
	---Parameter a value
	---@field value_a number
	local param_single_value = { }
end

do
	---Dual parameter value return
	---@class param_dual_value
	---Is param valid
	---@field valid boolean
	---Parameter a value
	---@field value_a number
	---Parameter b value
	---@field value_b number
	local param_dual_value = { }
end
