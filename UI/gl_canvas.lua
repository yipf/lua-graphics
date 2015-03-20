require 'iupluagl'

--- config btn
local CONFIG_STR=[[
Scene %t
Shadow: %b
Fog: %b
Alpha: %b
Background: %c
Light %t
API.glEnable: %b
x: %r
y: %r
z: %r
Draw %t
Cull Face: %b[no,yes]
Mode: %b[Line,Fill]
Shade: %b[Flat,Smooth]
]]
local apply_cfg=function(cfg)
	local s,fog,a,bg,l,x,y,z,cf,mode,shade=unpack(cfg,2)
	
end

require "lua-utils/tree"

local do_tree=do_tree

local draw_obj=function()
	
end

local draw_obj_pre=function(o)
	
end

local draw_obj_post=function(o)
	
end

local draw_obj_pre_alpha=function(o)
	
end

make_gl_canvas=function(scn,camera,w,h)
	local cfg=scn.config or {"Config The Opengl Windows",1,0,1,"65 105 225",1,1,2,1,1,1,1,1}
	local MakeCurrent,SwapBuffer,Update=iup.GLMakeCurrent,iup.GLSwapBuffers,iup.Update
	local isleft,ismiddle,isright,isshift=iup.isbutton1,iup.isbutton2,iup.isbutton3,iup.isshift
	local mouse_xy={0,0}
	local F1,UP,DOWN,LEFT,RIGHT,PGUP,PGDN=iup.K_F1,iup.K_UP,iup.K_DOWN,iup.K_LEFT,iup.K_RIGHT,iup.K_PGUP,iup.K_PGDN
	local glcanvas=iup.glcanvas{ buffer="DOUBLE", rastersize = w..'x'..h,
		map_cb=function(o)
			MakeCurrent(o)
			API.my_init()
			apply_cfg(cfg) 
		end,
		action=function(o)
			MakeCurrent(o)
			API.gl_clear_all()
			API.camera_look(camera)
			
--~ 			if alpha then
--~ 				API.glEnable('BLEND')
--~ 				BlendFunc('SRC_ALPHA','ONE_MINUS_SRC_ALPHA');
--~ 				do_tree(scn,draw_alpha2_pre,draw_post) -- draw objects with alpha properties
--~ 				Disable('BLEND')
--~ 			end
			SwapBuffer(o)
		end,
		resize_cb=function(o,w_,h_)
			MakeCurrent(o)
		end,
		-- mouse callbacks
		wheel_cb=function (o,delta,x,y,status)
			API.scale_camera(camera,delta<0 and 1.11 or 0.9)
			API.update_camera(camera)
			Update(o)
		end,
		motion_cb=function(o,x,y,status)
			if isleft(status) then -- if left bottun down
				local mx,my=unpack(mouse_xy)
				if mx then
					API.rotate_camera(camera,mx-x,y-my)
					API.update_camera(camera)
					Update(o)
				end
				mouse_xy[1],mouse_xy[2]=x,y
				return true
			end
			-- clear the mouse
			mouse_xy[1]=nil
		end,
		button_cb=function(o,but, pressed, x, y, status)-- mouse button
			if pressed==1 and click_func then
--~ 				local p,v=camera("xy2line",x/w,y/h,w/h)
--~ 				click_func(line2plane(p,v,{0,0,0},{0,1,0}),isright(status),isshift(status))
--~ 				Update(o)
				return true
			end
		end,
		-- key board callbacks
		keypress_cb=function (o,k,pressed)
			local step=0.02
			API.move_camera(camera,k==LEFT and step or k==RIGHT and -step or 0, k==UP and step or k==DOWN and -step or 0, k==PGUP and step or k==PGDN and -step or 0)
			API.update_camera(camera)
			Update(o)
		end,
	}
	return glcanvas,make_cfg_btn("Graphic Config",CONFIG_STR,cfg,apply_cfg)
end