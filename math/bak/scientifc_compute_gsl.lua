--------------------------------------------------------------------
-- helper functions
--------------------------------------------------------------------


require "lua-utils/clib-loader"

--~ GSL=clib_loader("clibs/gsl.h","/usr/lib/libgsl.so")
GSL,ffi=clib_loader("clibs/yipf-gsl.h")

local push,type=table.insert,type
local setmetatable,getmetatable=setmetatable,getmetatable
local rawset,rawget=rawset,rawget

local make_cell_func=function(value)
	return type(value)=="function" and value or function()
		return value
	end
end

local make_metatable=function(tbl)
	tbl.__index=tbl
	return tbl
end

--------------------------------------------------------------------
-- vector functions
--------------------------------------------------------------------

local create_vector=function(vec,n,v)
	local size,func
	if type(n)=="table" then 
		size=#n
		func=function(i) return n[i] end
	else
		size=n
		func=make_cell_func(v or 0)
	end
	local res=GSL.gsl_vector_alloc(size)
	for i=1,n do GSL.gsl_vector_set(res,i-1,func(i)) end
	return vector_t(res)
end

local destroy_vector=function(vec)
	return GSL.gsl_vector_free (vec.vec)
end

local vector_get_set=function(vec,i,v)
	vec=vec.vec
	if v  then
		return GSL.gsl_vector_set(vec,i-1,v)
	else
		return GSL.gsl_vector_get(vec,i-1)
	end
end

local vector_size=function(vec)
	vec=vec.vec
	return tonumber(vec.size)
end

local clone_vector=function(src)
	local n=src:dim()
	local dst=GSL.gsl_vector_alloc(n)
	GSL.gsl_vector_memcpy (dst, src.vec)
	return vector_t(dst)
end

local vector_add=function(v1,v2)
	local res=clone_vector(v1)
	print(v2,type(v2))
	if type(v2)=="number" then
		GSL.gsl_vector_add_constant (res.vec, v2)
	else
		GSL.gsl_vector_add (res.vec, v2.vec)
	end
	return res
end

local vector_sub=function(v1,v2)
	local res=clone_vector(v1)
	if type(v2)=="number" then
		GSL.gsl_vector_add_constant (res.vec, -v2)
	else
		GSL.gsl_vector_sub (res.vec, v2.vec)
	end
	return res
end

local vector_mul=function(v1,v2)
	local res=clone_vector(v1)
	if type(v2)=="number" then
		GSL.gsl_vector_scale (res.vec, v2)
	else
		GSL.gsl_vector_mul(res.vec, v2.vec)
	end
	return res
end

local vector_equal=function(v1,v2)
	return GSL.gsl_vector_equal (v1.vec, v2.vec) == 1
end

local vector_sum=function(v1)
	local n=vector_size(v1)
	local sum=0
	for i=1,n do sum=sum+v1(i) end
	return sum
end

local vector_dot=function(v1,v2)
	local n1,n2=vector_size(v1),vector_size(v2)
	local sum=0
	assert(n1==n2,"The length are not matched!")
	for i=1,n do sum=sum+v1(i)*v2(i) end
	return sum
end

local vector2table=function(vec)
	local n=vector_size(vec)
	local tbl={}
	for i=1,n do push(tbl,vec(i))	end
	return tbl
end

local table2vector=function(tbl)
	return create_vector(_,tbl)
end

local vector2str=function(vec)
	vec=vector2table(vec)
	return (table.concat(vec,"\t"))
end

local vector_print=function(vec,name)
	print((name or "vector").."=",vector2str(vec))
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
	return table2vector(res)
end

local vector_mt=make_metatable{
	__gc=destroy_vector,
	__len=vector_size,
	__call=vector_get_set,
	__sub=vector_sub,
	__add=vector_add,
	__mul=vector_mul,
	-- others
	new=create_vector,
	clone=clone_vector,
	dim=vector_size,
	sum=vector_sum,
	dot=vector_dot,
	print=vector_print,
	save=vector2file,
	load=file2vector,
}
ffi.cdef[[typedef struct{gsl_vector* vec;} vector_t;]]
vector_t=ffi.metatype("vector_t",vector_mt)
Vector=vector_t(GSL.gsl_vector_alloc(1))
print(Vector,Vector.vec)
--------------------------------------------------------------------
-- matrix functions
--------------------------------------------------------------------

--~ local create_matrix=function(mat,m,n,v)
--~ 	if type(m)=="table" then return setmetatable(m,getmetatable(mat)) end
--~ 	m,n,v=m or 1,n or 1,v or 0
--~ 	local f=make_cell_func(v or 0)
--~ 	local res,row={}
--~ 	for i=1,m do
--~ 		row={}
--~ 		for j=1,n do
--~ 			push(row,f(i,j))
--~ 		end
--~ 		push(res,row)
--~ 	end
--~ 	return setmetatable(res,getmetatable(mat))
--~ end

