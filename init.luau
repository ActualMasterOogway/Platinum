local luau = require("@lune/luau")
local serde = require("@lune/serde")
local fs = require("@lune/fs")

local deserializer = require("deserializer")

local function_class = require("deserializer/classes/func")

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

        for instruction_index, instruction in func.instructions_table.instructions do
            print(`\t[{instruction_index}] {instruction.opcode.name}{if (instruction.opcode.has_aux) then ` AUX: 0x{string.format("%x", instruction.aux)}` else ""}`)
        end
        print("")
    end
end

TestXD()