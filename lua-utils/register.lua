local make_register_table=function(kv_map)
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

local init_drawer_=function(drawer)
	if type(drawer[1])=='function' then return drawer end
	local f=drawer and drawer_hooks(drawer[1])
	if drawer and not f then 
		print("Not valid drawer type:",drawer[1]) 
		return 
	end
	drawer[1]=f
	return drawer
end

local pcall,unpack=pcall,unpack

local draw_direct_=function(d)
	pcall(unpack(d))
end

init_drawer,draw_direct=init_drawer_, draw_direct_

local obj2callid=function(o)
	if type(o[1])~='function'  then return end 	-- test drawer to know if it is drawable
	id=API.begin_gen_calllist()
	draw_direct(o)
	API.end_gen_calllist()
	return id
end

calllist_table=make_register_table(obj2callid)

local obj2texid=function(o)
	local f,id=texture_hooks(o[1])
	if not f then print("Not valid texture type:",o.TYPE) return end
	return f(unpack(o,2))
end

texture_table=make_register_table(obj2texid)