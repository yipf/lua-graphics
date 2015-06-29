--~ require "math/basic_types"

local gsub,match=string.gsub,string.match
local push=table.insert
local type,tonumber=type,tonumber

local id_func=function(v)
	return v
end

local make_iter_func=function(set,f)
	return function()
		for i,v in ipairs(set) do
			f(v)
		end
	end
end

local func_obj_mt={
	__call=function(fobj,...)
		local arglist,input=fobj.arglist,{...}
		local env=fobj.env
		for i,key in ipairs(arglist) do
			env[key]=input[i]
		end
		return fobj.exec()
	end
}
func_obj_mt.__index=func_obj_mt

local make_func_obj=function(env,args,body) 	-- generate function object via args and body
	local body="return "..body
	local f=loadstring(body)
	local arglist={}
	for arg in string.gmatch(args,"%w+") do
		push(arglist,arg)
	end
	return setmetatable({exec=setfenv(f,env),arglist=arglist,env=env,body=body},func_obj_mt)
end

local copy_kv=function(src,dst)
	dst=dst or {}
	for k,v in pairs(src) do
		dst[k]=v
	end
	return dst
end

local make_compute_env=function(env)
	env=env or copy_kv(math)
	local setfenv,loadstring=setfenv,loadstring
	local match,format=string.match,string.format
	local make_func=function(str)
		local state,result=pcall(loadstring,"return "..str)
		if not state then print(result) return end
		result=setfenv(result,env)
		return result
	end
	local eval=function(str)
		local f=make_func(str)
		return f and f()
	end
	-- convert a string to a function object
	local str2func=function(str)
		local args,body=match(str,"^%s*(.*%w.*)%s*%-%>%s*(.-)%s*$")
		if not args then print("Not a valid function string:",str) return end
		return make_func_obj(env,args,body)
	end
	-- convert a string to a set
	local replace_func=function(str)
		return (format("{%s,__ISPAIR=true}",str:sub(2,-2)))
	end
	local pair_parser=function(str,count) 	-- convert pairs( represetned by "<...>") to metasets
		str,count=gsub(str,"%b<>",replace_func)
		while count>0 do str,count=gsub(str,"%b<>",replace_func) end
		return str
	end
	local str2set=function(str)
		local body,condition=match(str,"^%s*%{%s*(.-)%s*|%s*(.-)%s*%}%s*$")
		if not body then return Set:new(eval(pair_parser(str))) end
		local args,sets={},{}
		local register_arg=function(arg,set)
			push(args,arg)
			push(sets,env[set])
			return ""
		end
		condition=gsub(condition,",*%s*(%w+)%s+in%s+(%w+)%s*,*",register_arg)
		condition=match(condition,"%S") and condition or "true"
		local vf,cf=make_func(pair_parser(body)),make_func(condition)
		local n,S=#sets
		local new_set=Set:new()
		if n==0 then -- no field
			new_set.test_func=cf
		elseif n==1 then 
			S=sets[1]
			local key=args[1]
			for i,v in ipairs(S) do
				env[key]=v
				if cf() then new_set:insert(vf()) end
			end
		else
			S=sets[1]
			for i=2,n do S=S^sets[i] end
			for i,p in ipairs(S) do
				for j,argname in ipairs(args) do
					env[argname]=p[j]
				end
				if cf() then new_set:insert(vf()) end
			end
		end
		return new_set
	end
	-- main eval function
	local generic_eval=function(str)
		for line in string.gmatch(str,"%C+") do
			local key,value=match(line,"^%s*(%w+)%s*%=%s*(.-)%s*$")
			if not key then 				key=line 				value=line 			end
			if match(value,"%-%>") then 	-- if current line represent a function
				value=str2func(value)
			elseif match(value,"^%s*%{.-%}%s*$") then 		-- if current line represent a set
				value=str2set(value)
			else  	-- otherwise, evel the string
				value=eval(value)
			end
			env[key]=value
			print(key,"=",value)
		end
	end
	local set_env=function(src)
		copy(src,env)
	end
	return generic_eval,set_env
end

local eval,set=make_compute_env(math)

eval[[
f= x,y -> x^y+2*sin(x)
f(2,3)
f(1,3)
A={1,3}
See={<1,2>,<1,2>}
B={x+2 | x in A}
A+B
A-B
A*B
A^B
A^0
A^1
A^2
D={ <a,b> | a<4 and b>2, a in A, b in B}
A/D
]]

