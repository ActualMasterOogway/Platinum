-- https://github.com/luau-lang/luau/blob/c13b5b7440a65987ee9dd592ee468d421d83f223/Compiler/src/BytecodeBuilder.cpp#L722
export type FunctionHeader = {
    max_stack_size: number,
    num_params: number,
    num_upvalues: number,
    is_vararg: boolean,
    flags: number
}

export type FunctionInstructionsTable = {
    instructions_size: number,
    instructions: { instruction_class.Class }
}

export type ConstantType = 
    | nil_constant.Class 
    | boolean_constant.Class 
    | number_constant.Class 
    | string_constant.Class 
    | import_constant.Class 
    | table_constant.Class 
    | closure_constant.Class 
    | vector_constant.Class

export type FunctionConstantsTable = {
    constants_size: number,
    constants: { ConstantType }
}

export type FunctionChildProtosTable = {
    child_protos_size: number,
    child_protos: { number }
}

local binary_reader_class = require("../utilities/binary_reader")
local luau_spec = require("../luau/spec")

local string_table_class = require("string_table")

local nil_constant = require("constants/nil_constant")
local boolean_constant = require("constants/boolean_constant")
local number_constant = require("constants/number_constant")
local string_constant = require("constants/string_constant")
local import_constant = require("constants/import_constant")
local table_constant = require("constants/table_constant")
local closure_constant = require("constants/closure_constant")
local vector_constant = require("constants/vector_constant")

local line_info_class = require("line_info")
local debug_info_class = require("debug_info")

local instruction_class = require("instruction")

local version_class = require("version")

local func = {}
func.__index = func

function func.new(binary_reader: binary_reader_class.Class, string_table: string_table_class.Class, version: version_class.Class)
    local self = setmetatable({}, func)

    self.function_header = self:read_function_header(binary_reader)
    
    self.type_info = self:read_type_info(binary_reader, version.types_version)

    self.instructions_table = self:read_instructions(binary_reader)
    self.constants_table = self:read_constants(binary_reader, string_table)
    self.child_protos_table = self:read_child_protos(binary_reader)

    self.debug_line_defined = binary_reader:read_var_int()
    self.debug_name = string_table.strings[binary_reader:read_var_int()]

    self.line_info = self:read_line_info(binary_reader)
    self.debug_info = self:read_debug_info(binary_reader, string_table)

    if self.line_info then
        for i, instr in self.instructions_table.instructions do
            instr.line = self.line_info:get_line(i)
        end
    end

    return self
end

function func:read_function_header(binary_reader: binary_reader_class.Class): FunctionHeader
    return {
        max_stack_size = binary_reader:read_u8(),
        num_params = binary_reader:read_u8(),
        num_upvalues = binary_reader:read_u8(),
        is_vararg = binary_reader:read_u8() == 1,
        flags = binary_reader:read_u8()
    }
end

function func:read_type_info(binary_reader: binary_reader_class.Class, types_version: number): {}
    if (types_version == 1) then
        local typesize = binary_reader:read_var_int()
        if (typesize ~= 0) then
            -- Skip
            binary_reader.offset += typesize
        end
    elseif (types_version == 2 or types_version == 3) then
        local typesize = binary_reader:read_var_int()
        if (typesize ~= 0) then
            -- Skip
            binary_reader.offset += typesize
        end
    end

    return {}
end

function func:read_instructions(binary_reader: binary_reader_class.Class): FunctionInstructionsTable
    local instructions_size: number = binary_reader:read_var_int()

    local instructions: { instruction_class.Class } = table.create(instructions_size)

    local aux_skip_condition: boolean = false
    local current_aux_offset: number = 0

    for instruction_index: number = 1, instructions_size do
        -- Skip aux or else it will appear as it's own instruction, while it's being handled by the class.
        if (aux_skip_condition) then 
            aux_skip_condition = false 
            current_aux_offset += 1
            continue 
        end

        local instruction: instruction_class.Class = instruction_class.new(binary_reader, binary_reader:read_u32(), current_aux_offset)

        if (instruction.opcode_information.has_aux) then aux_skip_condition = true end
        table.insert(instructions, instruction)
    end

    return {
        instructions_size = instructions_size,
        instructions = instructions
    }
