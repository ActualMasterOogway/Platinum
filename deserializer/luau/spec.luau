local LuauBytecodeTag = {
    LBC_VERSION_MIN = 3,
    LBC_VERSION_MAX = 6,

    LBC_TYPE_VERSION_MIN = 1,
    LBC_TYPE_VERSION_MAX = 3,
}

local LuauBytecodeConstants = {
    LBC_CONSTANT_NIL = 0,
    LBC_CONSTANT_BOOLEAN = 1,
    LBC_CONSTANT_NUMBER = 2,
    LBC_CONSTANT_STRING = 3,
    LBC_CONSTANT_IMPORT = 4,
    LBC_CONSTANT_TABLE = 5,
    LBC_CONSTANT_CLOSURE = 6,
    LBC_CONSTANT_VECTOR = 7,
}

return {
    LuauBytecodeTag = table.freeze(LuauBytecodeTag),
    LuauBytecodeConstants = table.freeze(LuauBytecodeConstants)
}