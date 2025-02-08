local binary_reader = {}
binary_reader.__index = binary_reader

function binary_reader.new(source: buffer)
    if (buffer.len(source) <= 0) then
        error("Invalid buffer length")
    end

    return setmetatable({ offset = 0, source = source }, binary_reader)
end

function binary_reader:read_u8(): number
    local u8: number = buffer.readu8(self.source, self.offset)
    self.offset += 1
    return u8
end

function binary_reader:read_var_int(): number
    -- https://github.com/luau-lang/luau/blob/c13b5b7440a65987ee9dd592ee468d421d83f223/VM/src/lvmload.cpp#L120
    
    local result: number = 0
    local shift: number = 0

    repeat
        local byte: number = self:read_u8()
        result = bit32.bor(result, bit32.lshift(bit32.band(byte, 127), shift))
        shift += 7
    until bit32.band(byte, 128) == 0

    return result
end

function binary_reader:read_string(length: number?): string
    if (not length) then length = self:read_var_int() end
    local str: string = buffer.readstring(self.source, self.offset, length :: number)
    self.offset += length
    return str
end

function binary_reader:read_u32(): number
    local u32: number = buffer.readu32(self.source, self.offset)
    self.offset += 4
    return u32
end

function binary_reader:read_i32(): number
    local i32: number = buffer.readi32(self.source, self.offset)
    self.offset += 4
    return i32
end

function binary_reader:read_f64(): number
    local f64: number = buffer.readf64(self.source, self.offset)
    self.offset += 8
    return f64
end

export type Class = typeof(binary_reader.new(nil :: never))

return binary_reader