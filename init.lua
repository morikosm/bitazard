local Public = {}  -- Public Module Table
local private = {} -- Private Module Table

---**IsValidByte**
---
--- Validates if a table conforms to the byte format used by Bitazard.
---
--- Bitazard does not validate input on its function calls to avoid overhead, and assumes that
--- you are supplying valid input.
---
--- However, in the case you are receiving input from an outside source, you can use this function to validate it.
---
--- **Example:**
--- ```lua
--- bit.IsValidByte({ 0, 0, 0, 0, 0, 0, 0, 1 })
--- -- Output:
--- -- true
---
--- bit.IsValidByte({ 0, 0, 0, 0, 0, 0, 0, 1, 0 })
--- -- Output:
--- -- false
--- ```
--- @param byte table	# The byte to validate.
--- @return boolean boolean	# Whether the byte is valid.
function Public.IsValidByte(byte)
	-- A byte is a table...
	if type(byte) ~= "table" then
		return false
	end

	-- ...with 8 elements...
	if #byte ~= 8 then
		return false
	end

	-- ... where each element is either 0 or 1.
	for _, bit in ipairs(byte) do
		if bit ~= 0 and bit ~= 1 then
			return false
		end
	end

	return true
end

---**PositiveIntegerToBytes**
---
--- Converts a positive number to a list of bytes, with each byte represented as a list of bits.
--- Non-integer numbers are floored.
---
--- The resulting list of bytes is big-endian, with the most significant byte first.
---
--- **Example:**
--- ```lua
--- bitz.PositiveIntegerToBytes(34833)
--- -- Output:
--- -- {
--- -- 		{ 1, 0, 0, 0, 1, 0, 0, 0 },
--- -- 		{ 0, 0, 0, 1, 0, 0, 0, 1 },
--- -- }
--- ```
--- @param number number	# The positive number to convert to bytes.
--- @return table bytes	# The bytes represented by the number.
function Public.PositiveIntegerToBytes(number)
	-- Floor the number
	number = math.floor(number)

	-- Get the bit representation of the number, as a list, least-significant-bits first, such that 2 to the exponent of the index equals the bit's value
	local bits = {}; while number > 0 do
		table.insert(bits, number % 2)
		number = math.floor(number / 2)
	end

	-- Convert the bit list to a list of bytes, big endian
	local bytes = {}; for i = 1, #bits do
		if i % 8 == 1 then
			table.insert(bytes, 1, {})
		end

		table.insert(bytes[1], 1, bits[i])
	end

	-- Pad 8 bits to a byte
	if bytes[1] then
		while #bytes[1] < 8 do
			table.insert(bytes[1], 1, 0)
		end
	end

	return bytes
end

---**BytesToPositiveInteger**
---
--- Converts a list of bytes, with each byte represented as a list of bits, to a positive integer, up to 2^53 - 1.
--- The bytes are assumed to be big-endian, with the most significant byte first.
---
--- **Example:**
--- ```lua
--- bitz.BytesToPositiveInteger({
--- 	{ 1, 0, 0, 0, 1, 0, 0, 0 },
--- 	{ 0, 0, 0, 1, 0, 0, 0, 1 },
--- })
--- -- Output:
--- -- 34833
--- ```
--- @param bytes table	# The bytes to convert to a positive integer.
--- @return number number	# The positive integer represented by the bytes.
function Public.BytesToPositiveInteger(bytes)
	-- If a single byte is passed, wrap it in a table
	if #bytes == 8 then
		if type(bytes[1]) == "number" then
			bytes = { bytes }
		end
	end

	-- Convert the list of bytes to a number
	local number = 0; for byteIndex, byte in ipairs(bytes) do
		for i, bit in ipairs(byte) do
			-- ∀ bits | bit == 1 : number += 2^(#bytes * 8 - ((byteIndex - 1) * 8) - i)
			number = number + bit * 2 ^ ((#bytes * 8) - ((byteIndex - 1) * 8) - i)
		end
	end
	return number
end

function Public.band(lhs, rhs)
	local output = {}
	for i = 1, 8 do
		output[i] = (lhs[i] == rhs[i]) and 1 or 0
	end
	return output
end

function Public.bor(lhs, rhs)
	local output = {}
	for i = 1, 8 do
		output[i] = (lhs[i] == 1 or rhs[i] == 1) and 1 or 0
	end
	return output
end

function Public.MostSignificantBits(byte, count)
	local output = {}

	for i = 1, 8 - count do
		output[i] = 0
	end

	for i = 8, 8 - count, -1 do
		output[i] = byte[i]
	end

	return output
end

Public.msb = Public.mostSignificantBits

function Public.LeastSignificantBits(byte, count)
	local output = {}

	for i = 1, count do
		output[i] = byte[i]
	end

	for i = count + 1, 8 do
		output[i] = 0
	end

	return output
end

Public.lsb = Public.leastSignificantBits

function Public.BitShiftRight(byte, count)
	local output = {}

	for i = 1, 8 do
		output[i] = byte[i + count] or 0
	end

	return output
end

Public.bsr = Public.bitShiftRight

function Public.BitShiftLeft(byte, count)
	local output = {}

	for i = 1, 8 - count do
		if i + count < 9 then
			output[i + count] = byte[i]
		end
	end

	return output
end

Public.bsl = Public.bitShiftLeft

return Public
