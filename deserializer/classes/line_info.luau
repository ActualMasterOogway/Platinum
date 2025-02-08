local binary_reader_class = require("../utilities/binary_reader")
local instruction_class = require("../classes/instruction")

export type FunctionInstructionsTable = {
    instructions_size: number,
    instructions: { instruction_class.Class }
}

local line_info = {}
line_info.__index = line_info

function line_info.new(binary_reader: binary_reader_class.Class, instructions_table: FunctionInstructionsTable)
    local self = setmetatable({}, line_info)
    
    self.log_span = binary_reader:read_u8()
    self.line_deltas = {}
    self.line_baselines = {}

    for i = 1, instructions_table.instructions_size do
        local delta = if (self.line_deltas[i - 1]) then 
            self.line_deltas[i - 1] + binary_reader:read_u8() 
        else 
            binary_reader:read_u8()

        self.line_deltas[i] = delta
    end

    local baseline_count = bit32.rshift(instructions_table.instructions_size - 1, self.log_span) + 1
    for i = 1, baseline_count do
        local baseline = if (self.line_baselines[i - 1]) then 
            self.line_baselines[i - 1] + binary_reader:read_i32() 
        else 
            binary_reader:read_i32()

        self.line_baselines[i] = baseline
    end

    return self
end

function line_info:get_line(instruction_index: number): number
    local chunk = bit32.rshift(instruction_index - 1, self.log_span) + 1

    local baseline = self.line_baselines[chunk]
    local delta = self.line_deltas[instruction_index]
    
    return baseline + delta
end

export type Class = typeof(line_info.new(nil :: never))

return line_info