# Bitazard

Bitazard is a pure Lua bit manipulation library.

Bitazard is up-to-date in 2025.

# Rationale

Lua, as a language, has problems with bit manipulation:

- Lua 5.1 does not support bitwise operations.
- Lua 5.2 supports bitwise operations in the form of the bit32 module, which operates on 32 bit unsigned integer numbers.
- Lua 5.3 introduces compatibility breaking bitwise operators, but does have bit32 as a fallback option.
- Lua 5.4 removes the bit32 fallback
- LuaJIT supports bitwise operations in the form of the bit extension module, which operates on 32 bit *signed* integer numbers, and can operate on 64 bit integer cdata numbers through LuaJIT's FFI interface.

It can be useful to think about binary data without having to worry about the underlying number implementation or version compatability. To that end, Bitazard exists as an option.

Keep in mind, however, that Bitazard is inefficient compared to Pure C bitwise functions, and will be slower than the native Lua bitwise functions which are available with the different versions of the Lua language. Its purpose therefore is more for glue code in cases where there is no appetite or ability to implement the language-version specific operations, such as in a library targetting multiple versions of Lua.

# Data Representation

Bitazard encodes binary data in the form of 8-bit bytes as lists. The lists contain 8 boolean values from positions 1 through 8, with position 1 being the most significant bit, and position 8 being the least significant bit. A 0 in the list represents 0. A 1 in the list represents 1. Any other value in a list will result in undefined behaviour. Any other length of a list will result in undefined behaviour.

Bitazard expects the programmer to call its API with valid data, and provides API helpers to create data that is valid. If the data is being sourced from somewhere outside the programmer's control, there are validations that will verify whether or not the data conforms to Bitazard's expected inputs.

This makes it very easy to hand-write bytes when you need to: `{0, 1, 1, 1,  1, 1, 1, 1} --127`

# Usage

TBD

# TODO

- Finish this readme and add a license.
- Add Logical and Rotation Shifts
- Add a package.toml