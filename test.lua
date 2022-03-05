--[[
	fn
	File:/test.lua
	Date:2022.03.05
	By MIT License.
	Copyright (c) 2022 Suote127.All rights reserved.
]]

local fn = require("fn");
local io = require("io");

do
	local nativePrint = print;
	print = function(l)
			if type(l) == "table"
			then
				if l[1]
				then
					for i,v in ipairs(l)
					do
						io.write(tostring(v) ..
							 "\t");
					end
					io.write("\n");
				else
					for k,v in pairs(l)
					do
						nativePrint(tostring(k) ..
							    "\t" ..
							    tostring(v));
					end
				end
			else
				nativePrint(l);
			end
			return;
		end
end

local l = {1,2,3,4,5,6};
print("fn.take()");
print(fn.take(2,l));
print("fn.head()");
print(fn.head(l));

local s = "Hello World!Hello Functional Programming!";
print("fn.singleChar()");
print(fn.singleChar(s));

print("fn.map(fn.sub(1))");
print(fn.map(fn.sub(1))(l));

print("fn.reduce(fn.add,0)");
print(fn.reduce(fn.add,0)(l));
