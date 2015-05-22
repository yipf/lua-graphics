--------------------------------------------------------------------
-- helper functions
--------------------------------------------------------------------

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

local map=function(tbl,func,iter)
	iter=iter or ipairs
	for i,v in iter(tbl) do
		tbl[i]=func(i,v) or v
	end
	return tbl
end

--------------------------------------------------------------------
-- vector functions
--------------------------------------------------------------------

local create_vector=function(vec,n,v)
	if type(n)=="table" then return setmetatable(n,getmetatable(vec)) end
	n=n or 1
	local f=make_cell_func(v or 0)
	local res={}
	for i=1,n do push(res,f(i)) end
	return setmetatable(res,getmetatable(vec))
end

local clone_vector=function(vec)
	local f=function(i) return vec[i]	end
	return create_vector(vec,#vec,f)
end

local vector_add=function(v1,v2)
	local f
	if type(v2)=="table" then
		f=function(i) return v1[i]+v2[i] end
	else
		f=function(i) return v1[i]+v2 end
	end
	return create_vector(v1,#v1,f)
end

local vector_sub=function(v1,v2)
	local f
	if type(v2)=="table" then
		f=function(i) return v1[i]-v2[i] end
	else
		f=function(i) return v1[i]-v2 end
	end
	return create_vector(v1,#v1,f)
end

local vector_scale=function(v1,v2)
	local f=function(i,v) return v1[i]*v2 end
	return create_vector(v1,#v1,f)
end

local vector_dot=function(v1,v2)
	local sum=0
	for i,v in ipairs(v1) do		sum=sum+v*v2[i]	end
	return  sum
end

local vector_sum=function(v1)
	local sum=0
	for i,v in ipairs(v1) do
		sum=sum+v
	end
	return sum
end

local vector_min=function(v1)
	local val=math.huge
	for i,v in ipairs(v1) do
		val=val>v and v or val
	end
	return val
end

local vector_max=function(v1)
	local val=-math.huge
	for i,v in ipairs(v1) do
		val=val>v and val or v
	end
	return val
end

local vector2str=function(vec)
	return (table.concat(vec,"\t"))
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
	__add=vector_add,
	__sub=vector_sub,
	__mul=function(v1,v2) return type(v2)=="table" and vector_dot(v1,v2) or vector_scale(v1,v2) end,
	__call=function(vec,i,v)		return v and rawset(vec,i,v) or rawget(vec,i)	end,
	-- others
	new=create_vector,
	clone=clone_vector,
	size=function() return #vec	end,
	sum=vector_sum,
	min=vector_min,
	max=vector_max,
	print=function(vec,name) print((name or "vector").."=",unpack(vec))	end,
	save=vector2file,
	load=file2vector,
}

Vector=setmetatable({0},vector_mt)

--------------------------------------------------------------------
-- matrix functions
--------------------------------------------------------------------

local create_matrix=function(mat,m,n,v)
	if type(m)=="table" then return setmetatable(m,getmetatable(mat)) end
	m,n,v=m or 1,n or 1,v or 0
	local f=make_cell_func(v or 0)
	local res,row={}
	for i=1,m do
		row={}
		for j=1,n do
			push(row,f(i,j))
		end
		push(res,row)
	end
	return setmetatable(res,getmetatable(mat))
end

local clone_matrix=function(mat)
	local m,n=mat:size()
	return create_matrix(src,m,n,function(i,j) return mat(i,j) end)
end

local matrix_add=function(m1,m2)
	local f
	if type(m2)=="table" then
		f=function(i,j) return m1(i,j)+m2(i,j) end
	else
		f=function(i,j) return m1(i,j)+m2 end
	end
	local m,n=m1:size()
	return create_matrix(m1,m,n,f)
end

local matrix_sub=function(m1,m2)
	local f
	if type(m2)=="table" then
		f=function(i,j) return m1(i,j)-m2(i,j) end
	else
		f=function(i,j) return m1(i,j)-m2 end
	end
	local m,n=m1:size()
	return create_matrix(m1,m,n,f)
end

local matrix_scale=function(m1,m2)
	local f=function(i,j) return m1(i,j)*m2 end
	local m,n=m1:size()
	return create_matrix(m1,m,n,f)
end

local matrix_mul=function(mat1,mat2)
	local m1,n1=mat1:size()
	local m2,n2=mat2:size()
	assert(n1==2,"Dimension not match!")
	local f=function(i,j) return mat1:row(i)*mat2:col(j)	end
	return create_matrix(mat1,m1,n2,f)
end

local matrix_transpose=function(mat)
	local m,n=mat:size()
	local f=function(i,j)		return mat(j,i)	end
	return create_matrix(mat,n,m,f)
end

local matrix_row=function(mat,i)
	local m,n=mat:size()
	local f=function(j) return mat(i,j) end
	return Vector:new(n,f)
end

local matrix_col=function(mat,j)
	local m,n=mat:size()
	local f=function(i) return mat(i,j) end
	return Vector:new(m,f)
end

local matrix2file=function(mat,filepath)
	local fhandle=io.open(filepath,"w")
	assert(fhandle,"Can't open file:\t"..filepath)
	print("Saving matrix to",filepath,"...")
	local m,n=mat:size()
	local str
	for i=1,m do
		fhandle:write(vector2str(mat:row(i)),"\n")
	end
	fhandle:close()
	print("Success!")
end

local file2matrix=function(mat,filepath)
	local res={}
	local fhandle=io.open(filepath)
	assert(fhandle,"Can't open file:\t"..filepath)
	print("Loading matrix from",filepath,"...")
	local gmatch,tonumber=string.gmatch,tonumber
	local row
	for line in fhandle:lines() do
		row={}
		for w in gmatch(line,"%S+") do push(row,tonumber(w)) end
		if #row>0 then		push(res,row)	end
	end
	fhandle:close()
	print("Success!")
	return setmetatable(res,getmetatable(mat))
end

local matrix_mt=make_metatable{
	__add=matrix_add,
	__sub=matrix_sub,
	__mul=function(m1,m2) return type(m2)=="table" and matrix_mul(m1,m2) or matrix_scale(m1,m2) end,
	__call=function(mat,i,j,v) return v and rawset(rawget(mat,i),j,v) or rawget(rawget(mat,i),j)	end,
	-- others
	new=create_matrix,
	clone=clone_matrix,
	size=function(mat) return #mat,#mat[1]	end,
	row=matrix_row,
	col=matrix_col,
	svd=matrix_svd,
	inv=matrix_inv,
	transpose=matrix_transpose,
	print=function(mat,name)
		print((name or "matrix").."=")
		for i,row in ipairs(mat) do
			print("",unpack(row))
		end
	end,
	save=matrix2file,
	load=file2matrix,
}

Matrix=setmetatable({{0}},matrix_mt)

-- test

--~ local a=Vector:new(2,-9)

--~ a:print("a")

--~ local b=a-2

--~ b:print("b")

--~ b:save("b")

--~ local A=Matrix:new{a,b}
--~ A:print()
--~ local B=A*A
--~ B:print("B")
--~ B:save("B")
