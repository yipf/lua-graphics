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

local mat_rot,rot_Y=API.create_mat4x4(),{0,1,0}
rotate_obj=function(path,s,e,n,rot)
	n=n or 1
	rot=rot and normalize(rot) or rot_Y
	local coord=mat_rot
	local grid={}
	local d,ang=(e-s)/n,s
	for i=1,n+1 do
		coord=API.make_rotate(coord,rot[1],rot[2],rot[3],ang)
		grid[i]=new_path(path,coord)
		ang=ang+d
	end
	return grid
end

local default_X,default_Y,default_Z={1,0,0},{0,1,0},{0,0,1}
local mat_path=API.create_mat4x4()
path_obj=function(curve,path)
	local grid={uclose=curve.close,vclose=path.close}
	local coord=mat_path
	local T=tangent(path)
	local N=tangent(T)
	local X,Y,Z
	for i,v in ipairs(path) do
		Z=T[i]
		Y=N[i]
		if zero(Z) then
			X=default_X;	Y=default_Y;	Z=default_Z;	
		else
			if eq(Z,Y) then Y=eq(Z,default_Y) and cross(Z,default_X) or default_Y end
			X=cross(Y,Z)
			Y=cross(Z,X)
			X=normalize(X);	Y=normalize(Y);	Z=normalize(Z);	
		end
		grid[i]=new_path(curve,build_coord_XYZT(X,Y,Z,v,coord))
	end
	return grid
end
