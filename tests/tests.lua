local bitz; do
	local oldPackagePath = package.path
	package.path = "../?.lua"
	bitz = require("init")
	package.path = oldPackagePath
end

local lu; do
	local oldPackagePath = package.path
	package.path = "./luaunit/?.lua"
	lu = require("luaunit")
	package.path = oldPackagePath
end

local BIG_INT = 9007199254740991

TestPositiveIntegerToBytes = {
	-- Given a number,

	-- When the number is 127,
	-- Then the bytes should be { 0, 1, 1, 1, 1, 1, 1, 1 }.
	test_127 = function(self)
		local testByte = bitz.PositiveIntegerToBytes(127)
		lu.assertEquals(
			testByte[1],
			{
				0, 1, 1, 1,
				1, 1, 1, 1
			}
		)
	end,

	-- When the number is 1,
	-- Then the bytes should be { 0, 0, 0, 0, 0, 0, 0, 1 }.
	test_1 = function(self)
		lu.assertEquals(
			bitz.PositiveIntegerToBytes(1)[1],
			{
				0, 0, 0, 0,
				0, 0, 0, 1
			}
		)
	end,

	-- When the number is 34833
	-- Then the bytes should be {
	-- 	{ 1, 0, 0, 0, 1, 0, 0, 0 },
	-- 	{ 0, 0, 0, 1, 0, 0, 0, 1 }
	-- }.
	test_34833 = function(self)
		lu.assertEquals(
			bitz.PositiveIntegerToBytes(34833),
			{
				{
					1, 0, 0, 0,
					1, 0, 0, 0
				},
				{
					0, 0, 0, 1,
					0, 0, 0, 1
				}
			}
		)
	end
}

