--[[
	fn
	File:/fn.lua
	Date:2022.03.04
	By MIT License.
	Copyright (c) 2022 Suote127.All rights reserved.
]]

local table	= require("table");

local unpack	= table.unpack;

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
fn.curry  = _curry2(_curry);


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

local _pipe = function(list)
	local f = {};
	local i = 1;
	local f = list[i];
	while this
	do
		f[i] = this;
		i = i + 1;
		this = list[i];
	end
	local count = i;
	return function(v)
			for i = count,1,-1
			do
				v = f[i](v);
			end
			return v;
		end;
end
fn.pipe = _curry1(_pipe);

local _head1 = function(list)
	return list[1];
end
fn.head1 = _curry1(_head1);

local _head = function(n,list)
	local res = {};
	for i = 1,n
	do
		res[i] = list[i];
	end
	return unpack(res);
end
fn.head = _curry2(_head);

local _tail1 = function(list)
	return list[#list];
end
fn.tail1 = _curry1(_tail1);

return fn;
