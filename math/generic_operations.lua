local rawequal,ipairs,type=rawequal,ipairs,type
local push=table.insert

local generic_eq
generic_eq=function(a,b)
	local ta,tb=type(a),type(b)
	if ta~=tb then return false end
	if ta~='table' then return rawequal(a,b) end
	if #a~=#b then return false end
	for i,v in ipairs(a) do
		if not generic_eq(v,b[i]) then return false end
	end
	return true
end

local generic_lt
generic_lt=function(a,b)
	local ta,tb=type(a),type(b)
	if ta~=tb then return ta<tb end
	if ta~='table' then return a<b end
	local vb
	for i,v in ipairs(a) do
		vb=b[i]
		if vb and generic_lt(v,vb) then return true end
	end
	return false
end

local generic_alloc
generic_alloc=function(n,...)
	if n then
		local t={__SIZES={n,...}}
		for i=1,n do		t[i]=generic_alloc(...)		end
		return t
	end
	return 0
end

local generic_clone
generic_clone=function(src)
	if type(src)~='table' then return src end
	local dst={}
	for i,v in ipairs(src) do dst[i]=generic_clone(v) end
	return dst
end

local cons=function(a,b)
	if type(a)~='table' then return {a,b} end
	local c=generic_clone(a)
	push(c,b)
	return rawset(c,"__ISPAIR",true)
end

local generic_product
generic_product=function(a,b)
	local p={}
	local push=table.insert
	for i,va in ipairs(a) do
		for j,vb in ipairs(b) do
			push(p,cons(va,vb))
		end
	end
	return p
end

_generic_eq,_generic_lt,_generic_clone,_generic_alloc,_generic_product=generic_eq,generic_lt,generic_clone,generic_alloc,generic_product