TestBytesToNumber = {
	-- Given a valid table of bytes,

	-- When the bytes are { 0, 1, 1, 1, 1, 1, 1, 1 },
	-- Then the number should be 127.
	test_127 = function(self)
		lu.assertEquals(
			bitz.BytesToPositiveInteger({
				0, 1, 1, 1,
				1, 1, 1, 1
			}),
			127
		)
	end,

	-- When the bytes are { 0, 0, 0, 0, 0, 0, 0, 1 },
	-- Then the number should be 1.
	test_1 = function(self)
		lu.assertEquals(
			bitz.BytesToPositiveInteger({
				0, 0, 0, 0,
				0, 0, 0, 1
			}),
			1
		)
	end,

	-- When the bytes are {
	-- 	{ 1, 0, 0, 0, 1, 0, 0, 0 },
	-- 	{ 0, 0, 0, 1, 0, 0, 0, 1 }
	-- },
	-- Then the number should be 34833.
	test_34833 = function(self)
		lu.assertEquals(
			bitz.BytesToPositiveInteger({
				{
					1, 0, 0, 0,
					1, 0, 0, 0
				},
				{
					0, 0, 0, 1,
					0, 0, 0, 1
				}
			}),
			34833
		)
	end,

	-- When there is more than 7 bytes,
	-- The function should return nil
	test_TooManyBytes = function(self)
		lu.assertEquals(
			bitz.BytesToPositiveInteger({
				{ 1, 0, 0, 0, 0, 0, 0, 0 },
				{ 1, 1, 0, 0, 0, 0, 0, 0 },
				{ 1, 1, 1, 0, 0, 0, 0, 0 },
				{ 1, 1, 1, 1, 0, 0, 0, 0 },
				{ 1, 1, 1, 1, 1, 0, 0, 0 },
				{ 1, 1, 1, 1, 1, 1, 0, 0 },
				{ 1, 1, 1, 1, 1, 1, 1, 0 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
			}
			),
			nil
		)
	end,

	-- When the bytes represent 2 ^ 53 - 1,
	-- Then the number should be 2 ^ 53 -1.
	test_BigINT = function(self)
		lu.assertEquals(
			bitz.BytesToPositiveInteger({
				{ 0, 0, 0, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
			}),
			BIG_INT
		)
	end,

	-- When the bytes represent a number greater than 2 ^ 53 - 1,
	-- Then the function should return 2 ^ 53 - 1.
	test_TooBigINT = function()
		lu.assertEquals(
			bitz.BytesToPositiveInteger({
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
				{ 1, 1, 1, 1, 1, 1, 1, 1 },
			}),
			BIG_INT
		)
	end,
}

TestIsValidByte = {
	test_0 = function(self)
		lu.assertEquals(bitz.IsValidByte({ 0, 0, 0, 0, 0, 0, 0, 0 }), true)
	end,
	test_Overlong = function(self)
		lu.assertEquals(bitz.IsValidByte({ 0, 0, 0, 0, 0, 0, 0, 1, 1 }), false)
	end,
	test_WrongElement = function(self)
		lu.assertEquals(bitz.IsValidByte({ 0, 0, 0, 0, 0, 0, 0, "1" }), false)
	end,
	test_Nil = function(self)
		lu.assertEquals(bitz.IsValidByte(nil), false)
	end,
	test_Empty = function(self)
		lu.assertEquals(bitz.IsValidByte({}), false)
	end,
	test_WrongType = function(self)
		lu.assertEquals(bitz.IsValidByte(1), false)
	end,
}

TestBand = {
	test_all = function(self)
		lu.assertEquals(bitz.band(
				{
					1, 1, 1, 1,
					1, 1, 1, 1
				},
				{
					1, 1, 1, 1,
					1, 1, 1, 1
				}
			),
			{
				1, 1, 1, 1,
				1, 1, 1, 1
			})
	end,
	test_none = function(self)
		lu.assertEquals(bitz.band(
				{
					0, 0, 0, 0,
					0, 0, 0, 0
				},
				{
					1, 1, 1, 1,
					1, 1, 1, 1
				}
			),
			{
				0, 0, 0, 0,
				0, 0, 0, 0
			})
	end,
}

TestBor = {
	test_all = function(self)
		lu.assertEquals(bitz.bor(
				{
					1, 1, 1, 1,
					1, 1, 1, 1
				},
				{
					1, 1, 1, 1,
					1, 1, 1, 1
				}
			),
			{
				1, 1, 1, 1,
				1, 1, 1, 1
			})
	end,
	test_none = function(self)
		lu.assertEquals(bitz.bor(
				{
					0, 0, 0, 0,
					0, 0, 0, 0
				},
				{
					0, 0, 0, 0,
					0, 0, 0, 0
				}
			),
			{
				0, 0, 0, 0,
				0, 0, 0, 0
			})
	end,
	test_partial = function(self)
		lu.assertEquals(bitz.bor(
				{
					1, 1, 0, 0,
					1, 1, 1, 1
				},
				{
					0, 0, 1, 1,
					1, 1, 1, 1
				}
			),
			{
				1, 1, 1, 1,
				1, 1, 1, 1
			})
	end
}

TestBsr = {
	test_shift_1_through_7 = function(self)
		for i = 1, 7 do
			local testByte = bitz.PositiveIntegerToBytes(2 ^ i)[1]
			local shiftedByte = bitz.bsr(testByte, i)
			lu.assertEquals(
				shiftedByte,
				{ 0, 0, 0, 0, 0, 0, 0, 1 },
				"Iteration: " .. i
			)
		end
	end,

	test_shift_8 = function(self)
		local testByte = bitz.PositiveIntegerToBytes(2 ^ 8)[1]
		local shiftedByte = bitz.bsr(testByte, 8)
		lu.assertEquals(
			shiftedByte,
			{ 0, 0, 0, 0, 0, 0, 0, 0 }
		)
	end,
}

TestBsl = {
	test_shift_1_through_7 = function(self)
		for i = 1, 7 do
			local testByte = bitz.PositiveIntegerToBytes(1)[1]
			local shiftedByte = bitz.bsl(testByte, i)
			lu.assertEquals(
				shiftedByte,
				bitz.PositiveIntegerToBytes(2 ^ i)[1],
				"Iteration: " .. i
			)
		end
	end,

	test_shift_8 = function(self)
		local testByte = bitz.PositiveIntegerToBytes(1)[1]
		local shiftedByte = bitz.bsl(testByte, 8)
		lu.assertEquals(
			shiftedByte,
			{ 0, 0, 0, 0, 0, 0, 0, 0 }
		)
	end,
}

TestMostSignificantBits = {
	test_1_through_8 = function(self)
		for i = 1, 8 do
			local testByte = { 1, 1, 1, 1, 1, 1, 1, 1 }
			local mostSignificantBits = bitz.MostSignificantBits(testByte, i)
			local testAgainst = 0; for j = 1, i do
				testAgainst = testAgainst + 2 ^ (8 - j)
			end
			lu.assertEquals(
				mostSignificantBits,
				bitz.PositiveIntegerToBytes(testAgainst)[1],
				"Iteration: " .. i
			)
		end
	end
}

TestLeastSignificantBits = {
	test_1_through_8 = function(self)
		for i = 1, 8 do
			local testByte = { 1, 1, 1, 1, 1, 1, 1, 1 }
			local leastSignificantBits = bitz.LeastSignificantBits(testByte, i)
			local testAgainst = 0; for j = 1, i do
				testAgainst = testAgainst + 2 ^ (j - 1)
			end
			lu.assertEquals(
				leastSignificantBits,
				bitz.PositiveIntegerToBytes(testAgainst)[1],
				"Iteration: " .. i
			)
		end
	end
}

os.exit(lu.LuaUnit.run())
