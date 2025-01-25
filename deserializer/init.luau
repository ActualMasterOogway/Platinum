local binary_reader_class = require("utilities/binary_reader")
local version_class = require("classes/version")
local string_table_class = require("classes/string_table")

local deserializer = {}
deserializer.__index = deserializer

function deserializer.new(bytecode: buffer)
    local self = setmetatable({}, deserializer)

    self.binary_reader = binary_reader_class.new(bytecode)
    
    self.version = version_class.new(self.binary_reader)
    self.string_table = string_table_class.new(self.binary_reader)

    return self
end


return deserializer