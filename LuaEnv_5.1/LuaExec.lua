
local metatable = {"joe"}
setmetatable(metatable,{
	__metatable = "readonly",
	__index = (function()
		return "trol"
	end)
})

setreadonly(metatable,true)

metatable[2] = "shit"
print(metatable[1])

setreadonly(metatable,false)
print(getrawmetatable(metatable).__newindex)
metatable[2] = "nigger"
print(metatable[2])