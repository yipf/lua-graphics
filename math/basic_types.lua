--------------------------------------------------------------------
-- helper functions
--------------------------------------------------------------------

local push,pop,concat=table.insert,table.remove,table.concat
local setmetatable,getmetatable=setmetatable,getmetatable
local rawset,rawget,rawequal=rawset,rawget,rawequal
local type=type
local format=string.format

local make_cell_func=function(value)
	return type(value)=="function" and value or function()
		return value
	end
end

local map=function(tbl,func,iter)
	iter=iter or ipairs
	for i,v in iter(tbl) do
		tbl[i]=func(i,v) or v
	end
	return tbl
end


local generic_eq
generic_eq=function(a,b)
	local tp1,tp2=type(a),type(b)
	if tp1~=tp2 then return false end
	if tp1=="table" then
		local n1,n2=#a,#b
		if n1~=n2 then return false end
		for i,v in ipairs(a) do
			if not generic_eq(v,b[i]) then return false end
		end
		return true
	else 
		return rawequal(a,b)
	end
end

local make_metatable=function(tbl)
	tbl.__index=tbl
	tbl.__eq=generic_eq
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
	__add=vector_add,
	__sub=vector_sub,
	__mul=function(v1,v2) return type(v2)=="table" and vector_dot(v1,v2) or vector_scale(v1,v2) end,
	__call=function(vec,i,v)		return v and rawset(vec,i,v) or rawget(vec,i)	end,
	__tostring=vector2str,
	-- others
	new=create_vector,
	clone=clone_vector,
	size=function() return #vec	end,
	sum=vector_sum,
	min=vector_min,
	max=vector_max,
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

local matrix2str=function(mat)
	local t={}
	for i,row in ipairs(mat) do
		t[i]="\t["..concat(row,"\t").."]"
	end
	return concat(t,"\n")
end

local matrix_mt=make_metatable{
	__add=matrix_add,
	__sub=matrix_sub,
	__mul=function(m1,m2) return type(m2)=="table" and matrix_mul(m1,m2) or matrix_scale(m1,m2) end,
	__call=function(mat,i,j,v) return v and rawset(rawget(mat,i),j,v) or rawget(rawget(mat,i),j)	end,
	__tostring=matrix2str,
	-- others
	new=create_matrix,
	clone=clone_matrix,
	size=function(mat) return #mat,#mat[1]	end,
	row=matrix_row,
	col=matrix_col,
	svd=matrix_svd,
	inv=matrix_inv,
	transpose=matrix_transpose,
	save=matrix2file,
	load=file2matrix,
}

Matrix=setmetatable({{0}},matrix_mt)

--------------------------------------------------------------------
-- set functions
--------------------------------------------------------------------

local create_set=function(set,tbl,func)
	local elements,new_set={},{}
	if tbl then
		local id=1
		for i,v in ipairs(tbl) do	
			if not elements[v] then
				elements[v]=id
				new_set[id]=v
				id=id+1
			end
		end
	end
	new_set.elements=elements
	new_set.test_func=func
	return setmetatable(new_set,getmetatable(set))
end

local clone_set=function(set)
	local new_set=create_set(set)
	for e in set:each() do
		new_set:insert(e)
	end
	new_set.test_func=set.test_func
	return new_set
end

set_each=function(set)
	local i=0
	local f=function()
		i=i+1
		return set[i]
	end
	return f
end

local set_include=function(set,element)
	local elements,test_func=set.elements,set.test_func
	if elements then return elements[element] else return test_func(element) end
end

local set_insert=function(set,element)
	local elements=set.elements
	assert(elements,"The 'insert' operation can only apply on finit sets!")
	assert(element,"The 'insert' operation need a valid element to add!")
	if not elements[element] then 
		push(set,element)
		elements[element]=#set
	end
	return set
end

local set_remove=function(set,element)
	local elements=set.elements
	assert(elements,"The 'remove' operation can only apply on finit sets!")
	assert(element,"The 'remove' operation need a valid element to add!")
	local id=elements[element]
	if id then  	-- update elements
		pop(set,id)
		for i=id,#set do	elements[set[i]]=i		end
	end
	return element
end

local element2str
element2str=function(element)
	if type(element)=="table" then
		local t={}
		for i,v in ipairs(element) do
			t[i]=element2str(v)
		end
		return format(element.__ISPAIR and "<%s>" or "{%s}",(concat(t,",")))
	end
	return tostring(element)
