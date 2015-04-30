require "lua-utils/register"
local make_register_table=make_register_table

print(make_register_table)

local importers,exporters=make_register_table(),make_register_table()

require "lua-utils/strstr"
local path2DirNameExt=path2DirNameExt

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

-- implements

require "lua-utils/ioio"
local str2file,file2str,file2table=str2file,file2str,file2table

local confirm_prop=function(t,key,init_value)
	
end

local obj_key_hooks={
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
		
		push(dst,{"face",vs})
		return dst
	end,
	['mtllib']=function(path,dst,dir)
		file2table(dir.."/"..filepath,dst.MTL,obj_key_hooks,dir,"^%s*(.-)%s+(.-)%s*$")
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
		push(mtl,{"map_kd",})
		return mtl
	end,
}

local f=function(filepath)
	local dir,name,ext=path2DirNameExt(filepath)
	return file2table(filepath,{V={},T={},N={},MTL={}},obj_key_hooks,dir,"^%s*(.-)%s+(.-)%s*$")
end
importer("obj",f)