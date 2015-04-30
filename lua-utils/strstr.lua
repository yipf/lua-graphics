local push=table.insert

local f=function(o)
	return o
end

str2table=function(str,pat,map_f)
	local t={}
	pat=pat or "%S+"
	map_f=map_f or f
	for v in string.gmatch(str,pat) do
		v=map_f(v)
		push(t,v)
	end
	return t
end

path2DirNameExt=function(str)
	local dir,name,ext=string.match(str,"^(.-/*)([^/]*)%.(.-)$")
	return dir,name,ext
end
