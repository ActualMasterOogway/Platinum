local luau_spec = require("../../luau/spec")

local table_constant = {}
table_constant.__constant_type = luau_spec.LuauBytecodeConstants.LBC_CONSTANT_TABLE
table_constant.__index = table_constant

function table_constant.new(value: { any })
    return setmetatable({ value = value }, table_constant)
end

function table_constant:__tostring()
    return `\{ {table.concat(self.value, ", ")} \}`
end

export type Class = typeof(table_constant.new(nil :: never))

return table_constant