require 'geo/utils'
local normalize,cross,tangent=normalize,cross,tangent

require 'lua-utils/obj'
local clone=copy

grid2mesh=function(grid,uclosed,vclosed) 	-- convert a point grid to a drawerable mesh
	local r,c=#grid,#grid[1]
	if r<2 or c<2 then return end
	local T
	-- generate normals
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
	-- set texture
	if uclosed then for i,v in ipairs(grid) do v[c+1]=clone(v[1]) end end
	if vclosed then grid[r+1]=clone(grid[1]) end
	r,c=#grid,#grid[1]
	local du,dv=1/(c-1),1/(r-1)
	for v,row in ipairs(grid) do
		for u,cell in ipairs(row) do
			cell.T={(u-1)*du,(v-1)*dv}
		end
	end
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


