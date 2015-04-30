require "lua-utils/register"

local make_static_draw_func=function(drawer)
	local id=calllist_table(drawer)
	return function(o)
		API.call_list(id)
	end
end

local init_obj_=function(o)
	local drawer,material=o.drawer,o.material
	if drawer and type(drawer)~="function" then o.drawer=make_static_draw_func(drawer) end
	return o
end

local material_hooks={
	['map_Kd']=function(v)
		API.apply_texture(texture_table(v))
	end,
}

local apply_material_=function(mtl)
	local hook
	for k,v in pairs(mtl) do
		hook=material_hooks[k]
		if hook then hook(v) end
	end
end

local draw_obj_pre_=function(o)
	local m,d,t=o.matrix,o.drawer,o.material
	if m then API.push_and_apply_matrix(m) end
	if t then  apply_material(t) end
	if d then d(o) end
	return o
end

local draw_obj_post_=function(o)
	if o.matrix then API.pop_matrix() end
	return o
end

init_obj, apply_material, draw_obj_pre, draw_obj_post = init_obj_,apply_material_, draw_obj_pre_, draw_obj_post_