--~ local clone_matrix=function(mat)
--~ 	local m,n=mat:dim()
--~ 	return create_matrix(src,m,n,function(i,j) return mat(i,j) end)
--~ end

--~ local matrix_add=function(m1,m2)
--~ 	local f
--~ 	if type(m2)=="table" then
--~ 		f=function(i,j) return m1(i,j)+m2(i,j) end
--~ 	else
--~ 		f=function(i,j) return m1(i,j)+m2 end
--~ 	end
--~ 	local m,n=m1:dim()
--~ 	return create_matrix(m1,m,n,f)
--~ end

--~ local matrix_sub=function(m1,m2)
--~ 	local f
--~ 	if type(m2)=="table" then
--~ 		f=function(i,j) return m1(i,j)-m2(i,j) end
--~ 	else
--~ 		f=function(i,j) return m1(i,j)-m2 end
--~ 	end
--~ 	local m,n=m1:dim()
--~ 	return create_matrix(m1,m,n,f)
--~ end

--~ local matrix_scale=function(m1,m2)
--~ 	local f=function(i,j) return m1(i,j)*m2 end
--~ 	local m,n=m1:dim()
--~ 	return create_matrix(m1,m,n,f)
--~ end

--~ local matrix_mul=function(mat1,mat2)
--~ 	local m1,n1=mat1:dim()
--~ 	local m2,n2=mat2:dim()
--~ 	assert(n1==2,"Dimension not match!")
--~ 	local f=function(i,j) return mat1:row(i)*mat2:col(j)	end
--~ 	return create_matrix(mat1,m1,n2,f)
--~ end

--~ local matrix_transpose=function(mat)
--~ 	local m,n=mat:dim()
--~ 	local f=function(i,j)		return mat(j,i)	end
--~ 	return create_matrix(mat,n,m,f)
--~ end

--~ local matrix_row=function(mat,i)
--~ 	local m,n=mat:dim()
--~ 	local f=function(j) return mat(i,j) end
--~ 	return Vector:new(n,f)
--~ end

--~ local matrix_col=function(mat,j)
--~ 	local m,n=mat:dim()
--~ 	local f=function(i) return mat(i,j) end
--~ 	return Vector:new(m,f)
--~ end

--~ local matrix2file=function(mat,filepath)
--~ 	local fhandle=io.open(filepath,"w")
--~ 	assert(fhandle,"Can't open file:\t"..filepath)
--~ 	print("Saving matrix to",filepath,"...")
--~ 	local m,n=mat:dim()
--~ 	local str
--~ 	for i=1,m do
--~ 		fhandle:write(vector2str(mat:row(i)),"\n")
--~ 	end
--~ 	fhandle:close()
--~ 	print("Success!")
--~ end

--~ local file2matrix=function(mat,filepath)
--~ 	local res={}
--~ 	local fhandle=io.open(filepath)
--~ 	assert(fhandle,"Can't open file:\t"..filepath)
--~ 	print("Loading matrix from",filepath,"...")
--~ 	local gmatch,tonumber=string.gmatch,tonumber
--~ 	local row
--~ 	for line in fhandle:lines() do
--~ 		row={}
--~ 		for w in gmatch(line,"%S+") do push(row,tonumber(w)) end
--~ 		if #row>0 then		push(res,row)	end
--~ 	end
--~ 	fhandle:close()
--~ 	print("Success!")
--~ 	return setmetatable(res,getmetatable(mat))
--~ end

--~ local matrix_mt=make_metatable{
--~ 	__add=matrix_add,
--~ 	__sub=matrix_sub,
--~ 	__mul=function(m1,m2) return type(m2)=="table" and matrix_mul(m1,m2) or matrix_scale(m1,m2) end,
--~ 	__call=function(mat,i,j,v) return v and rawset(rawget(mat,i),j,v) or rawget(rawget(mat,i),j)	end,
--~ 	-- others
--~ 	new=create_matrix,
--~ 	clone=clone_matrix,
--~ 	size=function(mat) return #mat,#mat	end,
--~ 	row=matrix_row,
--~ 	col=matrix_col,
--~ 	svd=matrix_svd,
--~ 	inv=matrix_inv,
--~ 	transpose=matrix_transpose,
--~ 	print=function(mat,name)
--~ 		print((name or "matrix").."=")
--~ 		for i,row in ipairs(mat) do
--~ 			print("",unpack(row))
--~ 		end
--~ 	end,
--~ 	save=matrix2file,
--~ 	load=file2matrix,
--~ }

--~ Matrix=setmetatable({{0}},matrix_mt)

-- test

local a=Vector:new(2,-9)

a:print("a")

print(a:sum())

local b=a+a
print("a+a")

--~ b:save("vb")

--~ local A=Matrix:new{a,b}
--~ A:print()
--~ local B=A*A
--~ B:print("B")
--~ B:save("B")
