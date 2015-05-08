local arg1,arg2=...

local inline,outline={},{}

require "geo/utils"
require "lua-utils/obj"

local rad,sin,cos,floor,mod=math.rad,math.sin,math.cos,math.floor,math.mod
local clone=copy

local angs=samples(math.rad(0),math.rad(300),5)

local push=table.insert

local gen_point=function(r,ang)
	return {r*cos(ang),r*sin(ang),1}
end

local r0,r1,r2,r=1,3,4
for i,v in ipairs(angs) do
	v=v+rad(10)
	push(inline,gen_point(r0,v))
	push(outline,gen_point(r2,v))
	v=v+rad(20)
	push(inline,gen_point(r0,v))
	push(outline,gen_point(r2,v))
	v=v+rad(10)
	push(inline,gen_point(r0,v))
	push(outline,gen_point(r1,v))
	v=v+rad(20)
	push(inline,gen_point(r0,v))
	push(outline,gen_point(r1,v))
end

local inline1,inline2=clone(inline),clone(inline)
local outline1,outline2=clone(outline),clone(outline)

for i,v in ipairs(inline1) do
	v[3]=1
end

for i,v in ipairs(inline2) do
	v[3]=-1
end

for i,v in ipairs(outline1) do
	v[3]=1
end

for i,v in ipairs(outline2) do
	v[3]=-1
end

return {
	{drawer={"grid",{clone(outline1),clone(inline1),uclosed=true}}},
	{drawer={"grid",{clone(inline2),clone(outline2),uclosed=true}}},
	{drawer={"grid",{clone(inline1),clone(inline2),uclosed=true}}},
	{drawer={"grid",{clone(outline2),clone(outline1),uclosed=true}}},
}
