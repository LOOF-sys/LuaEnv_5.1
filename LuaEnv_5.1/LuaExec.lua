print(is_c_function(hookfunction))
local old
old = hookfunction(hookfunction,newcclosure(function(...)
	return old(...)
end))

print(is_c_function(hookfunction))