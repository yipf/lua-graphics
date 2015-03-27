local unpack=unpack

local init_color=function(c)
	local r,g,b,a=unpack(c)
	r=r or 255
	g=g or 255
	b=b or 255
	a=a or 255
	c[1],c[2],c[3],c[4]=r,g,b,a
	return c
end

local f

f=function(c)
	local w,h=1,1
	c=init_color(c)
	local tex=API.gen_mem_img(w,h)
	for i=0,w-1 do
		for j=0,h-1 do
			API.set_mem_img_color(tex,i,j,unpack(c))
		end
	end
	return API.mem_img2texture(tex)
end

texture_hooks("color",f)

f=function(n,c1,c2)
	local w,h=n,n
	local tex=API.gen_mem_img(w,h)
	local mod=math.mod
	c1,c2=init_color(c1),init_color(c2)
	for i=0,w-1 do
		for j=0,h-1 do
			API.set_mem_img_color(tex,i,j,unpack( (mod(i+j,2)==0) and c1 or c2))
		end
	end
	return API.mem_img2texture(tex)
end

texture_hooks("chess",f)

f=function(filepath)
	return API.img2texture(filepath)
end

texture_hooks("file",f)