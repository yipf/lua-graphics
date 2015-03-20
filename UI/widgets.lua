
require 'iuplua'

local lower=string.lower
make_timer=function(title,time,cb)
	local timer=iup.timer{time=time,action_cb=cb,run='no'}
	local run
	local toggle=iup.toggle{title=title,value='off',expand='HORIZONTAL',
	action=function(o)
		run=lower(timer.run)
		timer.run= run=='no' and 'yes' or 'no'
		o.value= run=='no' and 'on' or 'off'
	end}
	return toggle,timer
end

make_button=function(title,cb)
	return iup.button{title=title,action=cb,expand='HORIZONTAL'}
end

local rawset,rawget,unpack=rawset,rawget,unpack

make_cfg_btn=function(title,cfg_str,cfg,f)
	local s
	local cb=function()
		s={iup.GetParam(rawget(cfg,1),nil,cfg_str,unpack(cfg,2))}
		if s[1] then 
			for i=2,#s do
				rawset(cfg,i,rawget(s,i))
			end
			if f then f(cfg) end
		end
	end
	return make_button(title,cb)
end

make_space=function(title)
	return iup.label{title=title,ALIGNMENT="ACENTER:ACENTER",expand='yes'}
end