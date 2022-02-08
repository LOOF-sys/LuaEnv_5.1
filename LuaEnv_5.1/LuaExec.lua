local old
old = hookfunction(print,(function(...)
	return old(...)
end))
print("lol")