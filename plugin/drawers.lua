local f=function(r)
	API.draw_box(r or 2)
end

drawer_hooks("box",f)

local f=function(r)
	API.draw_plane(r or 2)
end

drawer_hooks("plane",f)