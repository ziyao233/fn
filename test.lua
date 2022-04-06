--[[
	fn
	File:/test.lua
	Date:2022.03.09
	By MIT License.
	Copyright (c) 2022 Ziyao.All rights reserved.
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

local isOdd = fn.pipe({fn.equ(1),fn.mod(2)});
local isEven = fn.pipe({fn._not,isOdd});
print("fn.filter(isOdd)");
print(fn.filter(isOdd)(l));
print("fn.filter(isEven)");
print(fn.filter(isEven)(l));

local l1 = fn.copy(l);
local l2 = fn.range(function(x) return x; end,1,1,6);
local _cmp;
_cmp = function(l1,l2)
	if #l1 == 0
	then
		return true;
	end
	return l1[1] == l2[1] and _cmp(fn.tail(l1),fn.tail(l2));
end
print("_cmp(l1,l2)");
print(#l1 == #l2 and _cmp(l1,l2));
fn.foreach(io.write,l1);
