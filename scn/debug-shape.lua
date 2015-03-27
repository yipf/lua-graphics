local dialog,split,frame,vbox,tabs=iup.dialog,iup.split,iup.frame,iup.vbox,iup.tabs

require 'UI/gl_canvas'

local API=API
local camera=API.create_camera()
camera=API.make_camera(camera,0,0,0,100)
camera=API.set_camera_projection(camera,1,1000,math.rad(60),1)
camera=API.update_camera(camera)

require 'geo/shapes'
require 'geo/transformers'

local rad=math.rad

local geo={"grid",rotate_obj(arc(rad(-90),rad(90),10),rad(0),rad(360),10,{1,1,1}),false,true}


local box={"box",1}

local T=API.make_translate(API.create_mat4x4(),1,0,0)


local m1=API.make_scale(API.create_mat4x4(),2,0.3,0.3)
m1=API.mult_matrix(m1,T,m1)

T=API.make_translate(T,0,1,0)
local m3=API.make_scale(API.create_mat4x4(),0.3,2,0.3)
m3=API.mult_matrix(m3,T,m3)

T=API.make_translate(T,0,0,1)
local m4=API.make_scale(API.create_mat4x4(),0.3,0.3,2)
m4=API.mult_matrix(m4,T,m4)

local m5=API.make_scale(API.create_mat4x4(),5,5,5)

local scn={
 config={"Config The Opengl Windows",0,1,0,"65 105 225",1,1,2,1,1,1,1},
  
  drawer={"plane",20},texture={"file","data/sss.png"},
  
--~   {drawer=geo,texture={"chess",4,{160,160,160},{224,224,224}}, matrix=m5},
    {drawer=box,texture={"color",{255,0,0}},matrix=m1}, --X
  {drawer=box,texture={"color",{0,255,0}},matrix=m3},  -- Y
  {drawer=box,texture={"color",{0,0,255}},matrix=m4},   --Z
}

local glw,gl_cfg=make_gl_canvas(scn,camera,800,800)
local gl_panel=frame{title="GL",glw}

-- main dialog

local about_str=[[
YIPF Copyright

2008-2013
]]




local tabs=tabs{ expand="yes",
 vbox{tabtitle="Operation",expand='yes',gl_cfg,toggle,laplacian_btn,load_bvh_org,load_bvh_track,load_bvh_track_static,load_bvh_track_interact,bvh_lst,bvh_lst_btn,make_space()},
 vbox{tabtitle="Option",expand='yes',cfg_btn,make_space()},
 vbox{tabtitle="About",expand='yes',make_space(about_str)},
}

local op_panel=frame{title="Operations",size="200x400",tabs,expand='yes'}

local dlg=dialog{title="my",iup.split{gl_panel,op_panel;orientation='verticle'}}

dlg:show()
 
if (not iup.MainLoopLevel or iup.MainLoopLevel()==0) then
  iup.MainLoop()
end

