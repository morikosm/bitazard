local Public = {}  -- Public Module Table
local private = {} -- Private Module Table

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
function Public.numberToBytes(number)
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
function Public.byteToNumber(byte)
	local number = 0
	for index, bit in ipairs(byte) do
		number = number + bit * 2 ^ (index - 1)
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

function Public.mostSignificantBits(byte, count)
	local output = {}

	for i = 1, 8 - count do
		output[i] = 0
	end

	for i = 8, 8 - count, -1 do
		output[i] = byte[i]
	end

	return output
end

function Public.leastSignificantBits(byte, count)
	local output = {}

	for i = 1, count do
		output[i] = byte[i]
	end

	for i = count + 1, 8 do
		output[i] = 0
	end

	return output
end

function Public.bitShiftRight(byte, count)
	local output = {}

	for i = 1, 8 do
		output[i] = byte[i + count] or 0
	end

	return output
end

function Public.bitShiftLeft(byte, count)
	local output = {}

	for i = 1, 8 - count do
		if i + count < 9 then
			output[i + count] = byte[i]
		end
	end

	return output
end

return Public
