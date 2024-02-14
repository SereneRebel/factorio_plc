-- this fie is purely for vscode intellisense for my structures(tables)
do
    ---The entities used to make up the controller
    ---@class structure.entities
    ---Main entity of the structure
    ---@field main LuaEntity
    ---Signal input entity of the structure
    ---@field input LuaEntity
    ---Signal output entity of the structure
    ---@field output LuaEntity
    local structure_entities = { }
end
do
    ---The program data
    ---@class structure.program.program_data
    ---Command index
    ---@field command integer|uint
    ---Parameter 1
    ---@field parameter1 string
    ---Parameter 2
    ---@field parameter2 string
    ---Parameter 3
    ---@field parameter3 string
    local prog_data = { }
end
do
    ---The input/output data
    ---@class structure.program.inputoutput_data
    ---I/O name
    ---@field name string
    ---Signal
    ---@field signal nil|SignalID
    ---Wire type to read from
    ---@field wire string
    local io_data = { }
end
do
    ---The variable data
    ---@class structure.program.variable_data
    ---Variable name
    ---@field name string
    local var_data = { }
end

do
    ---The entities used to make up the controller
    ---@class structure.program
    ---Number of allowed input signals
    ---@field input_count integer
    ---The input definitions
    ---@field input_data structure.program.inputoutput_data[]
    ---Number of allowed output signals
    ---@field output_count integer
    ---The output definitions
    ---@field output_data structure.program.inputoutput_data[]
     ---Number of allowed variables
    ---@field variable_count integer
    ---The variable definitions
    ---@field variable_data structure.program.variable_data[]
    ---Number of allowed program instructions
    ---@field program_count integer
    ---The program instructions
    ---@field program_data structure.program.program_data[]
    local structure_program = { }
end
do
    ---Current run-time state variables
    ---@class structure.data
    ---Current variable values
    ---@field variables table
    ---Is the program running?
    ---@field running boolean
    ---Should we execute the lext line?
    ---@field execute_next boolean
    local structure_data = { }
end
do
    ---Structure data table
    ---@class structure_table
    ---Entities making up the structure
    ---@field entities structure.entities
    ---Configuration data table
    ---@field program structure.program
    ---Current run-time data table
    ---@field data structure.data
    local structure_table = { }
end
