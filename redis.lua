local ret = redis.call('keys', 'device:*')
-- local ret = {"device:12312323:data", "device:33333:update"}
local msg = ''
local set = {}
local t
local v
for _,r in pairs(ret) do
	-- print(_, r)
	-- local sn = string.match(r, ':(%S+):')
	-- print(sn,type(sn)) 
	-- set[sn] = true
	t = redis.call('type', r)
	if t.ok == 'hash' then
		v = redis.call('hkeys', r)
	elseif t.ok == 'zset' then
		v = redis.call('zrange', r, 0, -1)
	else
		v = nil
	end
	table.insert(set, v)
end
return set--{'123',123,34,{'ewr',666,{222,333,555}}}
-- return table.concat(set, '\n')
