# Platinum


## Usage
```luau
local deserializer = require("deserializer")

local bytecode_buffer: buffer = buffer.fromstring(...)

local bytecode_deserializer = deserializer.new(bytecode_buffer)
print(bytecode_deserializer)
```