--[[
--	fn.lua
--	File:/test.lua
--	Date:2022.08.13
--	By MIT License.
--	Copyright (c) 2022 Ziyao.All rights reserved.
]]

local fn = require("fn");

local cmpList = function(t1,t2)
	for i,v in ipairs(t1)
	do
		if t2[i] ~= v
		then
			return false;
		end
	end
	return true;
end

local testList = {};

local testFrameWork = function()
	local t = {1,2,3,4};
	assert(cmpList(t,t));
	assert(not cmpList(t,{}));
	assert(not cmpList(t,{2,3}));
	return;
end;
testList["test framework"] = testFrameWork;

testList["test list generating"] = function()
	local t = {2,4,6,8};
	local g = fn.range(function(idx) return idx << 1; end)
	assert(cmpList(g(1,1,4),t));
	return;
end;

testList["test list map"] = function()
	assert(cmpList(fn.map(fn.mul(2))(fn.range(nil,1,1,4)),
		       {2,4,6,8}));
	return;
end;

testList["test list reduce"] = function()
	assert(fn.reduce(fn.add,0)(fn.range(nil,1,1,100)) == 5050);
	return;
end;

testList["test list filter & pipe"] = function()
	assert(cmpList(fn.filter(fn.pipe({fn.mod(2),fn.equ(1),}))
				(fn.range(nil,1,1,100)),
		       fn.range(nil,2,1,100)));
	return;
end;

testList["test foreach & toString"] = function()
	local t = fn.range(nil,1,1,100);
	local res = "";
	fn.foreach(function(s) res = res .. s; return; end)
		  (t);
	return assert(res == fn.toString(t));
end;

testList["list head & last"] = function()
	local t = {1,2,3};
	assert(fn.head(t) + 1 == fn.last(t) - 1);
	return;
end;

for name,test in pairs(testList)
do
	io.write(name .. ":");
	io.flush();
	test();
	print((" "):rep(80 - 5 - #name) ..  "\27[32m[OK]\27[0m");
end

return 0;
