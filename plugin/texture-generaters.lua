local f=function(o)
	local r,g,b,a=unpack(o)
	local tex=API.gen_mem_img(1,1)
	API.set_mem_img(tex,0,0,r or 255,g or 255,b or 255,a or 255)
	return mem_img2texture(tex)
end

texture_hooks("color",f)