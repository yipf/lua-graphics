local dialog,split,frame,vbox,tabs=iup.dialog,iup.split,iup.frame,iup.vbox,iup.tabs

require 'UI/gl_canvas'

local API=API
local camera=API.create_camera()
camera=API.make_camera(camera,0,0,0,10)
camera=API.set_camera_projection(camera,1,1000,45,1)

local glw,gl_cfg=make_gl_canvas({},camera,800,800)
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

