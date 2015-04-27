require "lua-utils/register"
local make_register_table=make_register_table

local importers,exporters=make_register_table(),make_register_table()

require "lua-utils/strstr"
local path2DirNameExt=path2DirNameExt

require "lua-utils/ioio"
local str2file,file2str=str2file,file2str

importer=function(filepath,mtype)
	local dir,name,ext=path2DirNameExt(filepath)
	mtype=mtype or ext
	local func=importers(mtype)
	if func then
		return func(filepath,dir)
	end
end

exporter=function(obj,filepath,mtype)
	local dir,name,ext=path2DirNameExt(filepath)
	mtype=mtype or ext
	local func=exporters(mtype)
	if func then
		return func(filepath,dir)
	end
end