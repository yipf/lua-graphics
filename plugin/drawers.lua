-- basic geos

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

local draw_obj_pre=function(o)
	local m,t,d=o.matrix,o.texture,o.drawer
	if m then API.push_and_apply_matrix(m) end
	if t then API.push_and_apply_texture(texture_table(t)) end
	if d then 
		local f=drawer_hooks(d[1])
		if f then f(unpack(d,2)) end
	end
end

local draw_obj_post=function(o)
	if o.texture then API.pop_texture() end
	if o.matrix then API.pop_matrix() end
end

local draw_scn=function(scn)
	do_tree(scn,draw_obj_pre,draw_obj_post)
	return scn
end

drawer_hooks("scn",draw_scn)

f=function(filepath)
	print("Loading",filepath,"...")
	local state,scn=pcall(dofile,filepath)
	if state then
		print("Success!")
		draw_scn(scn)
	else
		print(scn) 	-- print error msg
	end
	return scn
end
drawer_hooks("scn-file",f)

