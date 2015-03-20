
require "3D/config"


require 'iupluagl'

require '3D/config'

local CONFIG_STR=[[
Scene %t
Shadow: %b
Fog: %b
Alpha: %b
Background: %c
Light %t
Enable: %b
x: %r
y: %r
z: %r
Draw %t
Cull Face: %b[no,yes]
Mode: %b[Line,Fill]
Shade: %b[Flat,Smooth]
]]

local rawget,rawset,unpack=rawget,rawset,unpack

local MATRIX_STR,DRAWER_STR,TEXTURE_STR,DRAWER_ID_STR,TEXTURE_ID_STR,DYNAMIC_STR="matrix","drawer","texture","CALL_ID","TEXTURE_ID","dynamic"

require "3D/draw"
local draw_ids,draw=draw_ids,draw

require "3D/texture"
local texture_ids=texture_ids

local LoadMatrix,MultMatrix,PushMatrix,PopMatrix,BindTexture,CallList=gl.LoadMatrix,gl.MultMatrix,gl.PushMatrix,gl.PopMatrix,gl.BindTexture,gl.CallList

local draw_obj=function(obj)
	local t,d,id=rawget(obj,TEXTURE_STR),rawget(obj,DRAWER_STR)
	-- texture
	if t then 
		id=rawget(obj,TEXTURE_ID_STR)
		if not id then 
			id=texture_ids(t)
			if id then rawset(obj,TEXTURE_ID_STR,id) end
		end
		if id then BindTexture('TEXTURE_2D',id) end
	end
	-- drawers
	if d then
		PushMatrix()
		if rawget(obj,DYNAMIC_STR) then -- when dynamic is decleared, d is not a string
			draw(d)
		else
			id=rawget(obj,DRAWER_ID_STR)
			if not id then 
				id=draw_ids(d)
				if id then rawset(obj,DRAWER_ID_STR,id) end
			end
			if id then CallList(id) end
		end
		PopMatrix()
	end
end

local draw_shadow_pre=function(obj)
	PushMatrix()
	local m=obj.matrix
	if m then MultMatrix(m) end
	if not obj.NOSHADOW then draw_obj(obj) end
end

local draw_alpha1_pre=function(obj)
	PushMatrix()
	local m=obj.matrix
	if m then MultMatrix(m) end
	if not obj.ALPHA then draw_obj(obj) end
end

local draw_alpha2_pre=function(obj)
	PushMatrix()
	local m=obj.matrix
	if m then MultMatrix(m) end
	if obj.ALPHA then draw_obj(obj) end
end

local draw_pre=function(obj)
	PushMatrix()
	local m=obj.matrix
	if m then MultMatrix(m) end
	draw_obj(obj)
end

local draw_post=function(obj)
	PopMatrix()
end

require "UI/widgets"
local make_cfg_btn=make_cfg_btn

require "tree"
local do_tree=do_tree

require '3D/matrix'
local make_project=make_project

require 'strstr'
local str2array=str2array

local Enable,Disable,Light,LightModel,Color,PolygonMode,ShadeModel,ClearColor,Viewport,Clear,MatrixMode,LoadIdentity,Fog,PushAttrib,PopAttrib,BlendFunc=gl.Enable,gl.Disable,gl.Light,gl.LightModel,gl.Color,gl.PolygonMode,gl.ShadeModel,gl.ClearColor,gl.Viewport,gl.Clear,gl.MatrixMode,gl.LoadIdentity,gl.Fog,gl.PushAttrib,gl.PopAttrib,gl.BlendFunc

local MakeCurrent,SwapBuffer,Update=iup.GLMakeCurrent,iup.GLSwapBuffers,iup.Update

local push,pop=table.insert,table.remove

require "3D/cross"

