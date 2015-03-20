-- an obj is general objs, including tables, numbers, strings, etc

local pairs,type,rawget,rawset=pairs,type,rawget,rawset
local push,concat,format=table.insert,table.concat,string.format

local copy_,obj2str_

copy_=function(src,dst)
	if type(src)~='table' then return src end
	dst={}
	for k,v in pairs(src) do
		rawset(dst,k,copy_(v))
	end
	return dst
end

obj2str_=function(o)
	local t=type(o)
	if t~='table' then return t=='string' and format("%q",o) or tostring(o) end
	local tt={}
	for k,v in pairs(o) do
		push(tt,format("[%s]=%s",obj2str_(k),obj2str_(v)))
	end
	return format("{%s}",concat(tt,","))
end

copy,obj2str=copy_,obj2str_


-- extend

local loadstring,assert=loadstring,assert

str2obj=function(str)
	str=format("return %s",str)
	str=assert(loadstring(str))
	return str and str()
end


-- test

--~ local t={4,3,4,{4,{2,"%d",222.0},c=4}}

--~ local str=obj2str_(t)

--~ local obj=str2obj(str)

--~ print(obj2str_(t))
--~ print(obj2str_(obj))

