-- http://en.wikipedia.org/wiki/Non-uniform_rational_B-spline#Construction_of_the_basis_functions

local debug_fun=function(...)
	return string.format("%s(%s)",arg[1],table.concat(arg,",",2))
end

require "geo/utils"
local samples=samples

local f=function(u,i,n,us)
	local s=us[i+n]-us[i]
	return s==0 and 0 or (u-us[i])/s
end

local g=function(u,i,n,us)
	local s=us[i+n]-us[i]
	return s==0 and 0 or (us[i+n]-u)/s
end

local N
N=function(u,i,n,us)
	local m=#us
	if (i==1 and u==us[1]) or (i==m-n-1 and u==us[m]) then return 1 end -- special case 
	if n>0 then 
		return f(u,i,n,us)*N(u,i,n-1,us)+g(u,i+1,n,us)*N(u,i+1,n-1,us)
	end 
	return u>=us[i] and u<us[i+1] and 1 or 0
end

local sum_points_curve=function(P,R,u,p)
	local x,y,z,r=0,0,0
	for i,point in ipairs(P) do
		r=R(u,i,p)
		x=x+r*point[1]
		y=y+r*point[2]
		z=z+r*point[3]
	end
	return {x,y,z}
end

local sum_points_surface=function(P,R,u,v,up,vp)
	local x,y,z,r=0,0,0
	for i,row in ipairs(P) do
		for j,point in ipairs(row) do
			r=R(u,v,i,j,up,vp)
			x=x+r*point[1]
			y=y+r*point[2]
			z=z+r*point[3]
		end
	end
	return {x,y,z}
end

local make_R_curve=function(weights,knots)
	return function(u,i,p)
		local sum=0
		for j,w in ipairs(weights) do
			sum=w*N(u,j,p,knots)
		end
		return weights[i]*N(u,i,p,knots)/sum
	end
end

local make_R_surface=function(uv_weights,u_knots,v_knots)
	return function(u,v,i,j,m,n)
		local sum=0
		for p,row in ipairs(uv_weights) do
			for q,w in ipairs(row) do
				sum=sum+w*N(v,p,m,v_knots)*N(u,q,n,u_knots)
			end
		end
		return uv_weights[i][j]*N(v,i,m,v_knots)*N(u,j,n,u_knots)/sum
	end
end

local make_knots=function(n,p)
	local knots={}
	local push=table.insert
	local max=n-p
	for i=1,p+1 do push(knots,0) end
	for i=1,n-p-1 do push(knots,i/max) end
	for i=1,p+1 do push(knots,1) end
	return knots
end

local make_weights1D=function(n)
	local w=1/n
	return samples(w,w,n-1)
end

local make_weights_2D=function(m,n)
	local uw=1/n
	local uws=samples(uw,uw,n-1)
	local vw=1/m
	local vws=samples(vw,vw,m-1)
	local W,ws={}
	for v=1,m do
		ws={}
		for u=1,n do
			ws[u]=uws[u]*vws[v]
		end
		W[v]=ws
	end
	return W
end

local regular_poly=function(control_count)
	return math.min(control_count-1,3)
end

make_nurbs_curve=function(control_points,p,sep,weights,knots)
	local n=#control_points
	p=p or regular_poly(n)
	sep=sep or 10
	weights=weights or make_weights_1D(n)
	knots=knots or make_knots(n,p)
	local curve=samples(knots[1],knots[#knots],sep)
	local R=make_R_curve(weights,knots)
	for i,u in ipairs(curve) do
		curve[i]=sum_points_curve(control_points,R,u,p)
	end
	return curve
end

make_nurbs_surface=function(control_grid,up,vp,u_sep,v_sep,uv_weights,u_knots,v_knots)
	local m,n=#control_grid,#control_grid[1]
	up=up or regular_poly(m)
	vp=vp or regular_poly(n)
	u_sep=u_sep or 20
	v_sep=v_sep or 20
	uv_weights=uv_weights or make_weights_2D(m,n)
	v_knots=v_knots or make_knots(m,vp)
	u_knots=u_knots or make_knots(n,up)
	local R=make_R_surface(uv_weights,u_knots,v_knots)
	local grid=samples(v_knots[1],v_knots[#v_knots],v_sep)
	local us=samples(u_knots[1],u_knots[#u_knots],u_sep)
	local row
	for j,v in ipairs(grid) do
		row={}
		for i,u in ipairs(us) do
			row[i]=sum_points_surface(control_grid,R,u,v,up,vp)
		end
		grid[j]=row
	end
	return grid
end


