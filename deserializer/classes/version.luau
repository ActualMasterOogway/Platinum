local binary_reader_class = require("../utilities/binary_reader")
local luau_spec = require("../luau/spec")

local version = {}
version.__index = version

function version.new(binary_reader: binary_reader_class.Class)
    local self = setmetatable({}, version)

    self.bytecode_version = binary_reader:read_u8()
    if (self.bytecode_version < luau_spec.LuauBytecodeTag.LBC_VERSION_MIN or self.bytecode_version > luau_spec.LuauBytecodeTag.LBC_VERSION_MAX) then
        error(`Bytecode version mismatch (expected [{luau_spec.LuauBytecodeTag.LBC_VERSION_MIN}..{luau_spec.LuauBytecodeTag.LBC_VERSION_MAX}], got {self.bytecode_version})`)
    end

    if (self.bytecode_version >= 4) then
        self.types_version = binary_reader:read_u8()
        if (self.types_version < luau_spec.LuauBytecodeTag.LBC_TYPE_VERSION_MIN or self.types_version > luau_spec.LuauBytecodeTag.LBC_TYPE_VERSION_MAX) then
            error(`Bytecode type version mismatch (expected [{luau_spec.LuauBytecodeTag.LBC_TYPE_VERSION_MIN}..{luau_spec.LuauBytecodeTag.LBC_TYPE_VERSION_MAX}], got {self.types_version})`)
        end
    end

    return self
end

export type Class = typeof(version.new(nil :: never))

return version