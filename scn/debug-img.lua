require "plugin/img2D"

local img=API.load_img("data/sss.png",4)
print(img.comp)

local block=get_editable_block(img)

local w,h=#block,#block[1]

print(block.width,block.height)

w=math.floor(w/2)
h=math.floor(h/2)

for i=w-10,w+10 do
	for j=h-10,h+10 do
		set_block_color(block,i,j,255,0,0,255)
	end
end

API.save_img(img,"data/sss-save.png")