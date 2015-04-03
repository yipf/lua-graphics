local FMT="shaders/%s.shader"

local f=function(name)
	local str=string.format(FMT,name)
	local vert,frag=dofile(str)
	return API.build_shader(vert,frag)
end

shader_hooks("built-in",f)