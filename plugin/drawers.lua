-- basic geos

require "lua-utils/register"

local f=function(r)
	API.draw_box(r or 2)
end
drawer_hooks("box",f)

f=function(r)
	API.draw_plane(r or 2)
end
drawer_hooks("plane",f)

-- extend functions
require 'geo/utils'
require 'geo/shapes'

local unpack=unpack
local set_point=function(cell)
	local x,y,z=unpack(cell)
	local tx,ty=unpack(cell.T)
	local nx,ny,nz=unpack(cell.N)
	API.set_vertex(x,y,z,tx,ty,nx,ny,nz)
end

local draw_mesh=function(mesh)
	local r,c=#mesh,#mesh[1]
	local r1,r2
	local tp=API.TRIANGLE_STRIP
	for i=1,r-1 do -- up to down
		r1,r2=mesh[i],mesh[i+1]
		API.begin_draw(tp)
		for j=1,c do
			set_point(r2[j])
			set_point(r1[j])
		end
		API.end_draw()
	end
	return mesh
end
drawer_hooks("mesh",f)

f=function(grid,uclosed,vclosed)
	return draw_mesh(grid2mesh(grid,uclosed,vclosed))
end
drawer_hooks("grid",f)

local direct_draw=direct_draw

require "render/render_funcs"

local draw_obj_pre_=function(o)
	local m,d,t=o.matrix,o.drawer,o.material
	if m then API.push_and_apply_matrix(m) end
	if t then  apply_material(t) end
	if d then direct_draw(d) end
	return o
end

local draw_obj_post_=function(o)
	if o.matrix then API.pop_matrix() end
	return o
end

local draw_scn=function(scn)
	do_tree(scn,draw_obj_pre_,draw_obj_post_)
	return scn
end

drawer_hooks("scn",draw_scn)

f=function(filepath)
	print("Loading",filepath,"...")
	local state,scn=pcall(dofile,filepath)
	if state then
		draw_scn(scn)
		print("Success!")
	else
		print(scn) 	-- print error msg
	end
	return scn
end
drawer_hooks("scn-file",f)

f=function(r,c,u,v,su,eu,sv,ev)
 	local sin,cos,rad=math.sin,math.cos,math.rad
	u,v=u or 20,v or 10
	c=c or {0,0,0}
	r=r or 1
	su,eu=su or 0,eu or rad(360)
	sv,ev=sv or rad(-90),ev or rad(90)
	local push=table.insert
	local us=samples(su,eu,u)
	local vs=samples(sv,ev,v)
	local du,dv=1/u,1/v
	local x,y,z=unpack(c)
	local dx,dy,dz
	local mesh={}
	for i,va in ipairs(vs) do
		r={}
		for j,ua in ipairs(us) do
			dx,dy,dz=cos(va)*cos(ua),sin(va),-cos(va)*sin(ua)
			r[j]={x+dx,y+dy,z+dz,N={dx,dy,dz},T={(j-1)*du,(i-1)*dv}}
		end
		mesh[i]=r
	end
	return draw_mesh(mesh)
end
drawer_hooks("sphere",f)

local stick_coord
f=function(from,to,r,n)
	local v=sub(to,from)
	local length=math.sqrt(dot(v,v))
	v=normalize(v)
	local Z,X,Y=v,{1,0,0}
	if eq(Z,X) then X={0,0,Z[1]>0 and -1 or 1} end
	Y=cross(Z,X)
	X=cross(Y,Z)
	stick_coord=build_coord_XYZT(normalize(X),normalize(Y),Z,from,stick_coord)
	local sin,cos,rad=math.sin,math.cos,math.rad
	r=r or 1
	n=n or 10
	local angs=samples(0,rad(360),n)
	local x,y,u,dx,dy
	API.push_and_apply_matrix(stick_coord)
	API.begin_draw(API.TRIANGLE_STRIP)
	for i,ang in ipairs(angs) do
		dx,dy=cos(ang),sin(ang)
		x,y,u=r*dx,r*dy,(i-1)/n
		API.set_vertex(x,y,length,u,1,dx,dy,0)
		API.set_vertex(x,y,0,u,0,dx,dy,0)
	end
	API.end_draw()
	API.pop_matrix()
end
drawer_hooks("stick",f)

require "plugin/nurbs"

f=function(control_grid,u_knots,v_knots)
	local grid=make_nurbs_surface(control_grid)
	print("NURBS:",#grid,#grid[1])
--~ 	for i,row in ipairs(grid) do
--~ 		for j,v in ipairs(row) do
--~ 			print(i,j,":",unpack(v))
--~ 		end
--~ 	end
	local mesh=grid2mesh(grid)
	return draw_mesh(mesh)
end
drawer_hooks("NURBS",f)

require "plugin/models"

f=function(control_grid,u_sep,v_sep,uv_weights,up,vp,u_knots,v_knots)
	local grid=make_nurbs_surface(control_grid,u_sep,v_sep,uv_weights,up,vp,u_knots,v_knots)
	print("NURBS:",#grid,#grid[1])
--~ 	for i,row in ipairs(grid) do
--~ 		for j,v in ipairs(row) do
--~ 			print(i,j,":",unpack(v))
--~ 		end
--~ 	end
	local mesh=grid2mesh(grid)
	return draw_mesh(mesh)
end
drawer_hooks("NURBS",f)

