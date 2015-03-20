local f=function(o)
	API.draw_box(o[1] or 2)
end

drawer_hooks("box",f)