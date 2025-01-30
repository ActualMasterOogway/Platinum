local luau_spec = require("../luau/spec")
local binary_reader_class = require("../utilities/binary_reader")

local instruction = {}
instruction.__index = instruction

function instruction.new(binary_reader: binary_reader_class.Class, value: number)
    local self = setmetatable({}, instruction)
    
    for _, opcode_information in luau_spec.LuauOpcode do
        if (opcode_information.index == bit32.band(value, 0xFF)) then
            self.opcode = opcode_information
        end
    end

    if (self.opcode.has_aux) then self.aux = binary_reader:read_u32() end

    return self
end

export type Class = typeof(instruction.new(nil :: never))

return instruction