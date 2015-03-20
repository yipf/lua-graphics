local C_define2const=function(str,ctype)
	ctype=ctype or "int"
	str=string.gsub(str,"#define%s+(%S+)%s+(%S+)","static const "..ctype.." %1=%2;")
	print(str)
	return str
end

local clean_function_define=function(str)
	str=string.gsub(str,"GLAPI%S*","")
	print(str)
	return str
end


local t={}

local f=function(str)
	local t={}
	for a,b,c in string.gmatch(str,"rawset%((m),(%d+),([^%)]*)%)") do
		print(a.."["..b.."]="..c..";")
	end
	print(table.concat(t,";")..";")
end

local str2table=function(str)
	local t={}
	for s in string.gmatch(str,"(.-)\n") do
		if string.match(s,"%S") then 	table.insert(t,s) end
	end
	return t
end

local t=str2table[[
TEXTURE_2D
LIGHTING
CULL_FACE
BLEND
]]

--~ for i,v in ipairs(t) do
--~ 	t[i]=v.."="..math.pow(2,i)
--~ 	print(string.format([[if(op&%s){glEnable(GL_%s);}else{ glDisable(GL_%s);}]],v,v,v))
--~ end
--~ print(table.concat(t,","))

local str=[[
POINTS 	单个顶点集
LINES 	多组双顶点线段
POLYGON 	单个简单填充凸多边形
TRAINGLES 	 多组独立填充三角形
QUADS 	多组独立填充四边形
LINE_STRIP 	不闭合折线
LINE_LOOP 	闭合折线
TRAINGLE_STRIP 	线型连续填充三角形串
TRAINGLE_FAN 	扇形连续填充三角形串
QUAD_STRIP
]]

for s in string.gmatch(str,"[A-Z_]+") do
	print(string.format("%s,",s))
end