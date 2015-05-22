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
drawer_hooks("mesh",draw_mesh)

f=function(grid)
	return draw_mesh(grid2mesh(grid))
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

local draw_sphere=function(r,c,u,v,su,eu,sv,ev)
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
drawer_hooks("sphere",draw_sphere)

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
	local mesh=grid2mesh(grid)
	return draw_mesh(mesh)
end
drawer_hooks("NURBS",f)

require "plugin/models"

local combine=function(arr)
	local x,y,z=0,0,0
	for i,v in ipairs(arr) do
		x=x+v[1]
		y=y+v[2]
		z=z+v[3]
	end
	return normalize{x,y,z}
end

local append_normals=function(vids,V,n)
	assert(n>2)
	local v1,v2,v3=V[vids[1]],V[vids[2]],V[vids[3]]
	local normal=normalize(cross(sub(v2,v1),sub(v3,v2)))
	local target,normals
	local push=table.insert
	for i=1,n do
		target=V[vids[i]]
		normals=target.normals or {}
		push(normals,normal)
		target.normals=normals
	end
	return V
end

local compute_normal=function(obj)
	if obj.NORMAL_COMPLETE then return obj end
	local V=obj.V
	local key,value
	local vids={}
	for i,v in ipairs(obj) do
		key,value=unpack(v)
		if key=="face" then
			for i,vertice in ipairs(value) do
				vids[i]=vertice[1]
			end
			append_normals(vids,V,#value)
		end
	end
	for i,v in ipairs(V) do
		v.normal=combine(v.normals)
	end
	obj.NORMAL_COMPLETE=true
	return obj
end

local computer_texcoord=function(obj)
	if obj.TEXCOORD_COMPLETE then return obj end
	for i,v in ipairs(obj.V) do
		v.texcoord={0.5,0.5}
	end
	obj.TEXCOORD_COMPLETE=true
	return obj
end

f=function(filepath)
	local func=importers("obj")
	local obj=func(filepath)
	local key,value
	local V,T,N=obj.V,obj.T,obj.N
	local vid,tid,nid
	print("drawing",filepath)
	for i,v in ipairs(obj) do
		key,value=unpack(v)
		if key=="mtl" then 
--~ 			apply_material(value)
		elseif key=="face" then
			API.begin_draw(#value==4 and API.QUADS or API.TRIANGLE_STRIP)
			for ii,vertice in ipairs(value) do
				vid,tid,nid=unpack(vertice)
				vid=V[vid]
				if not tid then 
					computer_texcoord(obj) 
					tid=vid.texcoord
				else
					tid=T[tid]
				end
				if not nid then
					compute_normal(obj)
					nid=vid.normal
				else
					nid=N[nid]
				end
				API.set_vertex(vid[1],vid[2],vid[3],tid[1],tid[2],nid[1],nid[2],nid[3])
			end
			API.end_draw()
		end
	end
	print("end")
end
drawer_hooks("obj",f)

local draw_box=function(x,y,z,rx,ry,rz)
	x=x or 0
	y=y or 0
	z=z or 0
	rx=rx or 1
	ry=ry or rx
	rz=rz or ry
	API.begin_draw(API.QUADS)
	-- right
	API.set_vertex(x+rx,y+0,z+rz,		0,0,		1,0,0)
	API.set_vertex(x+rx,y+0,z+0,		0,1,		1,0,0)
	API.set_vertex(x+rx,y+ry,z+0,		1,1,		1,0,0)
	API.set_vertex(x+rx,y+ry,z+rz,		1,0,		1,0,0)
	-- left
	API.set_vertex(x+0,y+0,z+0,		0,0,		-1,0,0)
	API.set_vertex(x+0,y+0,z+rz,		0,1,		-1,0,0)
	API.set_vertex(x+0,y+ry,z+rz,		1,1,		-1,0,0)
	API.set_vertex(x+0,y+ry,z+0,		1,0,		-1,0,0)
	-- top
	API.set_vertex(x+0,y+ry,z+rz,		0,0,		0,1,0)
	API.set_vertex(x+rx,y+ry,z+rz,		0,1,		0,1,0)
	API.set_vertex(x+rx,y+ry,z+0,		1,1,		0,1,0)
	API.set_vertex(x+0,y+ry,z+0,		1,0,		0,1,0)
	-- bottom
	API.set_vertex(x+0,y+0,z+0,		0,0,		0,-1,0)
	API.set_vertex(x+rx,y+0,z+0,		0,1,		0,-1,00)
	API.set_vertex(x+rx,y+0,z+rz,		1,1,		0,-1,0)
	API.set_vertex(x+0,y+0,z+rz,		1,0,		0,-1,0)
		-- right
	API.set_vertex(x+0,y+0,z+rz,		0,0,		0,0,1)
	API.set_vertex(x+rx,y+0,z+rz,		0,1,		0,0,1)
	API.set_vertex(x+rx,y+ry,z+rz,		1,1,		0,0,1)
	API.set_vertex(x+0,y+ry,z+rz,		1,0,		0,0,1)
	-- left
	API.set_vertex(x+rx,y+0,z+0,		0,0,		0,0,-1)
	API.set_vertex(x+0,y+0,z+0,		0,1,		0,0,-1)
	API.set_vertex(x+0,y+ry,z+0,		1,1,		0,0,-1)
	API.set_vertex(x+rx,y+ry,z+0,		1,0,		0,0,-1)
	API.end_draw()
end

f=function(x,y,z,rx,ry,rz)
	return draw_box(x-rx/2,y-ry/2,z-rz/2,rx,ry,rz)
end
drawer_hooks("box-point",f)

f=function(x,y,z,r)
	return draw_sphere({x,y,z},r or 1)
end
drawer_hooks("sphere-point",f)

local format,tostring=string.format,tostring
local value2key=function(x,y,z)
	return format("%s,%s,%s",tostring(x),tostring(y),tostring(z))
end

local push=table.insert
local get=function(t,x,y,z)
	local k=value2key(x,y,z)
	local s=t[k]
	if not s then s={x=x,y=y,z=z};t[k]=s;push(t,s) end
	return s
end

local floor=math.floor
local append_box=function(boxs,x,y,z,r)
	local xid,yid,zid=floor(x/r),floor(y/r),floor(z/r)
	local target=get(boxs,xid,yid,zid)	
	push(target,{x,y,z})
end

f=function(filepath,r)
	r=r or 1
	local fhandle=io.open(filepath)
	local boxs={}
	if fhandle then
		local match=string.match
		for line in fhandle:lines() do
			x,y,z=match(line,"^%s*v%s+(%S+)%s+(%S+)%s+(%S+)%s*$")
			if x then
				append_box(boxs,tonumber(x),tonumber(y),tonumber(z),r)
			end
		end
		fhandle:close()
	else
		print("Invalid filepath:",filepath)
		return 
	end
	print(#boxs)
	for i,v in ipairs(boxs) do
		draw_box(v.x*r,v.y*r,v.z*r,r)
	end
end
drawer_hooks("point-cloud",f)

local get_vol=function(vol,...)
	local p,key=vol
	for i=1,#arg do
		key=arg[i]
		p=p[key]
		if not p then return end
	end
	return p
end
local make_volumn=function(range,sep)
	local rx,ry,rz=unpack(range or {1,1,1})
	ry=ry or rx;	rz=rz or ry;
	local sx,sy,sz=unpack(sep or {1,1,1})
	sy=sy or sx;	sz=sz or sy;
	local dx,dy,dz=rx/sx,ry/sy,rz/sz
	local vol,ys,zs={}
	for x=0,sx-1 do
		ys={}
		for y=0,sy-1 do
			zs={}
			for z=0,sz-1 do
				zs[z]={drawable=true}
			end
			ys[y]=zs
		end
		vol[x]=ys
	end
	return vol,rx,ry,rz,sx,sy,sz,dx,dy,dz
end
f=function(range,sep,base)
	local bx,by,bz=unpack(base or {0,0,0})
	local vol,rx,ry,rz,sx,sy,sz,dx,dy,dz=make_volumn(range,sep)
	local ys,zs,cell
	local random=math.random
	for x=0,sz-1 do
		ys=vol[x]
		for y=0,sy-1 do
			zs=ys[y]
			for z=0,sz-1 do
				cell=zs[z]
				if random()>0.5 then
--~ 					API.glColor(x/rx,y/ry,z/rz)
					draw_box(bx+x*dx,by+y*dy,bz+z*dz,dx,dy,dz)
				end
			end
		end
	end
end
drawer_hooks("volumn",f)