end

local set2str=function(set)
	local t={}
	for i,v in ipairs(set) do		t[i]=element2str(v)	end
	local str=concat(t,",")
	return "{"..str.."}"
end

local set_print=function(set,name)
	local str=concat(set,",")
	print((name or "set").." =",set2str(set))
end

local set_union=function(A,B)
	local C=clone_set(A)
	for b in B:each() do
		C:insert(b)
	end
	return C
end

local set_interaction=function(A,B)
	local C=create_set(A)
	for a in A:each() do
		if B:include(a) then C:insert(a) end
	end
	return C
end

local set_sub=function(A,B)
	local C=clone_set(A)
	for a in A:each() do
		if B:include(a) then C:remove(a) end
	end
	return C
end

local cons=function(a,b)
	local t=type(a) == "table" and {unpack(a)} or {a}
	push(t,b)
	return rawset(t,"__ISPAIR",true)
end

local set_product=function(A,B)
	local C=create_set(A)
	for a in A:each() do
		for b in B:each() do
			C:insert(cons(a,b))
		end
	end
	return C
end

local set_pow=function(A,B)
	if type(B)~="table" then
		local n=math.floor(tonumber(B))
		assert(n>-1,"S^n where n<0 are not implemented yet!")
		if n==0 then return create_set(A,{}) end
		local S=clone_set(A)
		if n>1 then
			for i=2,n do				S=set_product(S,A)			end
		end
		return S
	else
		return set_product(A,B)
	end
end

local test_relation=function(S,r)
	for i,v in ipairs(r) do
		if S:include(v)  then			return true 		end
	end
	return false
end

local relation_set
relation_set=function(R,S,SUP)
	local R_rest=clone_set(R)
	for r in R:each() do
		if test_relation(S,r) then 
			R_rest:remove(r)
			for i,e in ipairs(r) do 
				if SUP:include(e) then S:insert(e) end
			end
			return relation_set(R_rest,S,SUP)
		end
	end
	return R_rest,S
end

local set_classify=function(A,R) -- to implement, where R is a relationship on set A
	if not R[1] then return end
	local subsets,subset,r={}
	local R=clone_set(R)
	while R[1] do
		r=R[1]
		subset=A:new()
		for i,e in ipairs(r) do 	-- fill subset with prop elements
			if A:include(e) then subset:insert(e) end
		end
		R:remove(r)
		R,subset=relation_set(R,subset,A)
		push(subsets,subset)
		A=A-subset
	end
	if A[1] then push(subsets,A) end
	return unpack(subsets)
end

local set_le=function(A,B)
	for a in A:each() do 
		if not B:include(a) then return false end
	end
	return true
end

local set_eq=function(A,B)
	return rawequal (A,B) or set_le(A,B) and set_le(B,A)
end

local set_lt=function(A,B)
	return #B>#A and set_le(A,B)
end

local generate_set=function(set,filter)
	local newset=create_set(set)
	for e in set:each() do
		if filter(e) then
			newset:insert(e)
		end
	end
	return newset
end

local set_mt=make_metatable{
	__add=set_union,
	__sub=set_sub,
	__div=set_classify,
	__mul=set_interaction,
	__pow=set_pow,
	__tostring=set2str,
	__eq=set_eq,
	__le=set_le,
	__lt=set_lt,
	new=create_set,
	clone=clone_set,
	generate=generate_set,
	include=set_include,
	insert=set_insert,
	each=set_each,
	remove=set_remove,
}

Set=setmetatable({},set_mt)


local relation=function(...)
	return rawset(arg,"__ISPAIR",true)
end

--~ local A=Set:new{1,2,3,4,5,6,7}
--~ local R=Set:new{relation(1,2),relation(2,2),relation(3,3),relation(1,4),}

--~ local B=A/R

--~ print("A","=",A)
--~ print("R","=",R)
--~ print("B","=",unpack(B))

--~ local A=Set:new{1,1,1,2,2,3,4,5}
--~ print("A=",A)

--~ B=A:generate(function(a)
--~ 	return a>3 and a<6
--~ end)
--~ print("B=",B)

--~ local C=A+B
--~ print("A+B=",C)

--~ local D=A-B
--~ print("A-B=",D)

--~ local E=A/B
--~ print("A/B=",E)

--~ local F=A*B*C
--~ print("A*B=",F)

--~ print(A==A)

--~ C=A-B
--~ C:print()
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
