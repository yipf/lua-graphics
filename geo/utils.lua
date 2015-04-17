local push,pop=table.insert,table.remove

sqrt,unpack=math.sqrt,unpack

local add_=function(v1,v2,n)
	n=n or 3
	local v={}
	for i=1,n do		v[i]=v1[i]+v2[i]	end
	return n
end

local sub_=function(v1,v2,n)
	n=n or 3
	local v={}
	for i=1,n do		v[i]=v1[i]-v2[i]	end
	return v
end

local cross_=function(v1,v2)
	local x1,y1,z1=unpack(v1)
	local x2,y2,z2=unpack(v2)
	return {y1*z2-y2*z1,z1*x2-z2*x1,x1*y2-x2*y1}
end

local dot_=function(v1,v2,n)
	n=n or 3
	local sum=0
	for i=1,n do		sum=sum+v1[i]*v2[i]	end
	return sum
end

local mul_=function(v,s,n)
	n=n or 3
	local r={}
	for i=1,n do		r[i]=v[i]*s	end
	return r
end

local normalize_=function(v)
	local n=sqrt(dot_(v,v,3))
	n= n>0 and 1/n or 0 
	return mul_(v,n)
end

local eq_=function(v1,v2)
	local x1,y1,z1=unpack(v1)
	local x2,y2,z2=unpack(v2)
	local n
	if x1~=0 then		n=x2/x1		return n~=0 and y1*n==y2 and z1*n==z2	end
	if y1~=0 then		n=y2/y1		return n~=0 and x1*n==x2 and z1*n==z2	end
	if z1~=0 then		n=z2/z1		return n~=0 and x1*n==x2 and y1*n==y2	end
	return x2==0 and y2==0 and z2==0
end

local zero_=function(v)
	local x,y,z=unpack(v)
	return x*x+y*y+z*z==0
end

add,sub,dot,cross,mul,normalize,eq,zero=add_,sub_,dot_,cross_,mul_,normalize_,eq_,zero_

-- extending functions

local tangent_=function(points,closed)
	local t={}
	local n,p=#points
	if #points<2 then return end
	p=points[1]
	t[1]=sub_(points[2],closed and points[n] or p)
	if n>2 then
		for i=2,n-1 do
			t[i]=sub_(points[i+1],points[i-1])
		end
	end
	p=points[n]
	t[n]=sub_(closed and points[1] or p,points[n-1])
	return t
end


local transpose_=function(m)
	local tm={}
	local r,c=#m,#m[1]
	local tr
	for i=1,c do
		tr={}
		for j=1,r do tr[j]=m[j][i] end
		tm[i]=tr
	end
	return tm
end

tangent,transpose=tangent_,transpose_

local temp_vec=API.create_vec4(0,0,0)

local table2vector_=function(t,v)
	if not v then return API.create_vec4(t[1],t[2],t[3]) end
	v[0]=t[1]; 	v[1]=t[2]; 	v[2]=t[3];
	return v
end

local vector2table_=function(v,t)
	t=t or {}
	t[1]=v[0];	t[2]=v[1];	t[3]=v[2]
	return t
end

local vector2vector_=function(vec,coord)
	vec=table2vector_(vec,temp_vec)
	vec=API.apply_mat(coord,vec,vec)
	return vector2table_(vec)
end

local build_coord_XYZT_=function(X,Y,Z,T,coord)
	coord=coord or API.create_mat4x4()
	coord[0]=X[1]	coord[1]=X[2]	coord[2]=X[3]	coord[3]=0
	coord[4]=Y[1]	coord[5]=Y[2]	coord[6]=Y[3]	coord[7]=0
	coord[8]=Z[1]	coord[9]=Z[2]	coord[10]=Z[3]	coord[11]=0
	coord[12]=T[1]	coord[13]=T[2]	coord[14]=T[3]	coord[15]=1
	return coord
end


table2vector,vector2table,vector2vector,build_coord_XYZT=table2vector_,vector2table_,vector2vector_,build_coord_XYZT_

samples=function(s,e,n)
	n=n or 1
	local t={s}
	local d=(e-s)/n
	for i=1,n do
		t[i+1]=s+i*d
	end
	return t
end



