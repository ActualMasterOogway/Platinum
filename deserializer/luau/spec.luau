local LuauOpcode = {
    -- NOP: noop
    LOP_NOP = { index = 0, name = "NOP", has_aux = false },

    -- BREAK: debugger break
    LOP_BREAK = { index = 1, name = "BREAK", has_aux = false },

    -- LOADNIL: sets register to nil
    -- A: target register
    LOP_LOADNIL = { index = 2, name = "LOADNIL", has_aux = false },

    -- LOADB: sets register to boolean and jumps to a given short offset (used to compile comparison results into a boolean)
    -- A: target register
    -- B: value (0/1)
    -- C: jump offset
    LOP_LOADB = { index = 3, name = "LOADB", has_aux = false },

    -- LOADN: sets register to a number literal
    -- A: target register
    -- D: value (-32768..32767)
    LOP_LOADN = { index = 4, name = "LOADN", has_aux = false },

    -- LOADK: sets register to an entry from the constant table from the proto (number/vector/string)
    -- A: target register
    -- D: constant table index (0..32767)
    LOP_LOADK = { index = 5, name = "LOADK", has_aux = false },

    -- MOVE: move (copy) value from one register to another
    -- A: target register
    -- B: source register
    LOP_MOVE = { index = 6, name = "MOVE", has_aux = false },

    -- GETGLOBAL: load value from global table using constant string as a key
    -- A: target register
    -- C: predicted slot index (based on hash)
    -- AUX: constant table index
    LOP_GETGLOBAL = { index = 7, name = "GETGLOBAL", has_aux = true },

    -- SETGLOBAL: set value in global table using constant string as a key
    -- A: source register
    -- C: predicted slot index (based on hash)
    -- AUX: constant table index
    LOP_SETGLOBAL = { index = 8, name = "SETGLOBAL", has_aux = true },

    -- GETUPVAL: load upvalue from the upvalue table for the current function
    -- A: target register
    -- B: upvalue index
    LOP_GETUPVAL = { index = 9, name = "GETUPVAL", has_aux = false },

    -- SETUPVAL: store value into the upvalue table for the current function
    -- A: target register
    -- B: upvalue index
    LOP_SETUPVAL = { index = 10, name = "SETUPVAL", has_aux = false },

    -- CLOSEUPVALS: close (migrate to heap) all upvalues that were captured for registers >= target
    -- A: target register
    LOP_CLOSEUPVALS = { index = 11, name = "CLOSEUPVALS", has_aux = false },

    -- GETIMPORT: load imported global table global from the constant table
    -- A: target register
    -- D: constant table index (0..32767); we assume that imports are loaded into the constant table
    -- AUX: 3 10-bit indices of constant strings that, combined, constitute an import path; length of the path is set by the top 2 bits (1,2,3)
    LOP_GETIMPORT = { index = 12, name = "GETIMPORT", has_aux = true },

    -- GETTABLE: load value from table into target register using key from register
    -- A: target register
    -- B: table register
    -- C: index register
    LOP_GETTABLE = { index = 13, name = "GETTABLE", has_aux = false },

    -- SETTABLE: store source register into table using key from register
    -- A: source register
    -- B: table register
    -- C: index register
    LOP_SETTABLE = { index = 14, name = "SETTABLE", has_aux = false },

    -- GETTABLEKS: load value from table into target register using constant string as a key
    -- A: target register
    -- B: table register
    -- C: predicted slot index (based on hash)
    -- AUX: constant table index
    LOP_GETTABLEKS = { index = 15, name = "GETTABLEKS", has_aux = true },

    -- SETTABLEKS: store source register into table using constant string as a key
    -- A: source register
    -- B: table register
    -- C: predicted slot index (based on hash)
    -- AUX: constant table index
    LOP_SETTABLEKS = { index = 16, name = "SETTABLEKS", has_aux = true },

    -- GETTABLEN: load value from table into target register using small integer index as a key
    -- A: target register
    -- B: table register
    -- C: index-1 (index is 1..256)
    LOP_GETTABLEN = { index = 17, name = "GETTABLEN", has_aux = false },

    -- SETTABLEN: store source register into table using small integer index as a key
    -- A: source register
    -- B: table register
    -- C: index-1 (index is 1..256)
    LOP_SETTABLEN = { index = 18, name = "SETTABLEN", has_aux = false },

    -- NEWCLOSURE: create closure from a child proto; followed by a CAPTURE instruction for each upvalue
    -- A: target register
    -- D: child proto index (0..32767)
    LOP_NEWCLOSURE = { index = 19, name = "NEWCLOSURE", has_aux = false },

    -- NAMECALL: prepare to call specified method by name by loading function from source register using constant index into target register and copying source register into target register + 1
    -- A: target register
    -- B: source register
    -- C: predicted slot index (based on hash)
    -- AUX: constant table index
    -- Note that this instruction must be followed directly by CALL; it prepares the arguments
    -- This instruction is roughly equivalent to GETTABLEKS + MOVE pair, but we need a special instruction to support custom __namecall metamethod
    LOP_NAMECALL = { index = 20, name = "NAMECALL", has_aux = true },

    -- CALL: call specified function
    -- A: register where the function object lives, followed by arguments; results are placed starting from the same register
    -- B: argument count + 1, or 0 to preserve all arguments up to top (MULTRET)
    -- C: result count + 1, or 0 to preserve all values and adjust top (MULTRET)
    LOP_CALL = { index = 21, name = "CALL", has_aux = false },

    -- RETURN: returns specified values from the function
    -- A: register where the returned values start
    -- B: number of returned values + 1, or 0 to return all values up to top (MULTRET)
    LOP_RETURN = { index = 22, name = "RETURN", has_aux = false },

    -- JUMP: jumps to target offset
    -- D: jump offset (-32768..32767; 0 means "next instruction" aka "don't jump")
    LOP_JUMP = { index = 23, name = "JUMP", has_aux = false },

    -- JUMPBACK: jumps to target offset; this is equivalent to JUMP but is used as a safepoint to be able to interrupt while/repeat loops
    -- D: jump offset (-32768..32767; 0 means "next instruction" aka "don't jump")
    LOP_JUMPBACK = { index = 24, name = "JUMPBACK", has_aux = false },

    -- JUMPIF: jumps to target offset if register is not nil/false
    -- A: source register
    -- D: jump offset (-32768..32767; 0 means "next instruction" aka "don't jump")
    LOP_JUMPIF = { index = 25, name = "JUMPIF", has_aux = false },

    -- JUMPIFNOT: jumps to target offset if register is nil/false
    -- A: source register
    -- D: jump offset (-32768..32767; 0 means "next instruction" aka "don't jump")
    LOP_JUMPIFNOT = { index = 26, name = "JUMPIFNOT", has_aux = false },

    -- JUMPIFEQ, JUMPIFLE, JUMPIFLT, JUMPIFNOTEQ, JUMPIFNOTLE, JUMPIFNOTLT: jumps to target offset if the comparison is true (or false, for NOT variants)
    -- A: source register 1
    -- D: jump offset (-32768..32767; 1 means "next instruction" aka "don't jump")
    -- AUX: source register 2
    LOP_JUMPIFEQ = { index = 27, name = "JUMPIFEQ", has_aux = true },
    LOP_JUMPIFLE = { index = 28, name = "JUMPIFLE", has_aux = true },
    LOP_JUMPIFLT = { index = 29, name = "JUMPIFLT", has_aux = true },
    LOP_JUMPIFNOTEQ = { index = 30, name = "JUMPIFNOTEQ", has_aux = true },
    LOP_JUMPIFNOTLE = { index = 31, name = "JUMPIFNOTLE", has_aux = true },
    LOP_JUMPIFNOTLT = { index = 32, name = "JUMPIFNOTLT", has_aux = true },

    -- ADD, SUB, MUL, DIV, MOD, POW: compute arithmetic operation between two source registers and put the result into target register
    -- A: target register
    -- B: source register 1
    -- C: source register 2
    LOP_ADD = { index = 33, name = "ADD", has_aux = false },
    LOP_SUB = { index = 34, name = "SUB", has_aux = false },
    LOP_MUL = { index = 35, name = "MUL", has_aux = false },
    LOP_DIV = { index = 36, name = "DIV", has_aux = false },
    LOP_MOD = { index = 37, name = "MOD", has_aux = false },
    LOP_POW = { index = 38, name = "POW", has_aux = false },

    -- ADDK, SUBK, MULK, DIVK, MODK, POWK: compute arithmetic operation between the source register and a constant and put the result into target register
    -- A: target register
    -- B: source register
    -- C: constant table index (0..255); must refer to a number
    LOP_ADDK = { index = 39, name = "ADDK", has_aux = false },
    LOP_SUBK = { index = 40, name = "SUBK", has_aux = false },
    LOP_MULK = { index = 41, name = "MULK", has_aux = false },
    LOP_DIVK = { index = 42, name = "DIVK", has_aux = false },
    LOP_MODK = { index = 43, name = "MODK", has_aux = false },
    LOP_POWK = { index = 44, name = "POWK", has_aux = false },

    -- AND, OR: perform `and` or `or` operation (selecting first or second register based on whether the first one is truthy) and put the result into target register
    -- A: target register
    -- B: source register 1
    -- C: source register 2
    LOP_AND = { index = 45, name = "AND", has_aux = false },
    LOP_OR = { index = 46, name = "OR", has_aux = false },

    -- ANDK, ORK: perform `and` or `or` operation (selecting source register or constant based on whether the source register is truthy) and put the result into target register
    -- A: target register
    -- B: source register
    -- C: constant table index (0..255)
    LOP_ANDK = { index = 47, name = "ANDK", has_aux = false },
    LOP_ORK = { index = 48, name = "ORK", has_aux = false },

    -- CONCAT: concatenate all strings between B and C (inclusive) and put the result into A
    -- A: target register
    -- B: source register start
    -- C: source register end
    LOP_CONCAT = { index = 49, name = "CONCAT", has_aux = false },

    -- NOT, MINUS, LENGTH: compute unary operation for source register and put the result into target register
    -- A: target register
    -- B: source register
    LOP_NOT = { index = 50, name = "NOT", has_aux = false },
    LOP_MINUS = { index = 51, name = "MINUS", has_aux = false },
    LOP_LENGTH = { index = 52, name = "LENGTH", has_aux = false },

    -- NEWTABLE: create table in target register
    -- A: target register
    -- B: table size, stored as 0 for v=0 and ceil(log2(v))+1 for v!=0
    -- AUX: array size
    LOP_NEWTABLE = { index = 53, name = "NEWTABLE", has_aux = true },

    -- DUPTABLE: duplicate table using the constant table template to target register
    -- A: target register
    -- D: constant table index (0..32767)
    LOP_DUPTABLE = { index = 54, name = "DUPTABLE", has_aux = false },

    -- SETLIST: set a list of values to table in target register
    -- A: target register
    -- B: source register start
    -- C: value count + 1, or 0 to use all values up to top (MULTRET)
    -- AUX: table index to start from
    LOP_SETLIST = { index = 55, name = "SETLIST", has_aux = true },

    -- FORNPREP: prepare a numeric for loop, jump over the loop if first iteration doesn't need to run
    -- A: target register; numeric for loops assume a register layout [limit, step, index, variable]
    -- D: jump offset (-32768..32767)
    -- limit/step are immutable, index isn't visible to user code since it's copied into variable
    LOP_FORNPREP = { index = 56, name = "FORNPREP", has_aux = false },

    -- FORNLOOP: adjust loop variables for one iteration, jump back to the loop header if loop needs to continue
    -- A: target register; see FORNPREP for register layout
    -- D: jump offset (-32768..32767)
    LOP_FORNLOOP = { index = 57, name = "FORNLOOP", has_aux = false },

    -- FORGLOOP: adjust loop variables for one iteration of a generic for loop, jump back to the loop header if loop needs to continue
    -- A: target register; generic for loops assume a register layout [generator, state, index, variables...]
    -- D: jump offset (-32768..32767)
    -- AUX: variable count (1..255) in the low 8 bits, high bit indicates whether to use ipairs-style traversal in the fast path
    -- loop variables are adjusted by calling generator(state, index) and expecting it to return a tuple that's copied to the user variables
    -- the first variable is then copied into index; generator/state are immutable, index isn't visible to user code
    LOP_FORGLOOP = { index = 58, name = "FORGLOOP", has_aux = true },

    -- FORGPREP_INEXT: prepare FORGLOOP with 2 output variables (no AUX encoding), assuming generator is luaB_inext, and jump to FORGLOOP
    -- A: target register (see FORGLOOP for register layout)
    LOP_FORGPREP_INEXT = { index = 59, name = "FORGPREP_INEXT", has_aux = false },

    -- FASTCALL3: perform a fast call of a built-in function using 3 register arguments
    -- A: builtin function id (see LuauBuiltinFunction)
    -- B: source argument register
    -- C: jump offset to get to following CALL
    -- AUX: source register 2 in least-significant byte
    -- AUX: source register 3 in second least-significant byte
    LOP_FASTCALL3 = { index = 60, name = "FASTCALL3", has_aux = true },

    -- FORGPREP_NEXT: prepare FORGLOOP with 2 output variables (no AUX encoding), assuming generator is luaB_next, and jump to FORGLOOP
    -- A: target register (see FORGLOOP for register layout)
    LOP_FORGPREP_NEXT = { index = 61, name = "FORGPREP_NEXT", has_aux = false },

    -- NATIVECALL: start executing new function in native code
    -- this is a pseudo-instruction that is never emitted by bytecode compiler, but can be constructed at runtime to accelerate native code dispatch
    LOP_NATIVECALL = { index = 62, name = "NATIVECALL", has_aux = false },

    -- GETVARARGS: copy variables into the target register from vararg storage for current function
    -- A: target register
    -- B: variable count + 1, or 0 to copy all variables and adjust top (MULTRET)
    LOP_GETVARARGS = { index = 63, name = "GETVARARGS", has_aux = false },

    -- DUPCLOSURE: create closure from a pre-created function object (reusing it unless environments diverge)
    -- A: target register
    -- D: constant table index (0..32767)
    LOP_DUPCLOSURE = { index = 64, name = "DUPCLOSURE", has_aux = false },

    -- PREPVARARGS: prepare stack for variadic functions so that GETVARARGS works correctly
    -- A: number of fixed arguments
    LOP_PREPVARARGS = { index = 65, name = "PREPVARARGS", has_aux = false },

    -- LOADKX: sets register to an entry from the constant table from the proto (number/string)
    -- A: target register
    -- AUX: constant table index
    LOP_LOADKX = { index = 66, name = "LOADKX", has_aux = true },

    -- JUMPX: jumps to the target offset; like JUMPBACK, supports interruption
    -- E: jump offset (-2^23..2^23; 0 means "next instruction" aka "don't jump")
    LOP_JUMPX = { index = 67, name = "JUMPX", has_aux = false },

    -- FASTCALL: perform a fast call of a built-in function
    -- A: builtin function id (see LuauBuiltinFunction)
    -- C: jump offset to get to following CALL
    -- FASTCALL is followed by one of (GETIMPORT, MOVE, GETUPVAL) instructions and by CALL instruction
    -- This is necessary so that if FASTCALL can't perform the call inline, it can continue normal execution
    -- If FASTCALL *can* perform the call, it jumps over the instructions *and* over the next CALL
    -- Note that FASTCALL will read the actual call arguments, such as argument/result registers and counts, from the CALL instruction
    LOP_FASTCALL = { index = 68, name = "FASTCALL", has_aux = false },

    -- COVERAGE: update coverage information stored in the instruction
    -- E: hit count for the instruction (0..2^23-1)
    -- The hit count is incremented by VM every time the instruction is executed, and saturates at 2^23-1
    LOP_COVERAGE = { index = 69, name = "COVERAGE", has_aux = false },

    -- CAPTURE: capture a local or an upvalue as an upvalue into a newly created closure; only valid after NEWCLOSURE
    -- A: capture type, see LuauCaptureType
    -- B: source register (for VAL/REF) or upvalue index (for UPVAL/UPREF)
    LOP_CAPTURE = { index = 70, name = "CAPTURE", has_aux = false },

    -- SUBRK, DIVRK: compute arithmetic operation between the constant and a source register and put the result into target register
    -- A: target register
    -- B: constant table index (0..255); must refer to a number
    -- C: source register
    LOP_SUBRK = { index = 71, name = "SUBRK", has_aux = false },
    LOP_DIVRK = { index = 72, name = "DIVRK", has_aux = false },

    -- FASTCALL1: perform a fast call of a built-in function using 1 register argument
    -- A: builtin function id (see LuauBuiltinFunction)
    -- B: source argument register
    -- C: jump offset to get to following CALL
    LOP_FASTCALL1 = { index = 73, name = "FASTCALL1", has_aux = false },

    -- FASTCALL2: perform a fast call of a built-in function using 2 register arguments
    -- A: builtin function id (see LuauBuiltinFunction)
    -- B: source argument register
    -- C: jump offset to get to following CALL
    -- AUX: source register 2 in least-significant byte
    LOP_FASTCALL2 = { index = 74, name = "FASTCALL2", has_aux = true },

    -- FASTCALL2K: perform a fast call of a built-in function using 1 register argument and 1 constant argument
    -- A: builtin function id (see LuauBuiltinFunction)
    -- B: source argument register
    -- C: jump offset to get to following CALL
    -- AUX: constant index
    LOP_FASTCALL2K = { index = 75, name = "FASTCALL2K", has_aux = true },

    -- FORGPREP: prepare loop variables for a generic for loop, jump to the loop backedge unconditionally
    -- A: target register; generic for loops assume a register layout [generator, state, index, variables...]
    -- D: jump offset (-32768..32767)
    LOP_FORGPREP = { index = 76, name = "FORGPREP", has_aux = false },

    -- JUMPXEQKNIL, JUMPXEQKB: jumps to target offset if the comparison with constant is true (or false, see AUX)
    -- A: source register 1
    -- D: jump offset (-32768..32767; 1 means "next instruction" aka "don't jump")
    -- AUX: constant value (for boolean) in low bit, NOT flag (that flips comparison result) in high bit
    LOP_JUMPXEQKNIL = { index = 77, name = "JUMPXEQKNIL", has_aux = true },
    LOP_JUMPXEQKB = { index = 78, name = "JUMPXEQKB", has_aux = true },

    -- JUMPXEQKN, JUMPXEQKS: jumps to target offset if the comparison with constant is true (or false, see AUX)
    -- A: source register 1
    -- D: jump offset (-32768..32767; 1 means "next instruction" aka "don't jump")
    -- AUX: constant table index in low 24 bits, NOT flag (that flips comparison result) in high bit
    LOP_JUMPXEQKN = { index = 79, name = "JUMPXEQKN", has_aux = true },
    LOP_JUMPXEQKS = { index = 80, name = "JUMPXEQKS", has_aux = true },

    -- IDIV: compute floor division between two source registers and put the result into target register
    -- A: target register
    -- B: source register 1
    -- C: source register 2
    LOP_IDIV = { index = 81, name = "IDIV", has_aux = false },

    -- IDIVK compute floor division between the source register and a constant and put the result into target register
    -- A: target register
    -- B: source register
    -- C: constant table index (0..255)
    LOP_IDIVK = { index = 82, name = "IDIVK", has_aux = false },

    -- Enum entry for number of opcodes, not a valid opcode by itself!
    LOP__COUNT = { index = 83, name = "_COUNT", has_aux = false },
}

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

local LuauProtoFlag = {
    -- used to tag main proto for modules with --!native
    LPF_NATIVE_MODULE = bit32.lshift(1, 0),
    -- used to tag individual protos as not profitable to compile natively
    LPF_NATIVE_COLD = bit32.lshift(1, 1),
    -- used to tag main proto for modules that have at least one function with native attribute
    LPF_NATIVE_FUNCTION = bit32.lshift(1, 2),
};

return {
    LuauBytecodeTag = table.freeze(LuauBytecodeTag),
    LuauBytecodeConstants = table.freeze(LuauBytecodeConstants),
    LuauOpcode = table.freeze(LuauOpcode),
    LuauProtoFlag = table.freeze(LuauProtoFlag)
}