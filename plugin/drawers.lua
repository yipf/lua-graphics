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
	local tp=API.QUAD_STRIP
	for i=1,r-1 do -- up to down
		r1,r2=mesh[i],mesh[i+1]
		API.begin_draw(tp)
		for j=1,c do
			set_point(r1[j])
			set_point(r2[j])
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

