# Lua Sandbox Running Lua 5.1.4
* Made by Cypher#6678 | For lua documentation visit https://www.lua.org/manual/5.1/manual.html#2
This sandbox is made for multiple major tasks and suddle tasks such as reverse engineering, encryption and much more, this documentation will walk you through the most valuable functions

## Global Hooking Library (Based in _G)
This segmented part of _G is dedicated to hooking security / cracking malicious code and or reverse engineering lua code in some cases

** hookfunction( function1 , function2 ) Return Value: Function
This function is made to hook other functions and replace them with there same type of closure/function, it is very important in handling malicious code
```lua
function totally_safe_function_that_does_math(int1,int2)
	hidden_malicious_function()
	return int1 + int2
end
function hidden_malicious_function()
	while(true)do -- crash (this can be as harmless as this to as bad as an ACE exploit on the sandbox
		print("L")
	end
end

-- To deal with functions like this, heres what you do
local old = nil -- initalize the variable
old = hookfunction(hidden_malicious_function,(function()
	-- put whatever replacement code you want here (can just be blank aswell
	return warn("an unexpected call to an unverified function has occured")
end))
print(old) -- "old" is the original function before it was hooked, its the malicious function basically
old() -- crash because its the malicious function
```

* hookmetamethod( table , method , value: any) Return Value: Old
This function is used to override metatable values that you specify, it is very useful when a malicious script overrides a key metatable that you need to access, heres how you use it
```lua
local important = {"i this table to store stuff"}
function hacker_thing()
	setmetatable(important,{
		__metatable = "stolen",
		__newindex = (function()
			return "haha now you need to use rawset L"
		end)
	})
end
hacker_thing()
-- The malicious function thinks it has won, but heres what you can do to override it
local old = nil -- store the old function 
old = hookmetamethod(important,"__newindex",(function(v,i)
	return rawset(important,i,v)
end))

important[420] = "works now" -- works

print(old()) -- "haha now you need to use rawset L"
```

* getrawmetatable( table ) Return Value: Table
This function is used to get the raw metatable from a table (if one exists) (all methods assigned to the metatable) and return it, Example:
```lua
local New = {}
setmetatable(New,{
	__metatable = "im set",
	__index = (function(v,i) -- how do i know this is here ahead of time?
		return warn("not a value")
	end)
})

-- to check lets do this
if(getrawmetatable(New).__index~=nil)then
	print("is set!")
end

-- getrawmetatable can also be used for assaulting metatable security (similar to hookmetamethod or setrawmetatable
```

* setrawmetatable( table , table ) Return Value: Boolean
This function is used to override a tables (ALREADY SET) metatable, Example of use:
```lua
local Table = {}

function hacked()
	setmetatable(Table,{
		__metatable = "haha ive ruined your __metatable value >:)"
	})
end
hacked()

-- it thinks we are screwed but let us show what we can do
setrawmetatable(Table,{
	__metatable = "get ratioed bozo"
})
```

* setreadonly( Table, Boolean ) Return Value: Boolean
This function is used to change the writeability of a table based on the Boolean provided
```lua
local LockMe = {"important"}
setreadonly(LockMe,true)
LockMe[2] = "oof" -- warning: attempt to modify a readonly table

setreadonly(LockMe,false)
LockMe[2] = "oof" -- works
```

## Obfuscation & Serialization Library
This library is used to obfuscate / secure your code with many advanced algorithms to simple table encoding and simple string security

* obfuscate.unconcat( string ) Return Value: Table
This function takes a string and breaks it up into an array of characters that make up the string, Example:
```lua
local FullString = "yo whats up"
FullString = obfuscate.unconcat(FullString)
print(FullString) -- it will now print a table that contains all of the characters in FullString
```

* obfuscate.multibyte( string, Table: {["Type"] = "table" or "string", ["Slashes"] = true or false}) Return Value: String or Table
This function is a bit of a hassle to get the hang of, but its basically the string encrypter and it has some options with it, Example:
```lua
local String = "whats up" -- define a string

print(obfuscate.multibyte(String,{
	Type = "string", -- set the setting so it returns a string rather then a table of the encrypted chars
	Slashes = true -- if the strings/table will contain slashes
}))

print(obfuscate.multibyte(String,{
	Type = "table", -- set it as a table so it returns an array with each index containing a small string being the encrypted char
	Slashes = true -- if the strings/table will contain slashes
}))
```

* serialize.CreateCharacter( char ) Return Value: String
This function takes a character and returns a random based serialized encoded version of it, very very secure way of encrypting your strings and is a hassle to reverse engineer, Example of usage:
```lua
local Encrypt = {"y","o"}
local Encrypted = {}
for i,v in pairs(Encrypt)do
	Encrypted[i] = serialize.CreateCharacter(v)
end
print(table.concat(Encrypted)) -- prints "yo" in a randomized encrypted form
```

* serialize.DecodeCharacter( string ) Return Value: char
This function does the opposite of serialize.CreateCharacter, it decrypts the character with an untraceable & non embedded method, Example:
```lua
local Encrypt = {"y","o"}
local Encrypted = {}
for i,v in pairs(Encrypt)do
	Encrypted[i] = serialize.CreateCharacter(v)
end
print(table.concat(Encrypted)) -- prints "yo" in a randomized encrypted form

for i,v in pairs(Encrypted)do
	Encrypted[i] = serialize.DecodeCharacter(v)
end
print(table.concat(Encrypted)) -- prints "yo" normally
```

## Deobfuscation Library
This library is made to attempt to deobfuscate scripts and decrypt some of there contents, its not very good for what it is yet but it does have some very concrete functions

* deobfuscate.disassembleTable( table ) Return Value: Table
This function takes in a table and returns a completely dug up version of it (all of the buried values are rosen to the top and placed in an organize array), Example:
```lua

-- we will print all of the contents of _G in an organized fasion
deobfuscate.dumpTable(deobfuscate.disassembleTable(_G),false) -- prints all of _G
```

* deobfuscate.dumpTable( table, boolean) Return Value: 0
This function basically takes a tables and prints all of its top layer contexts, its essentially a compressed for loop, Example:
```lua
local Table = {"hello","dumper","lol"}
deobfuscate.dumpTable(Table,false) -- prints all of the contexts with the index
deobfuscate.dumpTable(Table,true) -- prints all of the contexts without the index
```

* [!] WARNING: UNRELIABLE FUNCTION | ~~deobfuscate.reverseTable( table ) Return Value: nil~~
This function is used to swiutch the i and v values around so its v = i, Example:
```lua
local Table = {
	["Wrong Way"] = 1
}
Table = deobfuscate.reverseTable(Table)
print(Table[1]) -- prints "Wrong Way"
```
