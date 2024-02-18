-- this fie is purely for vscode intellisense for my structures(tables)

do
    ---Parameter selector <-> parameter list linking
    ---@class param_link
    ---Input Param index
    ---@field input integer?
    ---Output Param index
    ---@field output integer?
    ---Variable index
    ---@field variable integer?
    local param_link = { }
end


do
    ---The entities used to make up the controller
    ---@class PlcEntities
    ---Main entity of the structure
    ---@field main      LuaEntity?
    ---Signal input entity of the structure
    ---@field input     LuaEntity?
    ---Signal output entity of the structure
    ---@field output    LuaEntity?
    local PlcEntities = { }
end

do
    ---The programs validity status
    ---@class PlcProgramStatus
    ---Status
    ---@field status    "ok"|"warn"|"error"
    ---Message
    ---@field msg       string
    local PlcEntities = { }
end

do
    ---The program data
    ---@class PlcProgramEntry
    ---Command index
    ---@field command integer|uint
    ---Input A Parameter index
    ---@field in_param_a integer
    ---Input A Constant value
    ---@field in_const_a number
    ---Input B Parameter index
    ---@field in_param_b integer
    ---Input B Constant value
    ---@field in_const_b number
    ---Output Parameter index
    ---@field out_param integer
    local PlcProgramEntry = { }
end

do
    ---The parameter data
    ---@class PlcParameter
    ---I/O name
    ---@field name string
    ---Signal
    ---@field signal SignalID?
    ---Wire type to read from
    ---@field wire string?
    ---Input dropdown index
    ---@field input_dropdown_index integer?
    ---Outut dropdown index
    ---@field output_dropdown_index integer?
    local parameter_data = { }
end

do
    ---The entities used to make up the controller
    ---@class PlcProgram
    ---The input definitions
    ---@field inputs            PlcParameter[]
    ---The output definitions
    ---@field outputs           PlcParameter[]
    ---Number of allowed variables
    ---@field variables         PlcParameter[]
    ---The program instructions
    ---@field commands          PlcProgramEntry[]
    ---List of input parameters to pick from
    ---@field input_list        string[]
    ---List of input parameter links
    ---@field input_links       param_link[]
    ---List of output parameters to pick from
    ---@field output_list       string[]
    ---List of output parameter links
    ---@field output_links      param_link[]
    local PlcProgram = { }
end

do
    ---Current run-time state variables
    ---@class PlcRuntimeVars
    ---Current variable values
    ---@field variables         table
    ---Is the program running?
    ---@field running           boolean
    ---Should we execute the lext line?
    ---@field execute_next      boolean
    ---GUI Callback registration
    ---@field cb_funcs          function[]
    ---Current program status
    ---@field status            PlcProgramStatus
    local PlcRuntimeVars = { }
end

do
    ---Structure data table
    ---@class PlcData
    ---Entities making up the structure
    ---@field entities      PlcEntities
    ---Configuration data table
    ---@field program       PlcProgram
    ---Current run-time data table
    ---@field data          PlcRuntimeVars
    local PlcData = { }
end


do
    ---Command information
    ---@class command_info
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
    local command_info = { }
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
