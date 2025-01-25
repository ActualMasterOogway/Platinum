local luau_spec = require("../../luau/spec")

local string_constant = {}
string_constant.__constant_type = luau_spec.LuauBytecodeConstants.LBC_CONSTANT_STRING
string_constant.__index = string_constant

function string_constant.new(value: string)
    return setmetatable({ value = value }, string_constant)
end

function string_constant:__tostring()
    return `"{self.value}"`
end

export type Class = typeof(string_constant.new(nil :: never))

return string_constant