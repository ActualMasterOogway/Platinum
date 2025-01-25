local luau_spec = require("../../luau/spec")

local vector_constant = {}
vector_constant.__constant_type = luau_spec.LuauBytecodeConstants.LBC_CONSTANT_VECTOR
vector_constant.__index = vector_constant

function vector_constant.new(x: number, y: number, z: number, w: number)
    return setmetatable({ x= x, y = y, z = z, w = w }, vector_constant)
end

function vector_constant:__tostring()
    return `Vector({self.x}, {self.y}, {self.z}, {self.w})`
end

export type Class = typeof(vector_constant.new(nil :: never))

return vector_constant