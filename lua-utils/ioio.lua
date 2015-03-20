local open=io.open

local file2str_=function(path,str)
	local f=open(path,mode or "r")
	if f then 
		str=f:read("*a")
		f:close()
	end
	return str or string.format("Can't open file %q !",path)
end

local str2file_=function(str,path,append)
	local f=open(path,append and "a+" or "w")
	if f then 
		f:write(str)
		f:close()
	end
	return path
end

file2str,str2file=file2str_,str2file_

-- extend

local include_file_

local gsub=string.gsub

local make_include_func=function(pat)
	local f,str
	f=function(path)
		str=file2str_(path)
		return pat and (gsub(str,pat,f)) or str
	end
	return f
end

include_file=function(path,pat)
	local f=make_include_func(pat)
	return f and f(path)
end

--~ print(include_file("ioio.lua","%<%<(.-)%>%>"))


