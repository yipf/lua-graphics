local box={"box",1}

local chess={"chess",10,{160,160,160},{224,224,224}}

local T=API.make_translate(API.create_mat4x4(),1,0,0)

local m1=API.make_scale(API.create_mat4x4(),2,0.3,0.3)
m1=API.mult_matrix(m1,T,m1)

T=API.make_translate(T,0,1,0)
local m3=API.make_scale(API.create_mat4x4(),0.3,2,0.3)
m3=API.mult_matrix(m3,T,m3)

T=API.make_translate(T,0,0,1)
local m4=API.make_scale(API.create_mat4x4(),0.3,0.3,2)
m4=API.mult_matrix(m4,T,m4)

return {
 {drawer={"plane",30},texture=chess},
 {drawer=box,texture={"color",{255,0,0}},matrix=m1}, --X
  {drawer=box,texture={"color",{0,255,0}},matrix=m3},  -- Y
  {drawer=box,texture={"color",{0,0,255}},matrix=m4},   --Z
}