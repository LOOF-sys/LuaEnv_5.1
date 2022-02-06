local function nig()
	return "sjoe"
end
local old
old = hookfunction(nig,(function(...)
	return "joeware"
end))
print(nig())