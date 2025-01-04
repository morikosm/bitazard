local Public = {}  -- Public Module Table
local private = {} -- Private Module Table

--- @alias bitazard.bit number<0|1>
--- @alias bitazard.byte [bitazard.bit, bitazard.bit, bitazard.bit, bitazard.bit, bitazard.bit, bitazard.bit, bitazard.bit, bitazard.bit]
--- @alias bitazard.byteArray bitazard.byte[]

---MARK: Validity

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
--- bitz.IsValidByte({ 0, 0, 0, 0, 0, 0, 0, 1 })
--- -- Output:
--- -- true
---
--- bitz.IsValidByte({ 0, 0, 0, 0, 0, 0, 0, 1, 0 })
--- -- Output:
--- -- false
--- ```
--- @param byte bitazard.byte	# The byte to validate.
--- @return boolean isValid	# Whether the byte is valid.
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

---MARK: Conversion

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
--- @param number integer	# The positive number to convert to bytes.
--- @return bitazard.byteArray bytes	# The bytes represented by the number.
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
--- Accepts either a single byte or a list of bytes, with each byte represented as a list of bits.
--- Converts up to 7 bytes equalling 2^53 - 1. If provided 7 bytes, the top 3 bits of the first byte are ignored.
--- The bytes are assumed to be big-endian, with the most significant byte first.
--- Returns nil if more than 7 bytes are passed.
---
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
--- @param bytes bitazard.byteArray	# The bytes to convert to a positive integer.
--- @return integer|nil number	# The positive integer represented by the bytes.
function Public.BytesToPositiveInteger(bytes)
	-- If a single byte is passed, wrap it in a table
	if #bytes == 8 then
		if type(bytes[1]) == "number" and Public.IsValidByte(bytes) then
			bytes = { bytes }
		end
	end

	-- If more than 7 bytes are passed, return nil
	-- (2^53 - 1 is the maximum number representable in Lua, therefore 7 bytes, without the top 3 bits of the last byte)
	if #bytes > 7 then
		return nil
	end

	-- Convert the list of bytes to a number
	local number = 0; for byteIndex, byte in ipairs(bytes) do
		for i, bit in ipairs(byte) do
			if not (i <= 3 and byteIndex == 1 and #bytes == 7) then
				-- ∀ bits | bit == 1 : number += 2^(#bytes * 8 - ((byteIndex - 1) * 8) - i)
				number = number + bit * 2 ^ ((#bytes * 8) - ((byteIndex - 1) * 8) - i)
			end
		end
	end
	return number
end

---MARK: Bitwise Operations

---**band**
---
--- Bitwise AND
---
--- Performs a bitwise AND operation on two bytes.
---
--- **Example:**
--- ```lua
--- bitz.band(
--- 	{ 1, 0, 0, 0, 1, 0, 0, 0 },
--- 	{ 0, 0, 0, 1, 1, 0, 0, 1 },
--- )
--- -- Output:
--- -- { 0, 0, 0, 0, 1, 0, 0, 0 }
--- ```
--- @param lhs bitazard.byte	# The left byte. Order does not matter.
--- @param rhs bitazard.byte	# The right byte. Order does not matter.
--- @return bitazard.byte output	# The result of the bitwise AND operation.
function Public.band(lhs, rhs)
	local output = {}
	for i = 1, 8 do
		output[i] = (lhs[i] == rhs[i]) and 1 or 0
	end
	return output
end

---**bor**
---
--- Bitwise OR
---
--- Performs a bitwise OR operation on two bytes.
---
--- **Example:**
--- ```lua
--- bitz.bor(
--- 	{ 1, 0, 0, 0, 1, 0, 0, 0 },
--- 	{ 0, 0, 0, 1, 1, 0, 0, 1 },
--- )
--- -- Output:
--- -- { 1, 0, 0, 1, 1, 0, 0, 1 }
--- ```
--- @param lhs bitazard.byte	# The left byte. Order does not matter.
--- @param rhs bitazard.byte	# The right byte. Order does not matter.
--- @return bitazard.byte output	# The result of the bitwise OR operation.
function Public.bor(lhs, rhs)
	local output = {}
	for i = 1, 8 do
		output[i] = (lhs[i] == 1 or rhs[i] == 1) and 1 or 0
	end
	return output
end

---**bxor**
---	
--- Bitwise XOR
---
--- Performs a bitwise XOR operation on two bytes.
---
--- **Example:**
--- ```lua
--- bitz.bxor(
--- 	{ 1, 0, 0, 0, 1, 0, 0, 0 },
--- 	{ 0, 0, 0, 1, 1, 0, 0, 1 },
--- )
--- -- Output:
--- -- { 1, 0, 0, 1, 0, 0, 0, 1 }
--- ```
--- @param lhs bitazard.byte	# The left byte. Order does not matter.
--- @param rhs bitazard.byte	# The right byte. Order does not matter.
--- @return bitazard.byte output	# The result of the bitwise XOR operation.
function Public.bxor(lhs, rhs)
	local output = {}
	for i = 1, 8 do
		output[i] = (lhs[i] ~= rhs[i]) and 1 or 0
	end
	return output
end

---**bnot**
---
--- Bitwise NOT
---
--- Performs a bitwise NOT operation on a byte.
---
--- **Example:**
--- ```lua
--- bitz.bnot({ 1, 0, 0, 0, 1, 0, 0, 0 })
--- -- Output:
--- -- { 0, 1, 1, 1, 0, 1, 1, 1 }
--- ```
--- @param byte bitazard.byte	# The byte to perform the bitwise NOT operation on.
--- @return bitazard.byte output	# The result of the bitwise NOT operation.
function Public.bnot(byte)
	local output = {}
	for i = 1, 8 do
		output[i] = (byte[i] == 1) and 0 or 1
	end
	return output
end

---**MostSignificantBits**
---
--- Creates a new byte with the most significant (leftmost) bits of the input byte.
---
--- **Example:**
--- ```lua
--- bitz.MostSignificantBits({ 1, 0, 0, 1, 1, 0, 0, 0 }, 4)
--- -- Output:
--- -- { 1, 0, 0, 1, 0, 0, 0, 0 }
--- ```
---@param byte bitazard.byte # The byte to extract the most significant bits from.
---@param count integer # The number of bits to extract.
---@return bitazard.byte output # The byte with the most significant bits.
function Public.MostSignificantBits(byte, count)
	local output = {}

	for i = 1, count do
		output[i] = byte[i]
	end

	for i = count + 1, 8 do
		output[i] = 0
	end

	return output
end

-- Alias for MostSignificantBits
Public.msb = Public.MostSignificantBits

---**LeastSignificantBits**
---
--- Creates a new byte with the least significant (rightmost) bits of the input byte.
--- ```lua
--- bitz.LeastSignificantBits({ 1, 0, 0, 1, 1, 0, 0, 0 }, 4)
--- -- Output:
--- -- { 0, 0, 0, 0, 1, 0, 0, 0}
--- ```
--- @param byte bitazard.byte	# The byte to extract the least significant bits from.
--- @param count integer	# The number of bits to extract.
--- @return bitazard.byte output	# The byte with the least significant bits.
function Public.LeastSignificantBits(byte, count)
	local output = {}

	for i = 8, 8 - count + 1, -1 do
		output[i] = byte[i]
	end

	for i = 8 - count, 1, -1 do
		output[i] = 0
	end

	return output
end

-- Alias for LeastSignificantBits
Public.lsb = Public.leastSignificantBits

---MARK: Shifts

---**BitShiftRight**
---
--- Bitwise Shift Right
---
--- Shifts the bits of a byte to the right by a specified number of places. Fills the leftmost bits with 0.
--- **Example:**
--- ```lua
--- bitz.BitShiftRight({ 1, 0, 0, 0, 1, 0, 0, 0 }, 2)
--- -- Output:
--- -- { 0, 0, 1, 0, 0, 0, 1, 0 }
--- ```
--- @param byte bitazard.byte	# The byte to shift.
--- @param count integer	# The number of places to shift the bits.
--- @return bitazard.byte output	# The byte after the bits have been shifted.
function Public.BitShiftRight(byte, count)
	local output = {}

	-- Create an empty byte
	for i = 1, count do
		-- ∀ i | 1 <= i <= count : output[i] = 0
		output[i] = 0
	end


	for i = count + 1, 8 do
		-- ∀ i | count < i <= 8 : output[i] = byte[i - count]
		output[i] = byte[i - count]
	end

	return output
end

-- Alias for BitShiftRight
Public.bsr = Public.BitShiftRight

---**BitShiftLeft**
---
--- Bitwise Shift Left
---
--- Shifts the bits of a byte to the left by a specified number of places. Fills the rightmost bits with 0.
---
--- **Example:**
--- ```lua
--- bitz.BitShiftLeft({ 0, 0, 1, 0, 0, 0, 1, 0 }, 2)
--- -- Output:
--- -- { 1, 0, 0, 0, 1, 0, 0, 0 }
--- ```
--- @param byte bitazard.byte	# The byte to shift.
--- @param count integer	# The number of places to shift the bits.
--- @return bitazard.byte output	# The byte after the bits have been shifted.
function Public.BitShiftLeft(byte, count)
	local output = {}

	for i = 1, 8 do
		-- ∀ i | 1 <= i <= 8 : output[i] = byte[i + count] or 0
		output[i] = byte[i + count] or 0
	end

	return output
end

-- Alias for BitShiftLeft
Public.bsl = Public.BitShiftLeft

---**BitRotateLeft**
---
--- Rotates the bits of a byte to the left by a specified number of places.
--- The bits that are shifted out of the byte are rotated back to the right.
---
--- **Example:**
--- ```lua
--- bitz.BitRotateLeft({ 1, 0, 0, 0, 1, 0, 0, 0 }, 2)
--- -- Output:
--- -- { 0, 0, 1, 0, 0, 0, 1, 0 }
--- ```
--- @param byte bitazard.byte	# The byte to rotate.
--- @param count integer	# The number of places to rotate the bits.
--- @return bitazard.byte output	# The byte after the bits have been rotated.
function Public.BitRotateLeft(byte, count)
	local output = {}

	-- ∀ i | 1 <= i <= 8 : output[i] = byte[(i+count-1) % 8 + 1]
	for i = 1, 8 do
		output[i] = byte[(i + count - 1) % 8 + 1]
	end

	return output
end

Public.brl = Public.BitRotateLeft

---**BitRotateRight**
---
--- Rotates the bits of a byte to the right by a specified number of places.
--- The bits that are shifted out of the byte are rotated back to the left.
--- **Example:**
--- ```lua
--- bitz.BitRotateRight({ 1, 0, 0, 0, 1, 0, 0, 1 }, 2)
--- -- Output:
--- -- { 0, 1, 1, 0, 0, 0, 1, 0}
--- ```
--- @param byte bitazard.byte	# The byte to rotate.
--- @param count integer	# The number of places to rotate the bits.
--- @return bitazard.byte output	# The byte after the bits have been rotated.
function Public.BitRotateRight(byte, count)
	local output = {}

	-- ∀ i | 1 <= i <= 8 : output[i] = byte[(i-count-1) % 8 + 1]
	for i = 1, 8 do
		output[i] = byte[(i - count - 1) % 8 + 1]
	end

	return output
end

Public.brr = Public.BitRotateRight

---**ArithmeticShiftRight**
---
--- Arithmetic Shift Right
---
--- Shifts the bits of a byte to the right by a specified number of places.
--- Fills the leftmost bits with the value of the sign (first) bit.
---
--- **Example:**
--- ```lua
--- bitz.ArithmeticShiftRight({ 1, 0, 0, 0, 1, 0, 0, 0 }, 2)
--- -- Output:
--- -- { 1, 1, 1, 0, 0, 0, 1, 0 }
--- ```
--- @param byte bitazard.byte	# The byte to shift.
--- @param count integer	# The number of places to shift the bits.
--- @return bitazard.byte output	# The byte after the bits have been shifted.
function Public.ArithmeticShiftRight(byte, count)
	local output = {}

	-- ∀ i | 1 <= i <= count : output[i] = byte[1]
	for i = 1, count do
		output[i] = byte[1]
	end

	-- ∀ i | count < i <= 8 : output[i] = byte[i - count]
	for i = count + 1, 8 do
		output[i] = byte[i - count]
	end

	return output
end

Public.asr = Public.ArithmeticShiftRight

return Public