end

function func:read_constants(binary_reader: binary_reader_class.Class, string_table: string_table_class.Class): FunctionConstantsTable
    local constants_size: number = binary_reader:read_var_int()
    local constants: { ConstantType } = table.create(constants_size)

    for constant_index: number = 1, constants_size do
        local constant_type: number = binary_reader:read_u8()
        if (constant_type == luau_spec.LuauBytecodeConstants.LBC_CONSTANT_NIL) then
            constants[constant_index] = nil_constant.new()
        elseif (constant_type == luau_spec.LuauBytecodeConstants.LBC_CONSTANT_BOOLEAN) then
            constants[constant_index] = boolean_constant.new(binary_reader:read_u8() == 1)
        elseif (constant_type == luau_spec.LuauBytecodeConstants.LBC_CONSTANT_NUMBER) then
            constants[constant_index] = number_constant.new(binary_reader:read_f64())
        elseif (constant_type == luau_spec.LuauBytecodeConstants.LBC_CONSTANT_STRING) then
            constants[constant_index] = string_constant.new(string_table.strings[binary_reader:read_var_int()])
        elseif (constant_type == luau_spec.LuauBytecodeConstants.LBC_CONSTANT_IMPORT) then
            local import_id: number = binary_reader:read_u32()
            local count: number = bit32.rshift(import_id, 30)
            
            local import_constants: { any } = table.create(count)
            if (count > 0) then
                import_constants[1] = constants[bit32.band(bit32.rshift(import_id, 20), 1023) + 1]
            end
            if (count > 1) then
                import_constants[2] = constants[bit32.band(bit32.rshift(import_id, 10), 1023) + 1]
            end
            if (count > 2) then
                import_constants[3] = constants[bit32.band(import_id, 1023) + 1]
            end

            constants[constant_index] = import_constant.new(import_constants)
        elseif (constant_type == luau_spec.LuauBytecodeConstants.LBC_CONSTANT_TABLE) then
            local table_shape_length: number = binary_reader:read_var_int()
            local table_values: { any } = table.create(table_shape_length)

            for table_value_index: number = 1, table_shape_length do
                table_values[table_value_index] = constants[binary_reader:read_var_int() + 1]
            end

            constants[constant_index] = table_constant.new(table_values)
        elseif (constant_type == luau_spec.LuauBytecodeConstants.LBC_CONSTANT_CLOSURE) then
            constants[constant_index] = closure_constant.new(binary_reader:read_var_int())
        elseif (constant_type == luau_spec.LuauBytecodeConstants.LBC_CONSTANT_VECTOR) then
            local x: number, y: number, z: number, w: number = 
                binary_reader:read_f64(), binary_reader:read_f64(), binary_reader:read_f64(), binary_reader:read_f64()
            constants[constant_index] = vector_constant.new(x, y, z, w)
        else
            error(`Unsupported constant type {constant_type}`)
        end
    end

    return {
        constants_size = constants_size,
        constants = constants
    }
end

function func:read_child_protos(binary_reader: binary_reader_class.Class)
    local child_protos_size: number = binary_reader:read_var_int()
    
    local child_protos: { number } = table.create(child_protos_size)
    for child_proto_index: number = 1, child_protos_size do
        child_protos[child_proto_index] = binary_reader:read_var_int()
    end

    return child_protos
end

function func:read_line_info(binary_reader: binary_reader_class.Class): line_info_class.Class?
    local has_line_info = binary_reader:read_u8() == 1
    if (has_line_info) then
        return line_info_class.new(binary_reader, self.instructions_table)
    end
    return nil
end

function func:read_debug_info(binary_reader: binary_reader_class.Class, string_table: string_table_class.Class): debug_info_class.Class?
    local has_debug_info = binary_reader:read_u8() == 1
    if (has_debug_info) then
        return debug_info_class.new(binary_reader, string_table)
    end
    return nil
end

export type Class = typeof(func.new(nil :: never))

return func