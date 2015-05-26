local ret = {}
for i=1, 100 do
	local count = 0
	for j=1, math.floor(i/2) do
		if i%j == 0 then count = count + 1 end
	end
	count = count + 1
	-- print(count)
	if count%2 == 1 then ret[#ret+1] = i end
end
-- print(#ret)
-- print(table.concat(ret, ','))

local ret = {}
local lights = {}
for i=1,100 do
	lights[i] = false
end
for person=1,100 do
	for light=person,100,person do
		lights[light] = not lights[light]
	end
end
for i=1,100 do
	if lights[i] then ret[#ret+1] = i end
end
print(#lights)
print(table.concat(ret, ','))














--[=[
-- ÎÄ¼þ²Ù×÷
local str = [[
<html>
	<head>
		<title>file test</title>
	</head>
	<body>
		<h1>Welcome caogen</h1>
	</body>
</html>
]]
function file_test()
	f = assert(io.open('lua.html', 'w'))
	-- print(f:read('*all'))
	f:write(str)
	f:flush()
	print(f:read('*all'))
	f:close()

end
file_test()
--]=]
