local binary_reader_class = require("../utilities/binary_reader")

local line_info = {}
line_info.__index = line_info

function line_info.new(binary_reader: binary_reader_class.Class, instructions_table: { instructions_size: number, instructions: { number } })
    local self = setmetatable({}, line_info)

    self.log_span = binary_reader:read_u8()

    -- TODO: Figure this out, for now just skipping

    for _ = 1, instructions_table.instructions_size do
        binary_reader:read_u8()
    end

    for _ = 1, bit32.rshift(instructions_table.instructions_size - 1, self.log_span) + 1 do
        binary_reader:read_u32()
    end

    return self
end

export type Class = typeof(line_info.new(nil :: never))

return line_info