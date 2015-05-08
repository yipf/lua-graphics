require 'geo/utils'
local normalize,cross,tangent=normalize,cross,tangent

require 'lua-utils/obj'
local clone=copy

gen_normal=function(grid)
	local r,c=#grid,#grid[1]
	local uclosed,vclosed=grid.uclosed,grid.vclosed
	if r<2 or c<2 then return end
	local T
	for i,row in ipairs(grid) do
		T=tangent(row,uclosed)
		for j,cell in ipairs(row) do cell.U=T[j] end
	end
	local tg=transpose(grid)
	for i,col in ipairs(tg) do
		T=tangent(col,vclosed)
		for j,cell in ipairs(col) do cell.V=T[j] end
	end
	for i,row in ipairs(grid) do
		for i,cell in ipairs(row) do
			cell.N=normalize(cross(cell.U,cell.V))
		end
	end
	return grid
end

gen_texcoord=function(grid)
	local r,c=#grid,#grid[1]
	local uclosed,vclosed=grid.uclosed,grid.vclosed
	local du,dv=1/(c-1),1/(r-1)
	for v,row in ipairs(grid) do
		for u,cell in ipairs(row) do
			cell.T={(u-1)*du,(v-1)*dv}
		end
	end
	return grid
end

local copy=function(src,dst)
	dst=dst or {}
	for k,v in pairs(src) do
		dst[k]=v	
	end
	return dst
end

grid2mesh=function(grid) 	-- convert a point grid to a drawerable mesh
	local uclosed,vclosed=grid.uclosed,grid.vclosed
	local r,c=#grid,#grid[1]
	gen_normal(grid)
	if uclosed then for i,v in ipairs(grid) do v[c+1]=copy(v[1]) end end
	if vclosed then grid[r+1]=copy(grid[1]) end
	gen_texcoord(grid)
	return grid
end

arc=function(s,e,n)
	local path={}
	n=n or 1
	local sin,cos=math.sin,math.cos
	local d,ang=(e-s)/n,s
	for i=1,n+1 do
		path[i]={cos(ang),sin(ang),0}
		ang=ang+d
	end
	return path
end


