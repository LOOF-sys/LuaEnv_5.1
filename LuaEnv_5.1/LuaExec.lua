local old
old = hookfunction(deserialize,(function(...)
	return print(...)
end))

local s = serialize([[
	print("joemama")
]])

loadstring(s)