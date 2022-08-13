--[[
--	fn
--	File:/fn.lua
--	Date:2022.08.13
--	By MIT License.
--	Copyright (c) 2022 Ziyao.All rights reserved.
]]

local table	= require("table");
local string	= require("string");

local unpack	= table.unpack;
local sub	= string.sub;

local fn = {};

--[[
	Copy from Lamda v0.2.0
	https://github.com/moriyalb/lamda
	(c) 2017 MoriyaLB

]]

local _isPlaceholder = function(a)
	return a ~= nil and type(a) == 'table' and a['@@functional/placeholder'];
end;

local _pack = function(...)
	return {...};
end;

local _curry1 = function(fn)
	local f1;
	f1 = function(...)
		local args = {...};
		if #args == 0 or _isPlaceholder(args[1]) then
			return f1;
		else
			return fn(unpack(args));
		end
	end
	return f1;
end

local _curry2 = function(fn)
	local f2;
	f2 = function(...)
		local args = {...}
		if #args == 0 then
			return f2;
		elseif #args == 1 then
			return _isPlaceholder(args[1]) and f2 or _curry1(function(...)
				return fn(args[1], ...);
			end)
		else
			return (_isPlaceholder(args[1]) and _isPlaceholder(args[2])) and f2 or (_isPlaceholder(args[1]) and _curry1(function (_a, ...);
			 	return fn(_a, args[2], ...);
			end) or (_isPlaceholder(args[2]) and _curry1(function (...)
				return fn(args[1], ...);
			end) or fn(...)));
		end
	end
	return f2;
end;

local _curry3 = function(fn)
	local f3;
	f3 = function(...)
		local args = {...};
		local a, b, c = unpack(args);
		if #args == 0 then
			return f3;
		elseif #args == 1 then
			return _isPlaceholder(a) and f3 or _curry2(function (...)
				return fn(a, ...);
			end)
		elseif #args == 2 then
			return (_isPlaceholder(a) and _isPlaceholder(b)) and f3 or (_isPlaceholder(a) and _curry2(function (_a, ...)
				return fn(_a, b, ...);
			end) or (_isPlaceholder(b) and _curry2(function (...)
				return fn(a, ...);
			end) or _curry1(function (...)
				return fn(a, b, ...)
			end)));
		else
			if _isPlaceholder(a) and _isPlaceholder(b) and _isPlaceholder(c) then
				return f3;
			elseif _isPlaceholder(a) and _isPlaceholder(b) then
				return _curry2(function (_a, _b, ...)
					return fn(_a, _b, c, ...)
				end);
			elseif _isPlaceholder(a) and _isPlaceholder(c) then
				return  _curry2(function (_a, ...)
					return fn(_a, b, ...)
				end);
			elseif _isPlaceholder(b) and _isPlaceholder(c) then
				return  _curry2(function (...)
					return fn(a, ...) end);
			elseif _isPlaceholder(a)  then
				return _curry1(function (_a, ...)
					return fn(_a, b, c, ...)
				end);
			elseif _isPlaceholder(b) then
				return _curry1(function (_b, ...)
					return fn(a, _b, c, ...)
				end);
			elseif _isPlaceholder(c) then
				return _curry1(function (...)
					return fn(a, b, ...)
				end);
			else
				return fn(...);
			end
		end
	end
	return f3;
end;

