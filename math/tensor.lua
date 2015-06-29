--------------------------------------------------------------------
-- helper functions
--------------------------------------------------------------------

require'generic_operations'

local tensor_alloc,tensor_product=_generic_alloc,_generic_product

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

local tensor2str
tensor2str=function(t)
	if type(t)~='table' then return tostring(t) end
	local ss={}
	for i,v in ipairs(t) do		ss[i]=tensor2str(v)	end
	return #t.__SIZES==1 and "\t["..table.concat(ss,"\t" ).."]" or "{\n"..table.concat(ss,"\n").."\n}"
end

local tensor_get_set_=function(t,args,func)
	local n=#args
	if n>1 then
		for i=1,n-1 do
			if not t or type(t)~='table' then return end
			t=t[args[i]]
		end
	end
	local key=args[n]
	return func and rawset(t,key,func(t[key],unpack(args))) or rawget(t,key)
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
		ids=tensor_product(ids,make_tensor_1d(sizes[i]))
	end
	t.__IDS=ids
	return ids
end

local tensor_map_
tensor_map=function(t,f)
	if type(t)~='table' then return f(t) end
	local ids=t.__IDS or make_ids(t)
	for i,id in ipairs(ids) do
		tensor_get_set_(t,id,f)
	end
	return t
end



--------------------------------------------------------------------------------------------------------------------------
-- export for other file use
--------------------------------------------------------------------------------------------------------------------------


-------------------------
-- test 
-------------------------

local t3=tensor_alloc(3,4)

print(tensor2str(t3))

tensor_map(t3,function(v,i,j)
	return i+j
end)

print(tensor2str(t3))





--~ local create_tensor=function(t,v,...)
--~ 	if type(n)=="table" then return setmetatable(n,getmetatable(t)) end
--~ 	local result={}
--~ 	if type(v)~='function' then v=function() return v end
--~ 	for i=1,n do
--~ 		result[i]=v(i)
--~ 	end
--~ 	return setmetatable(result,getmetatable(t))
--~ end

--~ local clone_tensor
--~ clone_tensor=function(src,dst)
--~ 	if type(src)~='table' then return src end
--~ 	dst=dst or {}
--~ 	for i,v in ipairs(src) do
--~ 		dst[i]=clone_tensor(v)
--~ 	end
--~ 	return setmetatable(dst,getmetatable(src))
--~ end

--~ local make_op_func_1=function(op,value)
--~ 	return function(t)
--~ 		return tensor_status_(t,value)
--~ 	end
--~ end

--~ local make_op_func_2=function(op)
--~ 	return function(t1,t2)
--~ 		local t=tensor_apply_operation(t1,t2,op)
--~ 		return setmetatable(t,getmetatable(t1))
--~ 	end
--~ end

--~ local make_metatable=function(tbl)
--~ 	tbl.__index=tbl
--~ 	tbl.__eq=generic_eq
--~ 	return tbl
--~ end


--~ --------------------------------------------------------------------
--~ -- special functions
--~ --------------------------------------------------------------------

--~ local add=function(a,b) return a+b end
--~ local sub=function(a,b) return a-b end
--~ local mul=function(a,b) return a*b end
--~ local div=function(a,b) return a/b end

--~ local tensor_add=make_op_func_2(add)
--~ local tensor_sub=make_op_func_2(sub)
--~ local tensor_mul=make_op_func_2(mul)
--~ local tensor_div=make_op_func_2(div)


--~ local nrm=function(a,sum) return sum+a end
--~ local nrm2=function(a,sum) return sum+a^a end
--~ local max=function(a,current) return a>current and a or current end
--~ local min=function(a,current) return a<current and a or current end

--~ local tensor_nrm=function(t)
--~ 	return tensor_status_(v,nrm)
--~ end

--~ --------------------------------------------------------------------
--~ -- vector functions
--~ --------------------------------------------------------------------

--~ local vector_mul=function(v1,v2)
--~ 	local v=tensor_mul(v1,v2)
--~ 	return  type(v2)=="table" and tensor_status_(v,nrm,0)  or setmetatable(v,getmetatable(v1))

--~ local vector2str=function(vec)
--~ 	return ("\t["..table.concat(vec,"\t").."]")
--~ end

--~ local vector2file=function(vec,filepath)
--~ 	local fhandle=io.open(filepath,"w")
--~ 	assert(fhandle,"Can't open file:\t"..filepath)
--~ 	print("Saving vector to",filepath,"...")
--~ 	fhandle:write(vector2str(vec))
--~ 	fhandle:close()
--~ 	print("Success!")
--~ end

--~ local file2vector=function(vec,filepath)
--~ 	local res={}
--~ 	local fhandle=io.open(filepath)
--~ 	assert(fhandle,"Can't open file:\t"..filepath)
--~ 	print("Loading vector from",filepath,"...")
--~ 	local number
--~ 	number=fhandle:read("*n")
--~ 	while number do
--~ 		push(res,number)
--~ 		number=fhandle:read("*n")
--~ 	end
--~ 	fhandle:close()
--~ 	print("Success!")
--~ 	return setmetatable(res,getmetatable(vec))
--~ end

--~ local vector_mt=make_metatable{
--~ 	__add=tensor_add,
--~ 	__sub=tensor_sub,
--~ 	__mul=vector_mul,
--~ 	__call=function(vec,i,v)		return v and rawset(vec,i,v) or rawget(vec,i)	end,
--~ 	__tostring=vector2str,
--~ 	__eq=tensor_eq_,
--~ 	-- others
--~ 	new=create_tensor,
--~ 	clone=clone_tensor,
--~ 	size=function(vec) return #vec	end,
--~ 	nrm=make_op_func_1(nrm,0),
--~ 	nrm2=make_op_func_1(nrm2,0),
--~ 	min=make_op_func_1(nrm,min,math.huge),
--~ 	max=make_op_func_1(nrm,max,-math.huge),
--~ 	save=vector2file,
--~ 	load=file2vector,
--~ }

--~ Vector=setmetatable({0},vector_mt)



--~ local v1=Vector:new()




