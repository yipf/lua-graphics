require 'geo/utils'

local table2vector,vector2table,vector2vector=table2vector,vector2table,vector2vector

local push,pop=table.insert,table.remove

local new_path=function(path,coord)
	local p={}
	for i,v in ipairs(path) do
		p[i]=vector2vector(v,coord)
	end
	return p
end

local mat,rot_Y=API.create_mat4x4(),{0,1,0}
rotate_obj=function(path,s,e,n,rot)
	n=n or 1
	rot=rot and normalize(rot) or rot_Y
	local coord=mat
	local grid={}
	local d,ang=(e-s)/n,s
	for i=1,n+1 do
		coord=API.make_rotate(coord,rot[1],rot[2],rot[3],ang)
		grid[i]=new_path(path,coord)
		ang=ang+d
	end
	return grid
end