require "lua-utils/ioio"

local ffi=require "ffi"

clib_loader=function(name,dir)
	print("loading",name,"...")
	local dir=dir or "./clibs/"
	local des_str,lib=ffi.cdef(file2str(dir..name..".h")),ffi.load(dir..name..".so")
	return lib
end