local gsub,match=string.gsub,string.match
local push=table.insert
local type,tonumber=type,tonumber

local register_value=function(value,context)
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

--- test

eval,env=make_exp_func()

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

local test_exp=function(str)
	print(str,"=",eval(str))
end

test_exp[[a0,b,c,-0.2*c*(a+b)]]

for i,v in ipairs(env) do
	print("V"..i,"=",v)
end

