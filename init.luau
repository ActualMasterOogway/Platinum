local luau = require("@lune/luau")
local serde = require("@lune/serde")
local fs = require("@lune/fs")

local deserializer = require("deserializer")

local function_class = require("deserializer/classes/func")
local instruction_class = require("deserializer/classes/instruction")

local disassembler_options = serde.decode("toml", fs.readFile("config.toml"))

local bytecode_string: string = luau.compile(fs.readFile("examples/print2.luau"), { optimizationLevel = 1, debugLevel = 1 })
local bytecode_buffer: buffer = buffer.fromstring(bytecode_string)

local bytecode_deserializer = deserializer.new(bytecode_buffer)

local function TestXD()
    for func_index: number, func: function_class.Class in bytecode_deserializer.functions do
        local is_main_function: boolean = func_index == bytecode_deserializer.main_function_index
        local generic_function_label: string = if (func.debug_name) then func.debug_name else `func{func_index}`
        local function_label = if (is_main_function) then "main" else generic_function_label

        local function_args = {}
        for arg_index: number = 1, func.function_header.num_params do
            table.insert(function_args, `arg{arg_index}`)
        end
        
        if (func.function_header.is_vararg) then table.insert(function_args, "...") end

        print(`function {function_label}({table.concat(function_args, ", ")})`)

        local registers_align: number = 0
        for _, instruction: instruction_class.Class in func.instructions_table.instructions do
            local opcode_name_length: number = #instruction.opcode_information.name
            if (opcode_name_length > registers_align) then registers_align = opcode_name_length end
        end

        for instruction_index: number, instruction: instruction_class.Class in func.instructions_table.instructions do
            local opcode_name_length: number = #instruction.opcode_information.name

            local registers_string: string = `A: {instruction.registers.A}, B: {instruction.registers.B}, C: {instruction.registers.C}, D: {instruction.registers.D}, E: {instruction.registers.E}`
            local aux_string: string = if (instruction.opcode_information.has_aux) then ` | AUX: 0x{string.format("%x", instruction.aux)}` else ""
            local line_string: string = if (instruction.line) then ` | LINE: {instruction.line}` else ""
            local instruction_string: string = `{instruction.opcode_information.name} {string.rep(" ", registers_align - opcode_name_length)}{registers_string}{line_string}{aux_string}`
            print(`\t[{instruction_index}] {instruction_string}`)
        end
        print("")
    end
end

TestXD()