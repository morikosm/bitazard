-- ---- Bit Manipulation ----
-- This section is going to be slow, and the rationale questionable.
-- Lua 5.1 does not support bitwise operations.
-- Lua 5.2 does, but it is in the form of the bit32 module.
-- Lua 5.3/5.4 has native bitwise operations, but these break backwards compatibility with 5.1/5.2 and LuaJIT.
-- LuaJIT has bit.*, but it is not available in all environments.
-- LuaRocks environments have a bit32 module, but it is not pure Lua, and LuaRocks on Windows is questionable at best.
--
-- The only solution is to implement them ourselves in pure Lua. If this implementation is too slow, recommend:
-- Implementing it for your environment.
-- Complaining to PUC RIO, lol.
-- --------------------------

local bitManip = {} -- Internal Use Bit Module

---**numberToBytes**
---
--- Converts a number to a list of bytes, with each byte represented as a list of bits.
---
--- The least significant byte is first in the list.
---
--- The least significant bit is first in each byte.
---
--- This might be a little counter-intuitive, but it is the easiest way to represent the binary data.
---
--- **Example:**
--- ```lua
--- bit.numberToBytes(128)
--- -- Output:
--- -- {
--- -- 	{ 0, 0, 0, 0, 0, 0, 0, 1 },
--- -- }
--- ```
function bitManip.numberToBytes(number)
	local bits = {}

	while number > 0 do
		table.insert(bits, number % 2)
		number = math.floor(number / 2)
	end

	local bytes = {}
	for index, bit in ipairs(bits) do
		if (index - 1) % 8 == 0 then
			table.insert(bytes, {})
		end
		-- print(math.floor((index - 1) / 8 + 1), ((index - 1) % 8) + 1, bit)
		bytes[math.floor((index - 1) / 8 + 1)][((index - 1) % 8) + 1] = bit
	end

	return bytes
end

---**byteToNumber**
---
--- Converts a byte, represented as a list of bits, with the least significant bit first, to a number.
---
--- **Example:**
--- ```lua
--- bit.byteToNumber({ 0, 0, 0, 0, 0, 0, 0, 1 })
--- -- Output:
--- -- 128.0
--- ```
--- @param byte table	# The byte to convert to a number.
--- @return number number	# The number represented by the byte.
function bitManip.byteToNumber(byte)
	local number = 0
	for index, bit in ipairs(byte) do
		number = number + bit * 2 ^ (index - 1)
	end
	return number
end

function bitManip.band(lhs, rhs)
	local output = {}
	for i = 1, 8 do
		output[i] = (lhs[i] == rhs[i]) and 1 or 0
	end
	return output
end

function bitManip.bor(lhs, rhs)
	local output = {}
	for i = 1, 8 do
		output[i] = (lhs[i] == 1 or rhs[i] == 1) and 1 or 0
	end
	return output
end

function bitManip.mostSignificantBits(byte, count)
	local output = {}

	for i = 1, 8 - count do
		output[i] = 0
	end

	for i = 8, 8 - count, -1 do
		output[i] = byte[i]
	end

	return output
end

function bitManip.leastSignificantBits(byte, count)
	local output = {}

	for i = 1, count do
		output[i] = byte[i]
	end

	for i = count + 1, 8 do
		output[i] = 0
	end

	return output
end

function bitManip.bitShiftRight(byte, count)
	local output = {}

	for i = 1, 8 do
		output[i] = byte[i + count] or 0
	end

	return output
end

function bitManip.bitShiftLeft(byte, count)
	local output = {}

	for i = 1, 8 - count do
		if i + count < 9 then
			output[i + count] = byte[i]
		end
	end

	return output
end

-- ---- End Section ----
