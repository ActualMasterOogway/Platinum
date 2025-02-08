export type Registers = {
    A: number,
    B: number,
    C: number,
    D: number,
    E: number,
}

local luau_spec = require("../luau/spec")
local binary_reader_class = require("../utilities/binary_reader")

local instruction = {}
instruction.__index = instruction

local function arshift(x: number, disp: number): number
    local result = bit32.rshift(x, disp)
    return if (result >= 2 ^ 15) then result - 2 ^ 16 else result
end

function instruction.new(binary_reader: binary_reader_class.Class, value: number)
    local self = setmetatable({}, instruction)
    
    local opcode = bit32.band(value, 0xFF)
    assert(opcode > 0 and opcode < luau_spec.LuauOpcode.LOP__COUNT.index, `Invalid opcode {opcode}`)

    for _, opcode_information in luau_spec.LuauOpcode do
        if (opcode_information.index == opcode) then
            self.opcode_information = opcode_information
        end
    end

    if (self.opcode_information.has_aux) then self.aux = binary_reader:read_u32() end

    self.registers = {
        A = bit32.band(bit32.arshift(value, 8), 0xFF),
        B = bit32.band(bit32.arshift(value, 16), 0xFF),
        C = bit32.band(bit32.arshift(value, 24), 0xFF),
        D = arshift(value, 16),
        E = arshift(value, 8),
    }

    return self
end

export type Class = typeof(instruction.new(nil :: never)) & {line: number?}

return instruction