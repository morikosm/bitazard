# Bitazard

Bitazard is a pure Lua bit manipulation library. It is fully documented with LuaCATS annotations, compatible with [LuaLS](https://luals.github.io/). Written in an procedural/imperative style, and heavily annotated, Bitazard is easy to use, read, and extend. Bitazard is licensed under the ZLIB license.

Bitazard is up-to-date and maintained in 2025. While this software is maintained, this notice will be current with the current year.

# Installation

Bitazard is published in a modern Lua Module format. The recommended way to add Bitazard to a project is as a git submodule.

`git submodule add https://github.com/morikosm/bitazard submodules/bitazard`

Then, make sure `./submodules/?/init.lua` is in your `package.path`. You can do this by setting the LUA_PATH environment variable to `;;./submodules/?/init.lua;`, or in the script you want to use Bitazard in, do:

```lua
local bitz; do
	local oldPackagePath = package.path
	package.path = package.path .. "./submodules/?/init.lua"
	bitz = require("bitazard")
	package.path = oldPackagePath
end
```

# Usage

Import bitazard and assign it to a local variable.

```lua
local bitz = require("bitazard")
```

`bitz` is the canonical name for importing and using bitazard. `bitazard` is also acceptable.

As long as the *luals* language server is running, simply type `bitz.` and your intellisense should provide to you documentation for all of the available functions. Or, you can browse through the init.lua, which has documentation and examples for every function in the API.

# Rationale

Lua, as a language, has problems with bit manipulation:

- Lua 5.1 does not support bitwise operations.
- Lua 5.2 supports bitwise operations in the form of the bit32 module, which operates on 32 bit unsigned integer numbers.
- Lua 5.3 introduces compatibility breaking bitwise operators, but does have bit32 as a fallback option.
- Lua 5.4 removes the bit32 fallback
- LuaJIT supports bitwise operations in the form of the bit extension module, which operates on 32 bit *signed* integer numbers, and can operate on 64 bit integer cdata numbers through LuaJIT's FFI interface.

It can be useful to think about binary data without having to worry about the underlying number implementation or version compatability. To that end, Bitazard exists as an option.

Keep in mind, however, that Bitazard is inefficient compared to Pure C bitwise functions, and will be slower than the native Lua bitwise functions which are available with the different versions of the Lua language. Its purpose therefore is more for glue code in cases where there is no appetite or ability to implement the language-version specific operations, such as in a library targetting multiple versions of Lua.

# Types

Bitazard declares the following types as LuaCATS annotations:

- `bitazard.bit` 0 or 1.
- `bitazard.byte` A tuple of 8 `bitazard.bit`.
- `bitazard.byteArray` An array of `bitazard.byte`.

Please note that numeric functions involving bytes will not accept byteArrays longer than 7 bytes, as 53 bits is the maximum size of the significand in the default Lua number (IEEE 754 double). If you don't know what that means, it just means that bitazard respects the upper bounds of numbers representable with Lua. If you need a bigger number than 9,007,199,254,740,991; you should extend bitazard to work with a big number library of your choosing.

Bitazard types are pure Lua constructs with no metatables.

# Testing

Bitazard is tested using LuaJIT, but is written without any Lua language version specific constructs, and should pass tests and behave the same on all major Lua platforms. (5.1 through 5.4, LuaJIT).

In the case you find a failing test, please reach out.

# Future

I consider Bitazard to be, at this time, complete software. It should be easily extensible enough for specific use-cases, containing functions for conversion to and from unsigned integers, which is my primary use case as it pertains to Lua characters. However, in the future, I can see arguments for adding the following, but such additions would only arise as needed.

- Function to convert from byteArrays to signed integers. Will probably be added as needed.
- Documentation. While Bitazard's source files are verbosely documented, not everyone may be using luals/LuaCATS, or may prefer external documentation. This will probably be added at my leisure.
- Adding an __index metatable to bytes and byteArrays to allow for method calling and method chaining. This is of very little value to me because it is syntactic sugar and easily implementable by the end user if needed.
- - Add testing workflows for Lua versions 5.1 through 5.4. Unlikely to be added in the near future, as LuaJIT is the primary support platform.