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

    if (self.version.bytecode_version >= 6) then
        self.userdata_types = self:read_userdata_types()
    end
    
    self.functions = self:read_functions()

    self.main_function_index = self.binary_reader:read_var_int() + 1

    if (self.binary_reader.offset ~= buffer.len(bytecode)) then
        print(`WARNING: Bytecode was not parsed properly ({self.binary_reader.offset}/{buffer.len(bytecode)})`)
    end

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

function deserializer:read_userdata_types()
    local userdata_types = {}

    while (true) do
        local index: number = self.binary_reader:read_u8()
        if (index == 0) then break end

        local name_ref: number = self.binary_reader:read_var_int()
        table.insert(userdata_types, { index = index, name_ref = name_ref })
    end

    return userdata_types
end

return deserializer