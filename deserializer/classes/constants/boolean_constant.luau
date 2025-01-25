local luau_spec = require("../../luau/spec")

local boolean_constant = {}
boolean_constant.__constant_type = luau_spec.LuauBytecodeConstants.LBC_CONSTANT_BOOLEAN
boolean_constant.__index = boolean_constant

function boolean_constant.new(value: boolean)
    return setmetatable({ value = value }, boolean_constant)
end

function boolean_constant:__tostring()
    return tostring(self.value)
end

export type Class = typeof(boolean_constant.new(nil :: never))

return boolean_constant