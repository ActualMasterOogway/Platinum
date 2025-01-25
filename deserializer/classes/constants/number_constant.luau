local luau_spec = require("../../luau/spec")

local number_constant = {}
number_constant.__constant_type = luau_spec.LuauBytecodeConstants.LBC_CONSTANT_NUMBER
number_constant.__index = number_constant

function number_constant.new(value: number)
    return setmetatable({ value = value }, number_constant)
end

function number_constant:__tostring()
    return tostring(self.value)
end

export type Class = typeof(number_constant.new(nil :: never))

return number_constant