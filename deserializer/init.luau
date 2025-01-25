local binary_reader_class = require("utilities/binary_reader")
local version_class = require("classes/version")
local string_table_class = require("classes/string_table")
local func_class = require("classes/func")

local deserializer = {}
deserializer.__index = deserializer

function deserializer.new(bytecode: buffer)
    local self = setmetatable({}, deserializer)

    self.binary_reader = binary_reader_class.new(bytecode)
    
    self.version = version_class.new(self.binary_reader)
    self.string_table = string_table_class.new(self.binary_reader)

    -- TODO: Read userdata type remapping table (typesversion >= 3)

    self.functions = self:read_functions()


    return self
end

function deserializer:read_functions()
    local functions_size: number = self.binary_reader:read_var_int()

    local functions: { func_class.Class } = table.create(functions_size)
    for function_index: number = 1, functions_size do
        functions[function_index] = func_class.new(self.binary_reader, self.string_table)
    end

    return functions
end

return deserializer