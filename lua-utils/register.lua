make_register_table=function(kv_map)
	local t={}
	return function(key,value)
		if not key then return t end
		if value then
			t[key]=value
		else
			value=t[key]
			if (not value) and kv_map then 
				value=kv_map(key)
				t[key]=value 
			end
		end
		return value
	end
end

drawer_hooks=make_register_table()
texture_hooks=make_register_table()
shader_hooks=make_register_table()

local pcall,unpack=pcall,unpack

local direct_draw_=function(d)
	local key=d[1]
	local hook=drawer_hooks(key)
	if hook then 
		pcall(hook,unpack(d,2))
	else
		print("No drawer defined for type:",key)
	end
end

local obj2callid=function(o)
	id=API.begin_gen_calllist()
	direct_draw_(o)
	API.end_gen_calllist()
	return id
end

direct_draw=direct_draw_

calllist_table=make_register_table(obj2callid)

local obj2texid=function(o)
	local f,id=texture_hooks(o[1])
	if not f then print("Not valid texture type:",o[1]) return end
	return f(unpack(o,2))
end

texture_table=make_register_table(obj2texid)

local shader2shaderid=function(o)
	local f,id=shader_hooks(o[1])
	if not f then print("Not valid shader type:",o[1]) return end
	return f(unpack(o,2))
end

shader_table=make_register_table(shader2shaderid)
