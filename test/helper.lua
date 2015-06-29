local str=[[[
--------------------------------------------------------------------
-- helper functions
--------------------------------------------------------------------

local push,pop,concat=table.insert,table.remove,table.concat
local setmetatable,getmetatable=setmetatable,getmetatable
local rawset,rawget,rawequal=rawset,rawget,rawequal
local type=type
local format=string.format

local tensor_operation_
tensor_operation_=function(a,b,op)
	if type(a)~='table' then return op(a,b) end
	local t={}
	if type(b)~='table' then 
		for i,v in ipairs(a) do		t[i]=tensor_operation_(v,b)	end
	else
		for i,v in ipairs(a) do		t[i]=tensor_operation_(v,b[i])	end
	end
	return t
end

local tensor_status_
tensor_status_=function(t,op,value)
	value=value or 0
	if type(t)~='table' then return op(t,value) end
	for i,v in ipairs(t) do		value=tensor_status_(v,op,value)	end
	return value
end

local tensor_eq_
tensor_eq_=function(a,b)
	if type(a)~='table' then return rawequal(a,b) end
	if type(b)~='table' or #a~=#b then return false end
	for i,v in ipairs(a) do
		if not tensor_eq_(v,b[i]) then return false end
	end
	return true
end

local tensor_clone_
tensor_clone_=function(src)
	if type(src)~='table' then return src end
	local dst={}
	for i,v in ipairs(src) do dst[i]=tensor_clone_(v) end
	return dst
end

local cons=function(a,b)
	if type(a)~='table' then return {a,b} end
	local c=tensor_clone_(a)
	push(c,b)
	return rawset(c,"__ISPAIR",true)
end

local tensor_product_
tensor_product_=function(a,b)
	local p={}
	local push=table.insert
	for i,va in ipairs(a) do
		for j,vb in ipairs(b) do
			push(p,cons(va,vb))
		end
	end
	return p
end

local alloc_tensor_
alloc_tensor_=function(n,...)
	if n then
		local t={__SIZES={n,...}}
		for i=1,n do		t[i]=alloc_tensor_(...)		end
		return t
	end
	return 0
end

local tensor2str_
tensor2str_=function(t)
	if type(t)~='table' then return tostring(t) end
	local ss={}
	for i,v in ipairs(t) do		ss[i]=tensor2str_(v)	end
	return #t.__SIZES==1 and "\t["..table.concat(ss,"\t" ).."]" or "{\n"..table.concat(ss,"\n").."\n}"
end

local tensor_get_set_=function(t,args,v)
	local n=#args
	if n>1 then
		for i=1,n-1 do
			if not t or type(t)~='table' then return end
			t=t[args[i] ]
		end
	end
	return v and rawset(t,args[n],v) or rawget(t,args[n])
end

local make_tensor_1d=function(n)
	local t={}
	for i=1,n do t[i]=i end
	return t
end

local make_ids=function(t)
	local sizes=t.__SIZES
	local n=sizes and #sizes
	assert(n and n>0,"Need SIZES properties")
	local ids={}
	for i=1,sizes[1] do ids[i]={i} end
	for i=2,#sizes do
		ids=tensor_product_(ids,make_tensor_1d(sizes[i]))
	end
	t.__IDS=ids
	return ids
end

local tensor_map_
tensor_map_=function(t,f)
	if type(t)~='table' then return f(t) end
	local ids=t.__IDS or make_ids(t)
	for i,id in ipairs(ids) do
		tensor_get_set_(t,id,f(unpack(id)))
	end
	return t
end

--------------------------------------------------------------------------------------------------------------------------
-- export for other file use
--------------------------------------------------------------------------------------------------------------------------

tensor_operation_,tensor_status_,

-------------------------
-- test 
-------------------------

local t3=alloc_tensor_(3,4)

print(tensor2str_(t3))

tensor_map(t3,function(i,j)
	return i*j
end)

print(tensor2str_(t3))


]]

local t={}



