#!/usr/bin/env lua

--[[
-- 字符串测试
function fact (n)
	if n == 0 then
		return 1
	else
		return n * fact(n-1)
	end
end
print("enter a number:")
a = io.read("*number")
print(fact(a))
--]]




--[[
-- list 测试
a = {}
for i=-5,5 do
	a[i] = 0
end
print(#a)
for i=10,15 do
	a[i] = '000'
end

for k,v in ipairs(a) do
	print(k,v)
end
--]]




--[[
-- repeat测试
function repeat_test()
	i = 1
	a = {23,345,456,234,121}
	repeat
		-- local i =0
		print(a[i])
		if i>=3 then
			-- break -- return、break要放块末尾
			print(i)
		end
		i = i + 1
		print(i)
	until i>=5
end
repeat_test()
--]]




--[[
-- dofile测试
function dofile(filename)
	-- local f = loadfile(filename)
	local f = assert(loadfile(filename))
	print('f>>>>', f)
	return f()
end
dofile('test.lua')
--]]




--[[
-- 字符串测试
function string_test ()
	line = ' caogen qjx sd  sdh '
	print(line)
	pos = 1
	while line do
		s,e = string.find(line, '%w+', pos)
		if s then
			print(string.sub(line, s, e))
			pos = e + 1
		else
			break
		end
	end
	print(s,e)
	print(line)
end
string_test()
--]]




--[[
-- 协程测试
function coroutine_test()
	local co
	co = coroutine.create(
		function ()
			for i=0, 5 do
				print('>>>>> hi, ' .. i)
				coroutine.yield(coroutine.status(co))
				print(i)
			end
		end
	)
	print(co, coroutine.status(co))
	repeat
		ret, v = coroutine.resume(co)
		print(ret, v)
	until ret == false
	print(co, coroutine.status(co))
end
coroutine_test()
--]]

--[[
-- 协程数据交换测试
function coroutine_test()
	co = coroutine.create (function (a,b)
			print(a, b)
			a,b = coroutine.yield(1,2)
			print("co", a, b)
			return 10, 11
		end)
	print(coroutine.status(co),'>>>',coroutine.resume(co, 3, 4))
	print(coroutine.status(co),'>>>',coroutine.resume(co, 5, 6))
	print(coroutine.status(co),'>>>',coroutine.resume(co, 7, 8))
end
coroutine_test()
--]]

--[==[
-- 协程 非抢占式多线程示例
function coroutine_test()
	require "socket"
	function download (host, file)
		local c = assert(socket.connect(host, 80))
		local count = 0 -- counts number of bytes read
		c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
		while true do
			local s, status, partial = receive(c)
			count = count + #(s or partial)
			if status == "closed" then break end
		end
		c:close()
		print(file, count)
	end

	function receive (connection)
		connection:settimeout(0) -- do not block
		local s, status, partial = connection:receive(2^10)
		if status == "timeout" then
			coroutine.yield(connection)
		end
		return s or partial, status
	end

	threads = {}
	function get (host, file)
		local co = coroutine.create(
			function ()
				download(host, file)
			end
		)
		table.insert(threads, co)
	end

	function dispatch ()
		print("fffff")
		local i = 1
		while true do
			if threads[i] == nil then -- no more threads?
				if threads[1] == nil then break end -- list is empty?
				i = 1 -- restart the loop
			end
			local status, res = coroutine.resume(threads[i])
			if not res then -- thread finished its task?
				table.remove(threads, i)
			else
				i = i + 1
			end
		end
	end

	function dispatch ()
		local i = 1
		local connections = {}
		while true do
			if threads[i] == nil then -- no more threads?
				if threads[1] == nil then break end
				i = 1 -- restart the loop
				connections = {}
			end
			local status, res = coroutine.resume(threads[i])
			if not res then -- thread finished its task?
				table.remove(threads, i)
			else -- time out
				i = i + 1
				connections[#connections + 1] = res
				if #connections == #threads then -- all threads blocked?
					socket.select(connections)
				end
			end
		end
	end

	host = "www.w3.org"
	-- get(host, "/TR/html401/html40.txt")
	-- get(host, "/TR/2002/REC-xhtml1-20020801/xhtml1.pdf")
	get(host, "/TR/REC-html32.html")
	get(host, "/TR/2000/REC-DOM-Level-2-Core-20001113/DOM2-Core.txt")
	dispatch() -- main loop
end
coroutine_test()
--]==]




--[[
-- 马尔科夫链    注意：line = io.read() 回车 line=''（空字符串）
function Markov ()
	function allwords ()
		local line = io.read() -- current line
		local pos = 1 -- current position in the line
		return function () -- iterator function
			while line do -- repeat while there are lines
				local s, e = string.find(line, "%w+", pos)
				if s then -- found a word?
					pos = e + 1 -- update next position
					word = string.sub(line, s, e) -- return the word
					print(word)
					return word
				else
					print(22222)
					line = io.read() -- word not found; try next line
					pos = 1 -- restart from first position
					-- if line == '\0' then print("hahaha") end
					print(type(line))
					print(string.byte(line,1))
					print(#line)
					if #line == 0 then
						break
					end
				end
			end
			return nil -- no more lines: end of traversal
		end
	end

	function prefix (w1, w2)
		return w1 .. " " .. w2
	end

	local statetab = {}
	function insert (index, value)
		local list = statetab[index]
		if list == nil then
			statetab[index] = {value}
		else
			list[#list + 1] = value
		end
	end

	local N = 2
	local MAXGEN = 10000
	local NOWORD = "\n"
	-- build table
	local w1, w2 = NOWORD, NOWORD
	for w in allwords() do
		insert(prefix(w1, w2), w)
		w1 = w2; w2 = w;
	end
	insert(prefix(w1, w2), NOWORD)
	-- generate text
	w1 = NOWORD; w2 = NOWORD -- reinitialize
	for i=1, MAXGEN do
		local list = statetab[prefix(w1, w2)]
		-- choose a random item from list
		local r = math.random(#list)
		local nextword = list[r]
		if nextword == NOWORD then return end
		io.write(nextword, " ")
		w1 = w2; w2 = nextword
	end
end
Markov()
--]]




--[[
-- 图
function graph_test ()
	function name2node (graph, name)
		if not graph[name] then
			-- node does not exist; create a new one
			graph[name] = {name = name, adj = {}}
		end
		return graph[name]
	end

	function readgraph ()
		local graph = {}
		for line in io.lines() do
			-- split line in two names
			local namefrom, nameto = string.match(line, "(%S+)%s+(%S+)")
			if not namefrom or not nameto then break end
			-- find corresponding nodes
			local from = name2node(graph, namefrom)
			local to = name2node(graph, nameto)
			-- adds ’to’ to the adjacent set of ’from’
			from.adj[to] = true
		end
		return graph
	end

	function findpath (curr, to, path, visited)
		path = path or {}
		visited = visited or {}
		if visited[curr] then -- node already visited?
			return nil -- no path here
		end
		visited[curr] = true -- mark node as visited
		path[#path + 1] = curr -- add it to path
		if curr == to then -- final node?
			return path
		end
		-- try all adjacent nodes
		for node in pairs(curr.adj) do
			local p = findpath(node, to, path, visited)
			if p then return p end
		end
		path[#path] = nil -- remove node from path
	end

	function printpath (path)
		for i=1, #path do
			print(path[i].name)
		end
	end

	g = readgraph() -- a d > d c > c b      a f > f b > b g
	a = name2node(g, "a")
	b = name2node(g, "b")
	p = findpath(a, b)
	if p then printpath(p) end
end
--graph_test()
--]]




--[[
--用【【】】字符串系列化
function quote_test (s)
	function quote (s)
		-- find maximum length of sequences of equal signs
		local n = -1
		for w in string.gmatch(s, "]=*]") do
			n = math.max(n, #w - 2) -- -2 to remove the ']'s
		end
		-- produce a string with 'n' plus one equal signs
		local eq = string.rep("=", n + 1)
		-- build quoted string
		return string.format(" [%s[\n%s]%s] ", eq, s, eq)
	end
	ss = '\nweww"caogen"\n ]===]ffff "html;xml"'
	print(quote(ss))
end
quote_test()
--]]

--[[
-- 系列化
function serialize_test ()
	function basicSerialize (o)
		if type(o) == "number" then
			return tostring(o)
		else -- assume it is a string
			return string.format("%q", o)
		end
	end

	function save (name, value, saved)
		saved = saved or {} -- initial value
		io.write(name, " = ")
		if type(value) == "number" or type(value) == "string" then
			io.write(basicSerialize(value), "\n")
		elseif type(value) == "table" then
			if saved[value] then -- value already saved?
				io.write(saved[value], "\n") -- use its previous name
			else
				saved[value] = name -- save name for next time
				io.write("{}\n") -- create a new table
				for k,v in pairs(value) do -- save its fields
					k = basicSerialize(k)
					local fname = string.format("%s[%s]", name, k)
					save(fname, v, saved)
				end
			end
		else
			error("cannot save a " .. type(value))
		end
	end

	a = {x=1, y=2; {3,4,5}}
	a[2] = a -- cycle
	a.z = a[1] -- shared subtable
	save('a', a)

	io.write('=============\n')
	a = {{"one", "two"}, 3}
	b = {k = a[1]}
	save('a', a)
	save('b', b)
	io.write('=====\n')
	local t = {}
	save('a', a, t)
	save('b', b, t)
end
serialize_test()
--]]



--[[
-- 元表测试
function meta_test ()
	local Set = {}
	local mt = {}

	-- create a new set with the values of a given list
	function Set.new (l)
		local set = {}
		setmetatable(set, mt)
		for _, v in ipairs(l) do set[v] = true end
		return set
	end
	-- 并
	function Set.union (a, b)
		local res = Set.new{}
		for k in pairs(a) do res[k] = true end
		for k in pairs(b) do res[k] = true end
		return res
	end
	-- 交
	function Set.inter (a, b)
		local res = Set.new{}
		for k in pairs(a) do
			res[k] = b[k]
		end
		return res
	end
	-- 差
	function Set.differ (a, b)
		local res = Set.new{}
		for k in pairs(a) do
			-- res[k] = if b[k] then nil else a[k] end
			res[k] = not b[k] and a[k] or nil
		end
		return res
	end
	-- presents a set as a string
	function Set.tostring (set)
		local l = {} -- list to put all elements from the set
		for e in pairs(set) do
			l[#l + 1] = e
		end
		return "{" .. table.concat(l, ", ") .. "}"
	end
	-- print a set
	function Set.print (s)
		print(Set.tostring(s))
	end
	-- 算术类元方法
	mt.__add = Set.union
	mt.__mul = Set.inter
	mt.__sub = Set.differ
	mt.__le = function (a, b) --包含a<=b
		for k in pairs(a) do
			if not b[k] then return false end
		end
		return true
	end
	-- 关系类元方法
	mt.__lt = function (a, b)
		return a<=b and not (b<=a)
	end
	mt.__eq = function (a, b)
		return a<=b and b<=a
	end
	mt.__tostring = Set.tostring

	s1 = Set.new{10,20,40}
	s2 = Set.new{20,30}
	print(getmetatable(s1)) --> table: 00672B60
	mt.__metatable = "hehe, caogen" -- 保护元表不让修改
	-- mt.__metatable  = function () print('ffff') end
	print(getmetatable(s2)) --> hehe, caogen
	mt.__metatable = nil

	print('算术类元方法')
	setmetatable(s1, {})
	print(s1+s2)
	print(s1*s2)
	print(s1-s2)

	print('关系类元方法')
	setmetatable(s1, mt)
	-- setmetatable(s3, {})
	s3 = Set.new{20,40}
	print(s3>s1)
	print(s3<s1)
end
meta_test()
--]]

--[[
-- 元表--table访问的元方法
function table_meta_test()
	Window = {}
	-- create the prototype with default values
	Window.prototype = {x = 0, y = 0, width = 100, height = 100}
	-- create a metatable
	Window.mt = {}
	-- declare the constructor function
	function Window.new (o)
		setmetatable(o, Window.mt)
		return o
	end
	Window.mt.__index = Window.prototype -- or
	-- function (_, key) return Window.prototype[key] end
	Window.mt.__newindex = --Window.prototype -- or
	 function (_, key, value)
	 	print("no access")
	 end

	w = Window.new{x=10, y=20}
	print('不存在的查询：__index')
	print(w.width) --> 100
	print(rawget(w, 'x'))
	print(rawget(w, 'width'))

	print('不存在的更新：__newindex')
	w.title = 'meta test'
	print(rawget(w, 'title'))
	print(w.title)
	print(w.x) --> 100
	rawset(w, 'x', 100)
	print(w.x) --> 100
	print(w.xx) --> 100
	rawset(w, 'xx', 100)
	print(w.xx) --> 100
end
-- table_meta_test()
-- 只读的table
function readOnly (t)
	local proxy = {}
	local mt = {
		__index = t,
		__newindex = function (t, k, v)
			error("attempt to update a read-only table", 2)
		end
	}
	setmetatable(proxy, mt)
	return proxy
end
days = readOnly{"Sunday", "Monday", 
				"Tuesday", "Wednesday",
				"Thursday", "Friday", 
				"Saturday"
			}
print(days[1])
days[2] = "Noday"
--]]

--[[
-- 具有动态名字的全局变量
function _G_test () 
	--for n in pairs(_G) do print(n) end
	function getfield (f)
		local v = _G
		for w in string.gmatch(f, '[%w_]+') do
			v = v[w]
		end
		return v
	end

	function setfield (f, v)
		local t = _G
		for w, d in string.gmatch(f, '([%w_]+)(%.?)') do
			if d == '.' then
				t[w] = t[w] or {}
				t = t[w]
			else
				t[w] = v
			end
		end
	end

	print(getfield('io.read'))
	-- print(getfield('a.b.c'))
	setfield('a.b.c', 'hello')
	print(getfield('a.b.c'))

end
_G_test()
--]]


