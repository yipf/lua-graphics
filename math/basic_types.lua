--------------------------------------------------------------------
-- helper functions
--------------------------------------------------------------------

local push,pop,concat=table.insert,table.remove,table.concat
local setmetatable,getmetatable=setmetatable,getmetatable
local rawset,rawget,rawequal=rawset,rawget,rawequal
local type=type
local format=string.format


local tensor_operation
tensor_operation=function(a,b,op)
	if type(a)~='table' then return op(a,b) end
	local t={}
	if type(b)~='table' then 
		for i,v in ipairs(a) do		t[i]=tensor_operation(v,b)	end
	else
		for i,v in ipairs(a) do		t[i]=tensor_operation(v,b[i])	end
	end
	return t
end

local tensor_status
tensor_status=function(t,op,value)
	value=value or 0
	if type(t)~='table' then return op(t,value) end
	for i,v in ipairs(t) do		value=tensor_status(v,op,value)	end
	return value
end

local tensor_eq
tensor_eq=function(a,b)
	if type(a)~='table' then return rawequal(a,b) end
	if type(b)~='table' or #a~=#b then return false end
	for i,v in ipairs(a) do
		if not tensor_eq(v,b[i]) then return false end
	end
	return true
end

local tensor_clone
tensor_clone=function(src)
	if type(src)~='table' then return src end
	local dst={}
	for i,v in ipairs(src) do dst[i]=tensor_clone(v) end
	return dst
end

local cons=function(a,b)
	if type(a)~='table' then return {a,b} end
	local c=tensor_clone(a)
	push(c,b)
	return rawset(c,"__ISPAIR",true)
end

local tensor_product
tensor_product=function(a,b)
	local p,element={}
	local push=table.insert
	for i,va in ipairs(a) do
		for j,vb in ipairs(b) do
			push(p,cons(element,vb))
		end
	end
	return p
end

local alloc_tensor
alloc_tensor=function(n,...)
	if n then
		local t={}
		if #arg>0 then
			for i=1,n do		t[i]=alloc_tensor(unpack(arg))		end
		else
			for i=1,n do		t[i]=i	end
		end
		return t
	end
end

local mat=alloc_tensor(2,2)

for i,v in ipairs(mat) do
	print(i,v)
end



local create_tensor=function(t,v,...)
	if type(n)=="table" then return setmetatable(n,getmetatable(t)) end
	local result={}
	if type(v)~='function' then v=function() return v endend
	for i=1,n do
		result[i]=v(i)
	end
	return setmetatable(result,getmetatable(t))
end

local clone_tensor
clone_tensor=function(src,dst)
	if type(src)~='table' then return src end
	dst=dst or {}
	for i,v in ipairs(src) do
		dst[i]=clone_tensor(v)
	end
	return setmetatable(dst,getmetatable(src))
end

local make_op_func_1=function(op,value)
	return function(t)
		return tensor_status(t,value)
	end
end

local make_op_func_2=function(op)
	return function(t1,t2)
		local t=tensor_apply_operation(t1,t2,op)
		return setmetatable(t,getmetatable(t1))
	end
end

local make_metatable=function(tbl)
	tbl.__index=tbl
	tbl.__eq=generic_eq
	return tbl
end


--------------------------------------------------------------------
-- special functions
--------------------------------------------------------------------

local add=function(a,b) return a+b end
local sub=function(a,b) return a-b end
local mul=function(a,b) return a*b end
local div=function(a,b) return a/b end

local tensor_add=make_op_func_2(add)
local tensor_sub=make_op_func_2(sub)
local tensor_mul=make_op_func_2(mul)
local tensor_div=make_op_func_2(div)


local nrm=function(a,sum) return sum+a end
local nrm2=function(a,sum) return sum+a^a end
local max=function(a,current) return a>current and a or current end
local min=function(a,current) return a<current and a or current end

local tensor_nrm=function(t)
	return tensor_status(v,nrm)
end

--------------------------------------------------------------------
-- vector functions
--------------------------------------------------------------------

local vector_mul=function(v1,v2)
	local v=tensor_mul(v1,v2)
	return  type(v2)=="table" and tensor_status(v,nrm,0)  or setmetatable(v,getmetatable(v1))

local vector2str=function(vec)
	return ("\t["..table.concat(vec,"\t").."]")
end

local vector2file=function(vec,filepath)
	local fhandle=io.open(filepath,"w")
	assert(fhandle,"Can't open file:\t"..filepath)
	print("Saving vector to",filepath,"...")
	fhandle:write(vector2str(vec))
	fhandle:close()
	print("Success!")
end

local file2vector=function(vec,filepath)
	local res={}
	local fhandle=io.open(filepath)
	assert(fhandle,"Can't open file:\t"..filepath)
	print("Loading vector from",filepath,"...")
	local number
	number=fhandle:read("*n")
	while number do
		push(res,number)
		number=fhandle:read("*n")
	end
	fhandle:close()
	print("Success!")
	return setmetatable(res,getmetatable(vec))
end

local vector_mt=make_metatable{
	__add=tensor_add,
	__sub=tensor_sub,
	__mul=vector_mul,
	__call=function(vec,i,v)		return v and rawset(vec,i,v) or rawget(vec,i)	end,
	__tostring=vector2str,
	__eq=tensor_eq,
	-- others
	new=create_tensor,
	clone=clone_tensor,
	size=function(vec) return #vec	end,
	nrm=make_op_func_1(nrm,0),
	nrm2=make_op_func_1(nrm2,0),
	min=make_op_func_1(nrm,min,math.huge),
	max=make_op_func_1(nrm,max,-math.huge),
	save=vector2file,
	load=file2vector,
}

Vector=setmetatable({0},vector_mt)



local v1=Vector:new()


