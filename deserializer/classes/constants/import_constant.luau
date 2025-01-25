local luau_spec = require("../../luau/spec")
local string_constant_class = require("string_constant")

local import_constant = {}
import_constant.__constant_type = luau_spec.LuauBytecodeConstants.LBC_CONSTANT_IMPORT
import_constant.__index = import_constant

function import_constant.new(value: { string_constant_class.Class })
    return setmetatable({ value = value }, import_constant)
end

function import_constant:__tostring()
    local result: { string } = {}

    for _, constant in self.value do
        table.insert(result, tostring(constant.value))
    end

    return table.concat(result, ".")
end

export type Class = typeof(import_constant.new(nil :: never))

return import_constant