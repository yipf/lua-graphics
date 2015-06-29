------------------------------------------------------------------------------------------
-- scn
------------------------------------------------------------------------------------------

require 'geo/shapes'
require 'geo/transformers'



local rad,sin,cos=math.rad,math.sin,math.cos

local geo1={"grid",rotate_obj(arc(rad(-90),rad(90),10),rad(0),rad(-360),10,{0,1,0}),false,true}

local path={}
local ang
for i=1,72 do
	ang=rad(i*10)
	path[i]={cos(ang)*3,i*0.3,sin(ang)*3}
end

local geo2={"grid",path_obj(arc(rad(0),rad(9*36),9),path),true,false}

local chess={"chess",4,{160,160,160},{224,224,224}}

local T=API.make_translate(T,3,0,0)
local m5=API.make_scale(API.create_mat4x4(),1.5,1.5,1.5)
m5=API.mult_matrix(T,m5,m5)

T=API.make_translate(T,0,0,3)
m6=API.mult_matrix(T,m5,API.create_mat4x4())

T=API.make_translate(T,0,3,0)
m7=API.mult_matrix(T,m5,API.create_mat4x4())


T=API.make_translate(T,0,10,10)

local rot1=API.make_rotate(API.create_mat4x4(),0,1,0,math.rad(1))
local rot2=API.make_rotate(API.create_mat4x4(),1,0,0,math.rad(5))
local rot3=API.make_rotate(API.create_mat4x4(),0,0,1,math.rad(5))
local rot31=API.make_rotate(API.create_mat4x4(),0,0,1,math.rad(-5))


local path={}

for ang=math.rad(0),math.rad(330),math.rad(30) do
	table.insert(path,{3+math.cos(ang),math.sin(ang),0})
end

local geo={"grid",rotate_obj(path,rad(0),rad(340),17,{0,1,0}),true,true}


local wheel={"scn-file","/host/Files/DLU/luajit-img2d-3d/data/wheels.lua"}

--~ local wheel=dofile"/host/Files/DLU/luajit-img2d-3d/data/wheels.lua"

local sphere={"sphere",5,nil,nil,nil,0,math.rad(180),-math.rad(30),math.rad(30)}

local grid={}

local s=5

for i=1,5 do
	row={}
	for j=1,5 do
		row[j]={(j-1)*s,2*math.mod(i+j,2)*s,(1-i)*s}
	end
	grid[i]=row
end

local surface={"NURBS",grid,10,10}
local surface1={"grid",grid}

local stick={"stick",{-10,5,10},{10,5,-10}}

local node=dofile

local obj_matrix=API.make_scale(API.create_mat4x4(),10,10,10)
obj_matrix[12]=0
obj_matrix[13]=5
obj_matrix[14]=0


local scn={
 config={"Config The Opengl Windows",0,1,0,"65 105 225",1,20,40,20,1,1,1},
  
  light_shader={"built-in","spot-light&shadow"},
  
  drawer={"scn-file","./data/base_scn.lua"},

--~ {drawer={"obj","data/cow.obj"},matrix=obj_matrix,material={map_Kd={"color",{0xFF,0xFF,0xFF}}}},
{
--~ drawer={"obj","/home/yipf/Downloads/host/Files/lua-platform/data/dragon.obj"},
--~ drawer={"box",10},
--~ drawer={"point-cloud","/host/Files/lua-platform/data/rabbit.obj",0.015},
drawer={"volumn",{2,1,2},{20,10,20},{-1,0.1,-1}},


matrix=obj_matrix,material={map_Kd={"color",{255,215,0}}},actor=function(o)
	  local m=o.matrix
	  API.mult_matrix(rot1,m,m)
	  end
	  },

--~ {drawer={"obj","/host/Files/lua-platform/data/horse.obj"}},
}

------------------------------------------------------------------------------------------
-- UI
------------------------------------------------------------------------------------------

local dialog,split,frame,vbox,tabs=iup.dialog,iup.split,iup.frame,iup.vbox,iup.tabs

require 'UI/gl_canvas'

local API=API
local camera=API.create_camera()
camera=API.make_camera(camera,0,0,0,100)
camera=API.set_camera_projection(camera,1,1000,math.rad(60),1)
camera=API.update_camera(camera)

local glw,gl_cfg=make_gl_canvas(scn,camera,800,800)
local gl_panel=frame{title="GL",glw}

action=function(o)
	local f=o.actor
	if f then f(o) end
end

local Update=iup.Update
local timer_toggle,timer=make_timer("timer",30,function()
    do_tree(scn,action)
	Update(glw)
end)

-- main dialog

local about_str=[[
YIPF Copyright

2008-2013
]]




local tabs=tabs{ expand="yes",
 vbox{tabtitle="Operation",expand='yes',gl_cfg,timer_toggle,make_space()},
 vbox{tabtitle="Option",expand='yes',cfg_btn,make_space()},
 vbox{tabtitle="About",expand='yes',make_space(about_str)},
}

local op_panel=frame{title="Operations",size="200x400",tabs,expand='yes'}

local dlg=dialog{title="my",iup.split{gl_panel,op_panel;orientation='verticle'}}

dlg:show()
 
if (not iup.MainLoopLevel or iup.MainLoopLevel()==0) then
  iup.MainLoop()
end

