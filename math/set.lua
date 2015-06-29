local floor=math.floor
local insert,remove=table.insert,table.remove
local type=type
local rawequal=rawequal
local format=string.format

table2set=function(t)
	table.sort(t,generic_lt)
	return t
end

local set_search
set_search=function(S,element,s,e)
	s,e=s or 1,e or #S
	if s==e then return s end
	local mid=floor((s+e)/2)
	local v=S[mid]
	if generic_eq(element,v) then return mid end
	if generic_lt(element,v) then 
		return set_search(S,element,s,mid) 
	else
		return set_search(S,element,mid+1,e) 
	end
end

local set2str
set2str=function(S,str)
	local tp=type(S)
	if tp=='table' then
		local t={}
		for i,v in ipairs(S) do	t[i]=set2str(v)		end
		str=format(S.__ISPAIR and "<%s>" or "{%s}",table.concat(t,","))
	else
		str=tostring(S)
		if tp=='string' then str=format("%q",str) end
	end
	return str
end

set_include=function(S,element)
	local pos=set_search(S,element)
	return generic_eq(element,S[pos]),pos
end

set_insert=function(S,element)
	local eq,pos=set_include(S,element)
	if not eq then
		insert(S,generic_lt(element,S[pos]) and pos or pos+1,element)
	end
	return S
end

set_union=function(A,B)
	local U={}
	for i,a in ipairs(A) do U[i]=a end
	for i,b in ipairs(B) do
		set_insert(U,b)
	end
	return U
end

set_sub=function(A,B)
	local U,a={}
	for i=1,#A do 
		a=A[i]
		if not set_include(B,a) then insert(U,a) end
	end
	return U
end

set_remove=function(S,element)
	local eq,pos=set_include(S,element)
	if eq then remove(S,pos) end
end

local S=table2set{1,2,3,4,5,6,0.5,20}

local A=table2set{1,2,3,4,5,6,7,8,9}

local C=set_union(S,A)

print("A+S=",set2str(C))
print("S-A=",set2str(set_sub(S,A)))
print("A-S=",set2str(set_sub(A,S)))

print(set2str(S))

set_insert(S,{1,2,3,__ISPAIR=true})
--~ set_insert(S,{2,3,4})

print(set2str(S))

--~ set_insert(S,100)
set_insert(S,{0.5,2,__ISPAIR=true})
print(set2str(S))

set_insert(S,0.5)
print(set2str(S))

set_remove(S,0.5)
print(set2str(S))