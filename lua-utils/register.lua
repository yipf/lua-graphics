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

local obj2callid=function(o)
	local d,id=drawer_hooks(o.TYPE)
	if not d then print("Not valid drawer type:",o.TYPE) return end
	local static=not o.DYNAMIC
--~ 	if static then id= end -- start calllist
	d(o)
--~ 	if static then end --end calllist
	return static and id
end

calllist_table=make_register_table(obj2callid)

local obj2texid=function(o)
	local t,id=texture_hooks(o.TYPE)
	if not t then print("Not valid texture type:",o.TYPE) return end
	return t(o)
end

texture_table=make_register_table(obj2texid)