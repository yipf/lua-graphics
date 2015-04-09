local regular_value=function(v,vmax)
	while v<0 do v=v+vmax end
	return  v>vmax and vmax or v
end

get_editable_block=function(src,x,y,width,height)
	-- init effictive values
	local w,h=src.width, src.height
	x=x and regular_value(x,w) or 0
	y=y and regular_value(y,h) or 0
	width = width and regular_value(width,w-x) or w-x
	height = height and regular_value(height,h-y) or h-y
	-- gen_block
	local block={x=x,y=y,width=width,height=height,comp=src.comp}
	local row
	for j=1,height do
		row={}
		for i=1,width do
			row[i]=API.get_pixel(src,x+i-1,y+j-1)
		end
		block[j]=row
	end
	return block
end

local get_block_cell=function(block,x,y)
	local row=y and block[y]
	if row then return x and row[x] end
end

set_block_color=function(block,x,y,r,g,b,a)
	local cell=get_block_cell(block,x,y)
	if not cell then return end
	API.set_pixel(cell,block.comp,r,g,b,a);
	return block;
end

copy_block=function(src,dst)
	local c1,c2=src.comp,dst.comp
	local scell,dcell
	for y=1,#dst do
		for x=1,#dst[1] do
			scell,dcell=get_block_cell(src,x,y),get_block_cell(dst,x,y)
			if scell and dcell then
				API.copy_pixel(dcell,c2,scell,c1);
			end			
		end
	end
	return dst
end