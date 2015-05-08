require "lua-utils/register"
local make_register_table=make_register_table

importers,exporters=make_register_table(),make_register_table()

require "lua-utils/strstr"
local path2DirNameExt=path2DirNameExt

import=function(filepath,mtype)
	local dir,name,ext=path2DirNameExt(filepath)
	mtype=mtype or ext
	local func=importers(mtype)
	if func then
		return func(filepath,dir)
	end
end

export=function(obj,filepath,mtype)
	local dir,name,ext=path2DirNameExt(filepath)
	mtype=mtype or ext
	local func=exporters(mtype)
	if func then
		return func(filepath,dir)
	end
end

-- implements

require "lua-utils/ioio"
local str2file,file2str,file2table=str2file,file2str,file2table

local push=table.insert
local obj_str2index=function(str)
	local t={}
	for num in string.gmatch(str,"[^/]") do
		push(t)
	end
	return t
end

local gmatch,match=string.gmatch,string.match

local obj_key_hooks
obj_key_hooks={
	['v']=function(str,dst)
		local t={}
		for w in gmatch(str,"%S+") do push(t,tonumber(w)) end
		push(dst.V,t)
		return dst
	end,
	['vt']=function(str,dst)
		local t={}
		for w in gmatch(str,"%S+") do push(t,tonumber(w)) end
		push(dst.T,t)
		return dst
	end,
	['vn']=function(str,dst)
		local t={}
		for w in gmatch(str,"%S+") do push(t,tonumber(w)) end
		push(dst.N,t)
		return dst
	end,
	['f']=function(str,dst)
		local V,T,N=dst.V,dst.T,dst.N
		local vs={}
		local v
		for element in gmatch(str,"%S+") do
			v={}
			for index in gmatch(element.."/","([^/]*)/") do
				push(v,tonumber(index) or 0)
			end
			push(vs,v)
		end
		push(dst,{"face",vs})
		return dst
	end,
	['mtllib']=function(path,dst,dir)
		file2table(dir..path,dst.MTL,obj_key_hooks,dir,"^%s*(.-)%s+(.-)%s*$")
		return dst
	end,
	['usemtl']=function(key,dst)
		push(dst,{"mtl",dst.MTL[key]})
		return dst
	end,
	--- hooks for stlfile
	['newmtl']=function(key,dst,dir)
		local mtl={}
		dst[key]=mtl
		dst.CURRENT=mtl
		return dst
	end,
	['map_Kd']=function(path,dst,dir)
		local mtl=dst.CURRENT
		mtl["map_Kd"]={"file",dir..path}
		return mtl
	end,
}

local f=function(filepath)
	local dir,name,ext=path2DirNameExt(filepath)
	return file2table(filepath,{V={},T={[0]={0,0}},N={},MTL={}},obj_key_hooks,dir,"^%s*(.-)%s+(.-)%s*$")
end
importers("obj",f)