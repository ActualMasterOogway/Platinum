local luau_spec = require("../../luau/spec")

local closure_constant = {}
closure_constant.__constant_type = luau_spec.LuauBytecodeConstants.LBC_CONSTANT_CLOSURE
closure_constant.__index = closure_constant

function closure_constant.new(value: number)
    return setmetatable({ value = value }, closure_constant)
end

function closure_constant:__tostring()
    return `closure({self.value})`
end

export type Class = typeof(closure_constant.new(nil :: never))

return closure_constant