require "lua-utils/clib-loader"

--~ GSL=clib_loader("clibs/gsl.h","/usr/lib/libgsl.so")
GSL,ffi=clib_loader("clibs/yipf-gsl.h")

local create_matrix=function(m,n,v)
	local mat=GSL.gsl_matrix_alloc(m,n)
	if v then
		GSL.gsl_matrix_set_all(mat,v)
	end
	return mat
end

local matrix_get=function(mat,i,j)
	return GSL.gsl_matrix_get(mat,i-1,j-1)
end

local matrix_set=function(mat,i,j,v)
	return GSL.gsl_matrix_set(mat,i-1,j-1,v)
end

local matrix_clone=function(src,dst)
	dst=dst or create_matrix (mat:size())
	GSL.gsl_matrix_memcpy (dst, src)
	return dst
end

local matrix_size=function(mat)
	return tonumber(mat.size1),tonumber(mat.size2)
end

local dot=function(vec1,vec2,n)
	
end

local tonumber,tostring,type,assert=tonumber,tostring,type,assert

local matrix_mt={
	__gc=GSL.gsl_matrix_free,
	__call=matrix_get_set,
	__add=function(a,b)
		a= matrix_clone(a)
		if type(b)=="number"then
			GSL.gsl_matrix_add_constant(a,b)
		else
			GSL.gsl_matrix_add_elements(a,b)
		return a
	end,
	__sub=function(a,b)
		a= matrix_clone(a)
		if type(b)=="number"then
			GSL.gsl_matrix_add_constant(a,-b)
		else
			GSL.gsl_matrix_sub(a,b)
		return a
	end,
	__mul=function(a,b)
		if type(b)=="number" then
			a= matrix_clone(a)
			GSL.gsl_matrix_scale(a,-b)
			return a
		else
			local a1,a2=matrix_size(a)
			local b1,b2=matrix_size(b)
			assert(a2==b1,"Dimention not match!")
			local m=create_matrix(a1,b2)
			for i=1,a1 do
				for j=1,b2 do
					matrix_set(m,i,j,)
				end
			end
			return m
		end
		return a
	end,
	__eq=function(a,b)
		return GSL.gsl_matrix_equal(a,b)==1
	end,
	__tostring=function(mat)
		local m,n=mat:size()
		
	end,
	-- oehter functions
	clone=matrix_clone,
	size=matrix_size,
	transpose=function(src)
		local m,n=src:size()
		local t=GSL.gsl_matrix_alloc (n, m)
		GSL.gsl_matrix_transpose_memcpy(t,src)
		return t
	end,
	new=function(_,tbl)
		local m,n=#tbl,#tbl[1]
		local mat=create_matrix(m,n)
		for i,row in ipairs(tbl) do
			for j,v in ipairs(row) do
				mat(i,j,v)
			end
		end
		return mat
	end,
	save=function(mat,filepath)
		
	end,
}
ffi.metatype("gsl_matrix",matrix_mt)

MATRIX=create_matrix(1,1,0) -- create a global matrix instance for furthur use

local create_vector=function(n,v)
	local vec=GSL.gsl_vector_alloc(n)
	if v then
		GSL.gsl_vector_set_all(vec,v)
	end
	return vec
end

local vector_get=function(vec,i)
	return GSL.gsl_vector_set(vec,i-1,v)
end

local vector_set=function(vec,i,v)
	return GSL.gsl_vector_get(vec,i-1)
end

local vector_size=function(vec)
	return tonumber(vec.size)
end

local matrix_clone=function(src,dst)
	dst=dst or create_vector (src:size())
	GSL.gsl_vector_memcpy (dst, src)
	return dst
end

local vector_mt={
	__gc=GSL.gsl_vector_free,
	__index=vector_get,
	__newindex=vector_set,
	__len=vector_size,
	-- other
	clone=vector_clone,
	size=vector_size,
	
	
}
ffi.metatype("gsl_vector",matrix_mt)

VECTOR=create_vector(1,0)-- create a global matrix instance for furthur use


local matrix2table=function(mat)
	local m,n=tonumber(mat.size1),tonumber(mat.size2)
	local tbl,row={}
	for i=1,m do
		row={}
		for j=1,n do
			row[j]=mat(i,j)
		end
		tbl[i]=row
	end
	return tbl
end


local vector2table=function(vec,destroy)
	local n=tonumber(vec.size)
	local tbl={}
	for i=1,n do
		tbl[i]=vec(i)
	end
	return tbl
end

local convert_funcs_totable={
	['gsl_vector']=vector2table,
	['gsl_matrix']=matrix2table,
	['gsl_vector*']=vector2table,
	['gsl_matrix*']=matrix2table,
}
totable=function(src)
	for tp,func in pairs(convert_funcs) do
		if ffi.istype(tp,src) then
			return func(src)
		end
	end
end

print_table_1d=function(tbl,name)
	print(name or "Vector=",table.concat(tbl,","))
	return tbl
end

print_table_2d=function(tbl,name)
	print(name or "Matrix=")
	for i,v in ipairs(tbl) do
		print_table_1d(v,"")
	end
	return tbl
end

-- user defined functions

--  http://hepg.sdu.edu.cn/zhangxueyao/software_doc/gsl/gsl-ref_toc.html#TOC219
-- A=U*S*V^T where diagonal matrix S is represented by vector S
SVD=function(t)
	local M,N=#t,#t[1]
	local A=table2matrix(t)
	local V,S=GSL.gsl_matrix_alloc(N, N),GSL.gsl_vector_alloc(N)
	GSL.gsl_linalg_SV_decomp_jacobi (A, V, S)
	return matrix2table(A,true),vector2table(S,true),matrix2table(V,true)
end

-- http://blog.sciencenet.cn/blog-261330-630627.html
local make_vector=function(n,value)
	value=value or 0
	local v={}
	local push=table.insert
	for i=1,n do	push(v,value)	end
	return v
end
-- X is m*n matrix which represent m vectors of n dimensions.
PCA=function(X,mean)
	local m,n=#X,#X[1]
	if not mean then
		mean=make_vector(n,0)
		local a,b
		-- compute center vector
		for j,x in ipairs(X) do
			a,b=(j-1)/j,1/j
			for i,v in ipairs(mean) do
				mean[i]=a*v+b*x[i]
			end
		end
	end
	-- X=X-(h^T)*mean where h[i]=1, i=1,2,...,m
	for j,x in ipairs(X) do
		for i,v in ipairs(mean) do
			x[i]=x[i]-v
		end
	end
	local U,S,V=SVD(X)
	return U,S,V,mean
end

--- 
local A=transpose_table_2d{
	{1,0,0,0,2},
	{0,0,3,0,0},
	{0,0,0,0,0},
	{0,4,0,0,0},
}


--~ print_table_2d(A,"A")

local U,S,V=SVD(A)
print_table_2d(U,"U")
print_table_2d(V,"V")
print_table_1d(S,"S")

--~ local X={
--~ 	{3,0},
--~ 	{0,2},
--~ }

--~ local U,S,V,m=PCA(X)
--~ print_table_2d(U,"U=")
--~ print_table_1d(S,"S=")
--~ print_table_2d(V,"V=")
--~ print_table_1d(m,"mean=")
