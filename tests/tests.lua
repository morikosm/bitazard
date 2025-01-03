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

TestPositiveIntegerToBytes = {
	-- Given a number,

	-- When the number is 127,
	-- Then the bytes should be { 0, 1, 1, 1, 1, 1, 1, 1 }.
	testNumberToBytes_127 = function(self)
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
	testNumberToBytes_1 = function(self)
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
	testNumberToBytes_34833 = function(self)
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
	-- Given a table of bytes,

	-- When the bytes are { 0, 1, 1, 1, 1, 1, 1, 1 },
	-- Then the number should be 127.
	testBytesToNumber_127 = function(self)
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
	testBytesToNumber_1 = function(self)
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
	testBytesToNumber_34833 = function(self)
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
	end

}

os.exit(lu.LuaUnit.run())