local _curry;
_curry = function(length, received, fn)
	return function(...)
		local args = {...};
		local argsIdx = 1;
		local combined = {};
		local left = length;
		local combinedIdx = 1;

		while combinedIdx <= #received or argsIdx <= #args do
			local result;
			if (combinedIdx <= #received and (not _isPlaceholder(received[combinedIdx]) or argsIdx >= #args)) then
				result = received[combinedIdx];
			else
				result = args[argsIdx];
				argsIdx = argsIdx + 1;
			end
			combined[combinedIdx] = result;
			if not _isPlaceholder(result) then
				left = left - 1;
			end
			combinedIdx = combinedIdx + 1;
		end
		return left <= 0 and fn(unpack(combined)) or _curry(length, combined, fn);
	end
end;

--[[
	End of the copied code
]]

fn.curry1 = _curry1;
fn.curry2 = _curry2;
fn.curry3 = _curry3;
fn.curry  = _curry2(function(n,f)
			if n == 1
			then
				return _curry1(f);
			end
			return _curry(n,{},f);
		    end);


local _map = function(f,list)
	local i = 1;
	local res = {};
	local this = list[1];
	while this ~= nil
	do
		res[i] = f(this);
		i = i + 1;
		this = list[i];
	end

	return res;
end;
fn.map = _curry2(_map);

local _reduce = function(f,init,list)
	local i = 1;
	local this = list[1];
	while this ~= nil
	do
		init = f(init,this);
		i = i + 1;
		this = list[i];
	end

	return init;
end;
fn.reduce = _curry3(_reduce);

local _filter = function(cond,list)
	local i,count = 1,1;
	local this = list[1];
	local res = {};

	while this ~= nil
	do
		if cond(this)
		then
			res[count] = this;
			count = count + 1;
		end
		i = i + 1;
		this = list[i];
	end

	return res;
end;
fn.filter = _curry2(_filter);

local _foreach = function(f,list)
	local i = 1;
	local this = list[i];

	while this ~= nil
	do
		f(this);
		i = i + 1;
		this = list[i];
	end

	return i - 1;
end;
fn.foreach = _curry2(_foreach);

local _pipe = function(list)
	local f = {};
	local i = 1;
	local this = list[i];
	while this
	do
		f[i] = this;
		i = i + 1;
		this = list[i];
	end
	local count = i - 1;
	return function(v)
			for i = 1,count
			do
				v = f[i](v);
			end
			return v;
		end;
end;
fn.pipe = _curry1(_pipe);

local _head = function(list)
	return list[1];
end;
fn.head = _curry1(_head);

local _last = function(list)
	return list[#list];
end;
fn.last = _curry1(_last);

local _tail = function(list)
	local res = {};
	local i = 2;
	local this = list[i];

	while this
	do
		res[i - 1] = this;
		i = i + 1;
		this = list[i];
	end

	return res;
end;
fn.tail = _curry1(_tail);

local _take = function(n,list)
	local res = {};

	for i = 1,n
	do
		res[i] = list[i];
	end

	return res;
end;
fn.take = _curry2(_take);

local _len = function(s)
	return #s;
end;
fn.len = _curry1(_len);

local _toTable = function(s)
	local len = #s;
	local res = {};

	for i = 1,len
	do
		res[i] = sub(s,i,i);
	end

	return res;
end;
fn.toTable= _curry1(_toTable);

local _idx = function(key,obj)
	return obj[key];
end;
fn.idx = _curry2(_idx);

local _copy = function(obj)
	if type(obj) == "table"
	then
		local res = {};
		for k,v in pairs(obj)
		do
			res[k] = v;
		end
		obj = res;
	end
	return obj;
end
fn.copy = _curry1(_copy);

local _range = function(gen,step,a,b)
	gen = gen or function(v) return v; end;
	local res = {};
	local count = 1;
	step = step or 1;
	a = a or 1;

	for i = a,b,step
	do
		res[count] = gen(i);
		count = count + 1;
	end

	return res;
end
fn.range = _curry(4,{},_range);

local _toString = function(v)
	local t = type(v);
	if t == "table"
	then
		return table.concat(v);
	else
		return tostring(v);
	end
end;
fn.toString = _curry1(_toString);

fn.add = _curry2(function(a,b) return a + b; end);
fn.sub = _curry2(function(a,b) return b - a; end);
fn.mul = _curry2(function(a,b) return a * b; end);
fn.div = _curry2(function(a,b) return b / a; end);
fn.mod = _curry2(function(a,b) return b % a; end);
fn.idiv = _curry2(function(a,b) return b // a; end);

fn.bitAnd = _curry2(function(a,b) return a & b; end);
fn.bitOr = _curry2(function(a,b) return a | b; end);
fn.bitNot = _curry2(function(a) return ~a; end);
fn.bitXor = _curry2(function(a,b) return a ~ b; end);

fn.gt = _curry2(function(a,b) return b > a; end);
fn.lt = _curry2(function(a,b) return b < a; end);
fn.equ = _curry2(function(a,b) return a == b; end);
fn.ge = _curry2(function(a,b) return b >= a; end);
fn.le = _curry2(function(a,b) return b <= a; end);
fn.strictEqu = _curry2(function(a,b)
			return a == b and
			       type(a) == type(b);
		       end);
fn._and = _curry2(function(a,b) return a and b; end);
fn._or = _curry2(function(a,b) return a or b; end);
fn._not = _curry1(function(a) return not a; end);

fn.type = _curry1(type);
fn.toInteger = _curry1(math.tointeger);

return fn;
