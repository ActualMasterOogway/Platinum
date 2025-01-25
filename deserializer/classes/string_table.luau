local binary_reader_class = require("../utilities/binary_reader")

local string_table = {}
string_table.__index = string_table

function string_table.new(binary_reader: binary_reader_class.Class)
    local self = setmetatable({}, string_table)

    self.string_count = binary_reader:read_var_int()
    self.strings = table.create(self.string_count)

    for index: number = 1, self.string_count do
        self.strings[index] = binary_reader:read_string()
    end

    return self
end

return string_table