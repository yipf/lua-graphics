--~ a tree is a table where values with string key are properties and number keys are children

local children=ipairs

local rawset,rawget,pairs,type,print=rawset,rawget,pairs,type,print

local do_tree_

do_tree_=function(tr,pre,post)
	if type(tr)~='table' then return tr end
	tr=pre and pre(tr) or tr
	for i,v in children(tr) do
		rawset(tr,i,do_tree_(v,pre,post))
	end
	return post and post(tr) or tr
end

do_tree=do_tree_

-- extend funtions

local eval_=function(l)
	if type(l)~='table' then return l end
	local s,r=pcall(unpack(l))
	return r
end

eval_tree=function(tr,f)
	return do_tree_(tr,nil,eval_)
end

-- test

--~ local t={print,4,3,4,{tonumber,{string.format,"%d",222.0}}}

--~ eval(t)
