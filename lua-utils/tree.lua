--~ a tree is a table where values with string key are properties and number keys are children

local ipairs,type=ipairs,type

local do_tree_before
do_tree_before=function(tr,fun,get_child,tp_fun)
	if tp_fun(tr)~='table' then return tr end
	fun(tr)
	for i,v in get_child(tr) do
		do_tree_before(v,fun,get_child,tp_fun)
	end
	return tr
end

local do_tree_after
do_tree_after=function(tr,fun,get_child,tp_fun)
	if tp_fun(tr)~='table' then return tr end
	for i,v in get_child(tr) do
		do_tree_after(v,fun,get_child,tp_fun)
	end
	fun(tr)
	return tr
end

local do_tree_enclose
do_tree_enclose=function(tr,pre,post,get_child,tp_fun)
	if tp_fun(tr)~='table' then return tr end
	pre(tr)
	for i,v in get_child(tr) do
		do_tree_enclose(v,pre,post,get_child,tp_fun)
	end
	post(tr)
	return tr
end

do_tree=function(tr,pre,post)
	if (not pre) and (not post) then return tr end
	if not post then return do_tree_before(tr,pre,ipairs,type) end
	if not pre then return do_tree_after(tr,post,ipairs,type) end
	return do_tree_enclose(tr,pre,post,ipairs,type)
end

-- extend funtions

local eval_=function(l)
	if type(l)~='table' then return l end
	local s,r=pcall(unpack(l))
	return r
end

eval_tree=function(tr,f)
	return do_tree_after(tr,eval_,ipairs,type)
end

-- test

--~ local t={print,4,3,4,{tonumber,{string.format,"%d",222.0}}}

--~ eval(t)