make_gl_canvas=function(scn,camera,w,h)
	scn=scn or {}
	camera=camera or {}
	w=w or 800
	h=h or 600
	local click_func=scn.CLICK_FUNC
	local shadow_matrix,shadow,alpha=make_project({},-1,-1,-1,0)
	-- config button binding to this canvas
	local cfg=scn.config or {"Config The Opengl Windows",1,0,1,"65 105 225",1,1,2,1,1,1,1,1}
	local c={0,0,0,1}
	local tonumber=tonumber
	local str2color=function(str)
		return tonumber(str)/255
	end
	local apply=function(cfg) 
		local s,fog,a,bg,l,x,y,z,cf,mode,shade=unpack(cfg,2)
		if l==1 then 
			Enable('LIGHTING') 
			Enable('LIGHT0')
			MatrixMode('MODELVIEW')
			LoadIdentity()
  			Light('LIGHT0', 'POSITION',{x,y,z,0})
			LightModel('LIGHT_MODEL_TWO_SIDE',-1)
		else 
			Disable('LIGHTING')
			Color(1,1,1,1)
		end
		c=str2array(bg,"%S+",str2color,c,1)
		ClearColor(unpack(c))
		shadow= l==1 and s==1 
		shadow_matrix=make_project(shadow_matrix,-x,-y,-z,0)
		alpha = a==1
		if cf==1 then Enable('CULL_FACE') else Disable('CULL_FACE') end
  		if mode==1 then PolygonMode('FRONT_AND_BACK','FILL') else  PolygonMode('FRONT_AND_BACK','LINE') end
  		if shade==1 then ShadeModel('FRONT_AND_BACK','SMOOTH') else ShadeModel('FRONT_AND_BACK','FLAT') end
		if fog==1 then
			Fog('FOG_MODE','LINEAR')
			Fog('FOG_COLOR',c)
			Fog('FOG_DENSITY',0.05)
			Fog('FOG_HINT','FASTEST')
			Fog('FOG_START',10.0)
			Fog('FOG_END',100.0)
			Enable('FOG')
		else
			Disable('FOG')
		end
	end
	local cfg_btn=make_cfg_btn("Graphic Config",CONFIG_STR,cfg,apply)
	-- the main canvas
	local isleft,ismiddle,isright,isshift=iup.isbutton1,iup.isbutton2,iup.isbutton3,iup.isshift
	local mouse_xy={0,0}
	local F1,UP,DOWN,LEFT,RIGHT,PGUP,PGDN=iup.K_F1,iup.K_UP,iup.K_DOWN,iup.K_LEFT,iup.K_RIGHT,iup.K_PGUP,iup.K_PGDN
	local glcanvas=iup.glcanvas{ buffer="DOUBLE", rastersize = w..'x'..h,
		map_cb=function(o)
			MakeCurrent(o)
			gl.ClearDepth(1.0)                 -- Depth Buffer Setup
			gl.Enable('DEPTH_TEST')            -- Enables Depth Testing
			gl.DepthFunc('LEQUAL')             -- The Type Of Depth Testing To Do
			gl.Hint('PERSPECTIVE_CORRECTION_HINT','NICEST')
			Enable('TEXTURE_2D')
			Enable('LIGHTING')
			Enable('NORMALIZE')
			gl.AlphaFunc('GREATER',0.1) 
			apply(cfg) 
		end,
		action=function(o)
			MakeCurrent(o)
			Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
			MatrixMode('PROJECTION')
			LoadIdentity()
			camera()
			MatrixMode('MODELVIEW')
			LoadIdentity()
			do_tree(scn,alpha and draw_alpha1_pre or draw_pre,draw_post) -- draw objects without alpha properties
			if shadow then
				PushMatrix()
				LoadMatrix(shadow_matrix)
				PushAttrib('ENABLE_BIT')
				Disable('TEXTURE_2D')
				Disable('LIGHTING')
				Disable('CULL_FACE')
				Color(0.2,0.2,0.2,1)
				for i,v in ipairs(scn) do
					do_tree(v,draw_shadow_pre,draw_post)
				end
--~ 				Enable('LIGHTING')
--~ 				Enable('TEXTURE_2D')
--~ 				Enable('CULL_FACE')
				PopAttrib('ENABLE_BIT')
				PopMatrix()
			end
			if alpha then
				Enable('BLEND')
				BlendFunc('SRC_ALPHA','ONE_MINUS_SRC_ALPHA');
				do_tree(scn,draw_alpha2_pre,draw_post) -- draw objects with alpha properties
				Disable('BLEND')
			end
			SwapBuffer(o)
		end,
		resize_cb=function(o,w_,h_)
			MakeCurrent(o)
			w,h=w_,h_
			Viewport(0, 0, w, h)
			camera('rate',w/h)
		end,
		-- mouse callbacks
		wheel_cb=function (o,delta,x,y,status)
			camera("scale",delta<0 and 1.11 or 0.9)
			Update(o)
		end,
		motion_cb=function(o,x,y,status)
			if isleft(status) then -- if left bottun down
				local mx,my=unpack(mouse_xy)
				if mx then
					camera("rotate",mx-x,y-my)
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
				local p,v=camera("xy2line",x/w,y/h,w/h)
				click_func(line2plane(p,v,{0,0,0},{0,1,0}),isright(status),isshift(status))
				Update(o)
				return true
			end
		end,
		-- key board callbacks
		keypress_cb=function (o,k,pressed)
			local step=0.02
			if k == F1 then
			elseif k==UP then
				camera("front",step)
			elseif k==DOWN then
				camera("front",-step)
			elseif k==LEFT then
				camera("left",step)
			elseif k==RIGHT then
				camera("left",-step)
			elseif k==PGUP then
				camera("up",step)
			elseif k==PGDN then
				camera("up",-step)
			end
			Update(o)
		end,
	}
	return glcanvas,cfg_btn
end

local direct_draw_pre=function(obj)
	local m,t,d,id=obj.matrix,obj.texture,obj.drawer
	PushMatrix()
	if m then 	-- matrix
		MultMatrix(m)
	end
	if t then 	-- texture
		id=texture_ids(t)
		if id then BindTexture('TEXTURE_2D',id) end
	end
	if d then  -- draw
		draw(d)
	end
end

draw_object_group=function(group)
	return do_tree(group,direct_draw_pre,draw_post)
end
