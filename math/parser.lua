local gsub,match=string.gsub,string.match
local push=table.insert
local type,tonumber=type,tonumber

local register=function(key,value,context)
	context=context or _G
	context[key]=value
	return context
end

local register_value=function(value,context)
	push(context,value)
	local key="V"..(#context)
	context[key]=value
	return key
end

make_func_processor=function(context)
	local func,vname,value
	return function(fname,args)
		args=args:sub(2,-2)
		func=context[fname]
		assert(func and type(func)=="function","Not a valid function name:  "..fname)
		value=func(eval_exp(args))
		return register_value(value,context)
	end
end

make_brace_processor=function(context)
	return function(str)
		str=str:sub(2,-2)
		return eval_exp(str)
	end
end

make_normal_processor=function(context)
	local func,op1,op2
	return function(a,op,b)
		print("normal",a,op,b)
		func,op1,op2=context[op],context[a] or tonumber(a),context[b] or tonumber(b)
		assert(func and type(func)=="function","Not a valid function name:  "..op)
		assert(op2,"Not a valid operand:\t"..b)
		return register_value(func(op1,op2),context)
	end
end

local str2table=function(str)
	local tbl={}
	local push=table.insert
	for w in string.gmatch(str..",","(.-)%,") do
		push(tbl,w)
	end
	return tbl
end

eval_exp=function(str,context)
	context=context or _G
	str=gsub(str,"(%w+)(%b())",make_func_processor(context)) 	-- process functions
	str=gsub(str,"(%b())",make_brace_processor(context)) 	-- process braces
	-- process 
	local func=make_normal_processor(context)
	local tbl=str2table(str)
	for i,v in ipairs(tbl) do
		while match(v,"[+-/*%^%%]") do v=gsub(v,"([%w%.]*)%s*([+-/*%^%%]+)%s*([%w%.]+)",func) end
		tbl[i]=tonumber(v) or context[v]
	end
	return unpack(tbl)
end

--- test

local context={
	a0=1,
	b=2,
	c=3,
	['+']=function(a,b)		return a+b	end,
	['-']=function(a,b)	a=a or 0;	return a-b	end,
	['*']=function(a,b)		return a*b	end,
	['/']=function(a,b)		return a/b	end,
}

local test_exp=function(str)
	print(str.."=",eval_exp(str,context))
end

test_exp[[a0,b,c,0.2]]

for i,v in ipairs(context) do
	print(i,v)
end

