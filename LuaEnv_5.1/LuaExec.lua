local function ShouldntWorkInLua(str)
	print("func: "..str)
	return "trolled"
end
print(ShouldntWorkInLua("joe mama"))
local old
old = hookfunction(ShouldntWorkInLua,(function(...)
	return "no"
end))
print(ShouldntWorkInLua("joe mama"))
old("no way it worked")
ShouldntWorkInLua = old
print(ShouldntWorkInLua("ah now it works"))