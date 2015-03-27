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
	local n=sqrt(dot_(v,v))
	n= n>0 and 1/n or 0 
	return mul_(v,n)
end

add,sub,dot,cross,mul,normalize=add_,sub_,dot_,cross_,mul_,normalize_

-- extending functions

local tangent_=function(points,name,closed)
	name=name or "T"
	local n,p=#points
	if #points<2 then return end
	p=points[1]
	p[name]=sub_(points[2],closed and points[n] or p)
	if n>2 then
		for i=2,n-1 do
			p=points[i]
			p[name]=sub_(points[i+1],points[i-1])
		end
	end
	p=points[n]
	p[name]=sub_(closed and points[1] or p,points[n-1])
	return points
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

table2vector,vector2table,vector2vector=table2vector_,vector2table_,vector2vector_


