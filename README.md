# Lua Sandbox Running Lua 5.1.4
* Made by Cypher#6678 | For lua documentation visit https://www.lua.org/manual/5.1/manual.html#2
This sandbox is made for multiple major tasks and suddle tasks such as reverse engineering, encryption and much more, this documentation will walk you through the most valuable functions

## Global Hooking Library (Based in _G)
This segmented part of _G is dedicated to hooking security / cracking malicious code and or reverse engineering lua code in some cases

* ★**hookfunction( function1 , function2 ) Return Value: Function**
* This function is made to hook other functions and replace them with there same type of closure/function, it is very important in handling malicious code
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

* **hookmetamethod( table , method , value: any) Return Value: Old**
* This function is used to override metatable values that you specify, it is very useful when a malicious script overrides a key metatable that you need to access, heres how you use it
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

* ★**getrawmetatable( table ) Return Value: Table**
* This function is used to get the raw metatable from a table (if one exists) (all methods assigned to the metatable) and return it, Example:
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

* **setrawmetatable( table , table ) Return Value: Boolean**
* This function is used to override a tables (ALREADY SET) metatable, Example of use:
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

* **setreadonly( Table, Boolean ) Return Value: Boolean**
* This function is used to change the writeability of a table based on the Boolean provided
```lua
local LockMe = {"important"}
setreadonly(LockMe,true)
LockMe[2] = "oof" -- warning: attempt to modify a readonly table

setreadonly(LockMe,false)
LockMe[2] = "oof" -- works
```

## Obfuscation & Serialization Library
This library is used to obfuscate / secure your code with many advanced algorithms to simple table encoding and simple string security

* **obfuscate.unconcat( string ) Return Value: Table**
* This function takes a string and breaks it up into an array of characters that make up the string, Example:
```lua
local FullString = "yo whats up"
FullString = obfuscate.unconcat(FullString)
print(FullString) -- it will now print a table that contains all of the characters in FullString
```

* **obfuscate.multibyte( string, Table: {["Type"] = "table" or "string", ["Slashes"] = true or false}) Return Value: String or Table**
* This function is a bit of a hassle to get the hang of, but its basically the string encrypter and it has some options with it, Example:
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

* ★**serialize.CreateCharacter( char ) Return Value: String**
* This function takes a character and returns a random based serialized encoded version of it, very very secure way of encrypting your strings and is a hassle to reverse engineer, Example of usage:
```lua
local Encrypt = {"y","o"}
local Encrypted = {}
for i,v in pairs(Encrypt)do
	Encrypted[i] = serialize.CreateCharacter(v)
end
print(table.concat(Encrypted)) -- prints "yo" in a randomized encrypted form
```

* ★**serialize.DecodeCharacter( string ) Return Value: char**
* This function does the opposite of serialize.CreateCharacter, it decrypts the character with an untraceable & non embedded method, Example:
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

* ★**deobfuscate.disassembleTable( table ) Return Value: Table**
* This function takes in a table and returns a completely dug up version of it (all of the buried values are rosen to the top and placed in an organize array), Example:
```lua

-- we will print all of the contents of _G in an organized fasion
deobfuscate.dumpTable(deobfuscate.disassembleTable(_G),false) -- prints all of _G
```

* **deobfuscate.dumpTable( table, boolean) Return Value: 0**
* This function basically takes a tables and prints all of its top layer contexts, its essentially a compressed for loop, Example:
```lua
local Table = {"hello","dumper","lol"}
deobfuscate.dumpTable(Table,false) -- prints all of the contexts with the index
deobfuscate.dumpTable(Table,true) -- prints all of the contexts without the index
```

* **[!] WARNING: UNRELIABLE FUNCTION | ~~deobfuscate.reverseTable( table ) Return Value: nil~~**
* This function is used to swiutch the i and v values around so its v = i, Example:
```lua
local Table = {
	["Wrong Way"] = 1
}
Table = deobfuscate.reverseTable(Table)
print(Table[1]) -- prints "Wrong Way"
```

* **deobfuscate.unpack( table, string: "string" or "table") Return Value: string or table or false
* This function is used to get all of a tables values and store them in either a string or table, Example: 
```lua
local Store = {"yo","bruh"}
local StoreString = ""
StoreString = deobfuscate.unpack(Store,"string") -- will import all of the tables values into StoreString
```

* ★***deobfuscate.sandboxFunction(function, ...) Return Value: Table***
* This function is very **special** and is one of the best reversing function this entire sandbox has to offer as it hijacks the sandbox's env and logs all function calls therefor telling you everything the function is doing, very useful for debugging, Example:
```lua
function malicious()
	local cantTraceMyLoop = {"lol"}
	for i,v in pairs(cantTraceMyLoop)do -- logged "pairs" call
		print(v) -- logged "print" call
	end
	return cantTraceMyLoop -- intercepted
end
deobfuscate.sandboxFunction(cantTraceMyLoop)
```

## Windows Library
This library is used to directly call to windows like opening messageboxes, closeing the windows, clearing the window and much more

* [?] This function is superseded by io.write | > windows.write(...) Return Value: true
* This function calls to io.write(...), Example:
```lua
windows.write("lol\n") -- prints "lol" from io.write
```

* ★**windows.closeprompt() Return Value: nil**
* This function closes the current prompt/window the lua sandbox is running in
```lua
windows.closeprompt() -- closes the windows
```

* ★**windows.messagebox(string: Title, string: Message, integer: Code) Return Value: nil**
* This function opens up a message box with the current args provided
```lua
windows.messagebox("lol","sussy error",16) -- opens up an error box
```

* ★**windows.clear() Return Value: nil**
* This function clears the prompt of all text
```lua
print("annying text")
windows.clear() -- clears the console of all text
```

* **windows.echo(...) Return Value: nil**
* This function calls directly to C to print the text you provide it, this function does not support multi-args
```lua
windows.echo("hello world") -- prints "hello world"
```

## Default _G
The default functions inside of the sandbox

* **typeof( type ) Return Value: string**
* Function used to identify the type of something, same as the "type" function
```lua
print(typeof(45)) -- prints "number"
```

* **getgenv() Return Value: Locked Table**
* This function is used to access the private getgenv table used to store backend variables
```lua
setgenv("lol",1) -- set a value to getgenv table
print(getgenv().lol) -- print "lol" value
```

* **callgenv(function) Return Value: Function Return**
* This function calls the function through C
```lua
callgenv(print,"lol") -- prints "lol"
```

* **getglobals() Return Value: _G**
* Fancy way to get _G
```lua
getglobals().print("yo") -- prints "yo"
```

# How to Install? Below is a guide, Any issues report to Cypher#6678 on Discord
* How do you download this Sandbox? Easy. Follow the steps below
* On the left there should be a little thing called "Releases", under that there should be a release, click it and it should download right away, after that go to your downloads folder and extract the zip to where ever, then from there delete the zip and keep the extracted folder, open it up, then open up the folder inside it, then edit the "LuaExec.lua" file preferably in an IDE and boom just edit it and whenever your ready to run your lua code, just run the .exe
