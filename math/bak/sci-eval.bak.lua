local gsub,match=string.gsub,string.match
local push=table.insert
local type,tonumber=type,tonumber

local make_set_metatable=function(mt)
	mt.__index=mt
	return mt
end

local set_mt=make_set_metatable{
	
}








local register_value=function(value,context,prefix)
	prefix=prefix or "V"
	push(context,value)
	local key="V"..(#context)
	context[key]=value
	return key
end

local copy_context=function(dst,src)
	dst=dst or {}
	for k,v in pairs(src) do		dst[k]=v	end
	return dst
end

local str2table=function(str)
	local tbl={}
	local push=table.insert
	for w in string.gmatch(str..",","(.-)%,") do		push(tbl,w)	end
	return tbl
end

local make_exp_func=function(context,eval,func_processor,brace_processor,normal_processor)
	local gsub,match=string.gsub,string.match
	local push=table.insert
	local assert,type,tonumber=assert,type,tonumber
	local register_value,str2table=register_value,str2table
	context=context or {}
	if not eval then
		eval=function(str) -- str --> value
			str=gsub(str,"(%w+)(%b())",func_processor) 	-- process functions
			str=gsub(str,"(%b())",brace_processor) 	-- process braces
			-- process 
			local tbl=str2table(str)
			for i,v in ipairs(tbl) do
				while match(v,"[%+%-%/%*%^%%]") do 	v=gsub(v,"^%s*(%-?[%w%.]*)%s*([%+%-%/%*%^%%])%s*(%-?[%w%.]+)",normal_processor,1)	end
				tbl[i]=tonumber(v) or context[v]
			end
			return unpack(tbl)
		end
	end
	if not func_processor then
		local func
		func_processor=function(fname,args) -- str"fname(args)" --> key_str (where context[key_str]=value)
			args=args:sub(2,-2)
			func=context[fname]
			assert(func and type(func)=="function","Not a valid function name:  "..fname)
			value=func(eval(args))
			return register_value(value,context)
		end
	end
	if not brace_processor then
		brace_processor=function(str) -- str"(values)" --> key_str (where context[key_str]=values)
			str=str:sub(2,-2)
			return register_value(eval(str),context)
		end
	end
	if not normal_processor then
		local func,op1,op2
		normal_processor=function(a,op,b) -- str"a op b" --> key_str (where context[key_str]=values)
			func,op1,op2=context[op],tonumber(a) or context[a],tonumber(b) or context[b]
			assert(func and type(func)=="function","Not a valid function name:  "..op)
			assert(op2,"Not a valid operand:\t"..b)
			return register_value(func(op1,op2),context)
		end
	end
	return eval,context
end

local str2func=function(str,env)
	env=env or _G
	local f=loadstring(str)
	return setfenv(f,env)
end

local make_str2set_func=function(str,context)
	
end


make_str2func_func=function(context,pattern) 	-- convert a str 2 function
	context=context or {}
	local format,match=string.format,string.match
	local args,body,field
	return function(str)
		args,body,field=match(str..",","^%s*(.-)%s*%-%>%s*()")
	end
end

make_str2set_func=function(context,pattern)
	
end

--- test

eval,env=make_exp_func()

local basic_operators={
	['+']=function(a,b)		return a and a+b or b	end,
	['-']=function(a,b)	 		return a and a-b or -b end,
	['*']=function(a,b)		return a*b	end,
	['/']=function(a,b)		return a/b	end,
	['^']=function(a,b) return a^b end,
	
}

local context={
	a0=1,
	b=2,
	c=3,
	['+']=function(a,b)		return a and a+b or b	end,
	['-']=function(a,b)	 		return a and a-b or -b end,
	['*']=function(a,b)		return a*b	end,
	['/']=function(a,b)		return a/b	end,
}

copy_context(env,context)
copy_context(env,math)

local test_exp=function(str)
	print(str,"=",eval(str))
end

test_exp[[a0,b,c,-0.2*c*(a+b),sin(rad(45))]]

for i,v in ipairs(env) do
	print("V"..i,"=",v)
end


test_exp=function(str)
	local state,result=pcall(loadstring,"return "..str)
	if not state then print(result) return end
	result=setfenv(result,env)
	return print(str,"=",result())
end

test_exp[[a0,b,c,-0.2*c*(a0+b),sin(rad(45))]]

[[x -> x+2, x]]

[[  {x+2  |  x@N and x@(a,b] } ]]
