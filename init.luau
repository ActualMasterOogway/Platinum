local luau = require("@lune/luau")
local serde = require("@lune/serde")
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local deserializer = require("deserializer")

local luau_spec = require("deserializer/luau/spec")

local function_class = require("deserializer/classes/func")
local instruction_class = require("deserializer/classes/instruction")

local disassembler_options = serde.decode("toml", fs.readFile("config.toml"))

local bytecode_string: string = luau.compile(fs.readFile("examples/print2.luau"), { optimizationLevel = 1, debugLevel = 1 })
local bytecode_buffer: buffer = buffer.fromstring(bytecode_string)

local bytecode_deserializer = deserializer.new(bytecode_buffer)

local function write_color(str: string, color: "black" | "blue" | "cyan" | "green" | "purple" | "red" | "reset" | "white" | "yellow")
    stdio.write(stdio.color(color))
    stdio.write(str)
    stdio.write(stdio.color("reset"))
end

local function TestXD()
    local long_tab = string.rep(" ", 8)
    local short_tab = string.rep(" ", 4)

    local main_function = bytecode_deserializer.functions[bytecode_deserializer.main_function_index]
    local is_native_module = bit32.band(main_function.function_header.flags, luau_spec.LuauProtoFlag.LPF_NATIVE_MODULE) == luau_spec.LuauProtoFlag.LPF_NATIVE_MODULE
    if (is_native_module) then
        write_color("--!native\n\n", "white")
    end

    for func_index: number, func: function_class.Class in bytecode_deserializer.functions do

        local is_main_function: boolean = func == main_function
        local generic_function_label: string = if (func.debug_name) then func.debug_name else `anonymous{func_index}`
        local function_label = if (is_main_function) then "main" else generic_function_label

        local function_args = {}
        for arg_index: number = 1, func.function_header.num_params do
            table.insert(function_args, `arg{arg_index}`)
        end
        
        if (func.function_header.is_vararg) then table.insert(function_args, "...") end

        local is_natively_compiled = bit32.band(func.function_header.flags, luau_spec.LuauProtoFlag.LPF_NATIVE_FUNCTION) == luau_spec.LuauProtoFlag.LPF_NATIVE_FUNCTION
        if (is_natively_compiled) then
            write_color(`@native\n`, "red")
        end

        write_color("function ", "purple")
        write_color(function_label, "reset")
        write_color("(", "white")
        write_color(table.concat(function_args, ", "), "reset")
        write_color(")", "white")

        if (func.debug_line_defined) then
            write_color(`{short_tab}@ line {func.debug_line_defined}`, "red")
        end

        local is_native_cold = bit32.band(func.function_header.flags, luau_spec.LuauProtoFlag.LPF_NATIVE_COLD) == luau_spec.LuauProtoFlag.LPF_NATIVE_COLD
        if (is_native_cold) then
            write_color(`{short_tab}(Not profitable to compile natively)`, "red")
        end

        stdio.write("\n")

        local registers_align: number = 0
        for _, instruction: instruction_class.Class in func.instructions_table.instructions do
            local opcode_name_length: number = #instruction.opcode_information.name
            if (opcode_name_length > registers_align) then registers_align = opcode_name_length end
        end

        local extra_align: number = 0
        for _, instruction: instruction_class.Class in func.instructions_table.instructions do
            local registers_string: string = `A: {instruction.registers.A}, B: {instruction.registers.B}, C: {instruction.registers.C}, D: {instruction.registers.D}, E: {instruction.registers.E}`
            if (#registers_string > extra_align) then extra_align = #registers_string end
        end

        for instruction_index: number, instruction: instruction_class.Class in func.instructions_table.instructions do
            local opcode_name_length: number = #instruction.opcode_information.name

            local registers_string: string = `A: {instruction.registers.A}, B: {instruction.registers.B}, C: {instruction.registers.C}, D: {instruction.registers.D}, E: {instruction.registers.E}`
            
            write_color(`{long_tab}{instruction_index}`, "blue")
            write_color(`{short_tab}{instruction.opcode_information.name}`, "yellow")
            write_color(`{string.rep(" ", registers_align - opcode_name_length)}{short_tab}{registers_string}`, "reset")
            if (instruction.line) then
                write_color(`{short_tab}{string.rep(" ", extra_align - #registers_string)}@ line {instruction.line}`, "red")
            end
            if (instruction.opcode_information.has_aux) then
                write_color(`{long_tab}AUX: `, "reset")
                write_color(`0x{string.format("%X", instruction.aux)}`, "blue")
            end

            stdio.write("\n")
        end

        stdio.write("\n")
    end
end

TestXD()