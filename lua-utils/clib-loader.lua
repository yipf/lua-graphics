require "lua-utils/ioio"

clib_loader=function(cdef_filename,libpath,name)
	libpath=libpath or string.gsub(cdef_filename,"^(.-)%.h$","%1%.so")
	name=name or string.match(cdef_filename,"^.-([^/]*)%.([^%.]-)$")
	print(string.format("Load modual %q from lib %q ...",name,libpath))
	local ffi=require "ffi"
	local str=file2str(cdef_filename) or ""
	ffi.cdef(str)
	print("Success!")
	return ffi.load(libpath),ffi
end