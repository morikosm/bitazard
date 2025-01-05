package = "bitazard"
version = "1.0.0"
source = {
	url = "git://github.com/morikosm/bitazard",
	tag = "v1"
}
description = {
	summary = "A Pure Lua bit manipulation library.",
	homepage = "https://github.com/morikosm/bitazard",
	license = "zlib",
}
dependencies = {
	"lua >= 5.1, <=5.4",
}
modules = {
	bitazard = "init.lua",
}