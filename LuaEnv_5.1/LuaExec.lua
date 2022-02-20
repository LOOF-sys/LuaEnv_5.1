local lasted = getfenv
local pairs = pairs
local print = print
windows.encrypt(function()
	print("joe")
end)
for i,v in pairs(lasted())do
	print(i,v)
end