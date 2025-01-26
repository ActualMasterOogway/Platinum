export type DebugLocal = {
    name: string,     -- var_int (string_table)
    start_pc: number, -- var_int
    end_pc: number,   -- var_int,
    reg: number,      -- byte
}

export type DebugUpval = {
    name: string, -- var_int (string_table)
}

export type DebugLocalsTable = {
    debug_locals_size: number,
    debug_locals: { DebugLocal }
}

export type DebugUpvalsTable = {
    debug_upvals_size: number,
    debug_upvals: { DebugUpval }
}

local binary_reader_class = require("../utilities/binary_reader")
local string_table_class = require("string_table")

local debug_info = {}
debug_info.__index = debug_info

function debug_info.new(binary_reader: binary_reader_class.Class, string_table: string_table_class.Class)
    local self = setmetatable({}, debug_info)

    local debug_locals_size: number = binary_reader:read_var_int()
    
    local debug_locals: { DebugLocal } = table.create(debug_locals_size)
    for debug_local_index: number = 1, debug_locals_size do
        debug_locals[debug_local_index] = {
            name = string_table.strings[binary_reader:read_var_int()],
            start_pc = binary_reader:read_var_int(),
            end_pc = binary_reader:read_var_int(),
            reg = binary_reader:read_u8()
        }
    end

    local debug_upvals_size: number = binary_reader:read_var_int()

    local debug_upvals: { DebugUpval } = table.create(debug_upvals_size)
    for debug_upval_index: number = 1, debug_upvals_size do
        debug_upvals[debug_upval_index] = {
            name = string_table.strings[binary_reader:read_var_int()],
        }
    end

    self.debug_locals_table = {
        debug_locals_size = debug_upvals_size,
        debug_locals = debug_locals
    }

    self.debug_upvals_table = {
        debug_upvals_size = debug_upvals_size,
        debug_upvals = debug_upvals
    }

    return self
end 

export type Class = typeof(debug_info.new(nil :: never))

return debug_info