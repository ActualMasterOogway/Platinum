local luau_spec = require("../../luau/spec")

local nil_constant = {}
nil_constant.__constant_type = luau_spec.LuauBytecodeConstants.LBC_CONSTANT_NIL
nil_constant.__index = nil_constant

function nil_constant.new()
    return setmetatable({}, nil_constant)
end

function nil_constant:__tostring()
    return "nil"
end

export type Class = typeof(nil_constant.new())

return nil_constant