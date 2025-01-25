local luau = require("@lune/luau")
local serde = require("@lune/serde")
local fs = require("@lune/fs")

local deserializer = require("deserializer")

local disassembler_options = serde.decode("toml", fs.readFile("config.toml"))

local bytecode_string: string = luau.compile(fs.readFile("examples/print.luau"), { optimizationLevel = 1, debugLevel = 1 })
local bytecode_buffer: buffer = buffer.fromstring(bytecode_string)

local bytecode_deserializer = deserializer.new(bytecode_buffer)
print(bytecode_deserializer.functions[1])