local binary_reader_class = require("../utilities/binary_reader")
local instruction_class = require("../classes/instruction")

local line_info = {}
line_info.__index = line_info

function line_info.new(binary_reader: binary_reader_class.Class, instructions_size: {
        instructions_size: number,
        instructions: { instruction_class.Class } -- TODO: Convert into class
    })
    local self = setmetatable({}, line_info)
    
    self.log_span = binary_reader:read_u8()
    self.line_deltas = {}
    self.line_baselines = {}

    for i = 1, instructions_size.instructions_size do
        self.line_deltas[i - 1] = binary_reader:read_u8()
    end

    local baseline_count = bit32.rshift(instructions_size.instructions_size - 1, self.log_span) + 1
    for i = 1, baseline_count do
        self.line_baselines[i - 1] = binary_reader:read_u32()
    end

    return self
end

function line_info:get_line(instruction_index: number): number
    local index = instruction_index - 1
    local chunk = bit32.rshift(index, self.log_span)

    local baseline = self.line_baselines[chunk]
    local delta = self.line_deltas[index]
    
    return baseline + delta
end

export type Class = typeof(line_info.new(nil :: never))

return line_info