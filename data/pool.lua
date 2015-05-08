require 'plugin/drawers'

local cos,sin,rad=math.cos,math.sin,math.rad

local make_wave=function(speed)
	local grid,row={}
	local ang,seed=0,0
	for i,r in ipairs(samples(0,20,20)) do
		row={}
		for j,ang in ipairs(samples(rad(0),rad(360),30)) do
			row[j]={r*cos(ang),seed,r*sin(ang)}
		end
		grid[i]=row
	end
	local mesh=grid2mesh(grid)
	local f=drawer_hooks("mesh")
	local drawer=function()
		f(mesh)
	end
	speed=speed or 1
	local step,bound=rad(speed),rad(360)
	local gen_normal=gen_normal
	local actor=function()
		seed=seed+step
		while seed>bound do seed=seed-bound end
		local N,t1,t2
		local da=rad(360)/(#mesh-1)
		for r,row in ipairs(mesh) do
			for i,v in ipairs(row) do
				v[2]=sin(r-seed)/r*4
			end
		end
		gen_normal(mesh)
	end
	return drawer,actor
end

local wave_drawer,wave_actor=make_wave(5)


local r1,dr,height=15,5,5
local r2=r1+dr

local c1,c2={},{}

local n=30
local d=rad(360)/n
local a
for i=1,n do
	a=i*d
	c1[i]={cos(a)*r1,0,sin(a)*r1}
	c2[i]={cos(a)*r2,0,sin(a)*r2}
end

require "lua-utils/obj"
local clone=copy

local c12=clone(c1)
for i,v in ipairs(c12) do
	v[2]=height
end
local c22=clone(c2)
for i,v in ipairs(c22) do
	v[2]=height-1
end

return {
	{
	material={map_Kd={"file","/host/Files/DLU/luajit-img2d-3d/data/bigstone.jpg"}},
			{drawer={"grid",{clone(c22),clone(c2),uclosed=true}}},
		{drawer={"grid",{clone(c1),clone(c12),uclosed=true}}},
		{drawer={"grid",{clone(c12),clone(c22),uclosed=true}}},

--~ 		{drawer={"grid",{c2,c1,uclosed=true}}},
	},
	{drawer=wave_drawer,actor=wave_actor,material={map_Kd={"color",{0x6C,0xA6,0xCD}}}}
}