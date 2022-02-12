# LuaEnv_5.1 / Lua Sandbox Running Lua Version 5.1.4 (Open Source)
Lua 5.1.4 Version of the original Lua Env, Also enhanced majorly and has alot better functions and stability

Currently this lua sandbox is built for deobfuscation / reversing and breaking lua scripts security, it is *currently* equipped with functions like:
```lua
local function breaker()
    while(true)do
        print("rekt")
    end
end
local old
old = hookfunction(breaker,(function()
    return "nah not gonna happen"
end))
breaker() -- will not crash the client since the function has been overriden

local try_again = {"original"}
setmetatable(try_again,{__metatable = "protected lol",__call = (function()return try_again end)}) -- for metatables we will do a little trolling (there is 3 ways you can go about handling this)
-- method 1

print(getmetatable(try_again)) -- will print "protected lol" as the metatable thinks it has cornered us, but fear not as we have some special functions to deal just with this.
print(try_again()[1]) -- will print "original"

local old -- currently hookmetamethod only hooks functions (this will be fixed in a later update)
old = hookmetamethod(try_again,"__call",(function(...)
    return {"joeware"}
end))

print(try_again()[1]) -- will print "joeware"

-- method 2
local old -- preferably i like this method the most for hooking the function because it is faster then the common method (method 3)
old = hookfunction(getrawmetatable(try_again).__call,(function(...)
    return {"lol","rekt"}
end))

print(try_again()[1]) -- will print "lol"

-- method 3
local MT = getrawmetatable(try_again)
local oldcall = MT.__call
local oldMetatable = MT.__metatable -- this is a very useful aspect of method 3 as you can (CURRENTLY) only replace non-functions with method 3 as hookmetamethod is shit right now

MT.__call = newcclosure(function(...)
    return {"classic"}
end)
MT.__metatable = "changed lol"

print(getmetatable(try_again)) -- will print the new hooked changed metatable 
print(try_again()[1]) -- will print "classic"
```
This sandbox has currently a few major uses and a few key uses for its existence void from the top listings.

* You can secure your code with the "serialize" function located in the "LuaPreDefined.lua" file with all of the backend lua sandbox powering functions, Example:
```lua
local code = serialize([[ -- serialize ( string )
local storage_for_password = ""
function joeware()
    return serialize("password1234")
end
function dopasswordstor(password)
    storage_for_password = password
end
local function login(password)
    if(deserialize(password)=="password1234")then
        print("logged in")
    end
end
print("is running")
dopasswordstor(joeware())
login(storage_for_password) -- will log you in securely
]])
loadstring(code)
```
* You can deobfuscate chaos that isnt directed to any specialized syntax or any seperate type of error handling, examples: luau, Versions lua 5.1.4+ with the help of the functions located in the "LuaPreDefined.lua" and cpp functionality for the sandbox.
* Here is the documentation for more useful functions that can be used in special scenarios.

* getglobals() is a more of a "fancy" way to get the global variables if you just hate doing.
```lua
_G.print("jo")
-- vs
getglobals().print("sup")
```

* getgenv() / setgenv() is a second secure table channel used for storing cross global variables, just like globals but in a seperate container.
```lua
getgenv().hello = "yes" 
setgenv("bye","ok") -- getgenv() but you specify ( variable name , value ) [[ useful in some cases but mainly useless ]]
```

* hookfunction() / hookmetamethod() / newcclosure() / getrawmetatable() these functions are pretty broken and overpowered as they can hook any Closure( proto / function ) and hookmetamethod was documented higher up but for friendly sake i will re-state its purpose
```lua
print("Hello!")
local old -- old is allocating the old function that isnt hooked (this is print before it was hooked)
old = hookfunction(print,(function(...) -- using varags or "..." to get every variable passed for a better printing method
    return warn(...)
end))

print("warning?") -- it will now call warn(...) instead of print(...)
old("printed!")

local old -- once again we allocate the old metamethod function inside of old to call it later
old = hookmetamethod(_G,"__call",(function(...)
    return {"no table for you :)"}
end))
print(_G()) -- essentially what this now returns is a table that is not _G but is now the {"no table for you :)"}, get what i mean? ill re-iterate what i just said.
old() -- returns _G globals table
-- hookmetamethod is basically hookfunction() and cannot process anything besides functions for now but this issue will be fixed. basically this is hookmetamethod for you lua nerds

local old
old = hookfunction(getrawmetatable(_G).__call,(function(...) -- now "getrawmetatable" pulls the metatable and returns it to lua (simply it returns a modifiable table to change the metamethods that are defined in a table (that isnt readonly)
    return {"trolled"}
end))
print(_G()[1]) -- this will print "trolled" as its hooked now
print(old()) -- returns old _G once again

getrawmetatable().__metatable = "changed" -- this method is by far the most raw you can get when it comes to changing metamethods as you can also do

local MT = getrawmetatable(_G) -- gets the _G metatables (no different from the examples above with getrawmetatable)
local oldcall = MT.__call -- gets the old definition or local old; old = hookfunction(getrawmetatable(_G).__call,(function()return nil end)) , the ; in the syntax there is just to divide the lines.
MT.__call = newcclosure(function(...) -- newcclosure simply returns a lua closure back as it isnt yet working.
    return {"lol ez hook"}
end)
print(_G[1]) -- prints "lol ez hook"
print(oldcall()) -- prints the _G table
```
* table.unconcat(), this is used for taking a string and breaking it up into a table (useful for obfuscation), table.unconcat( string )
```lua
local string = "joe mama aint secure yet"
for i,v in pairs(table.unconcat(string))do
    print(i,v)
end -- prints each char (character) from the string
```
* string.multibyte() / table.multibyte(), these functions are built for byting strings, similar to the "string.byte()" function but instead it takes in an entire string, for table.multibyte i think it takes a table and returns all the chars in it to a byte format (these functions are useful for obfuscating strings) : table.multibyte ( table , boolean ), string.multibyte ( string , boolean , boolean )
```lua
local string = "Hello world"
print(string) -- "Hello world"
print(string.multibyte(string,true,true)) -- returns a concated version of the string, [[ argument 2 is for if you want your string to have automatic \ to add security and argument 3 is to decide whether to return it in a table format or a string ( false , true )
```
* windows library, this library is meant for main calling to the lua C++ backend and lua backend for elevating your permissions in the lua sandbox just because we like to make it a challenge for you to escape its security :), anyway the windows lib has about 4 funcs, windows.gethandle( string ) <- this gets any running process from your computer, windows.write ( HANDLE * ) <- writes process memory of the handle you have got in return from windows.gethandle(), windows.getwvar( CMD -> string , ... ) <- this function is used for accessing the lua backend, here are the examples of all of these in action:
```lua
local address = 0x000304D

local handle = windows.gethandle("RobloxPlayerBeta.exe") -- gets the roblox process and stores it

windows.write(handle,address,1) -- writes over the specified memory addresses memory

local firstLocal = windows.getwvar("wlocal",1) -- gets the first locally defined variable in the entire lua backend part of the sandbox

local allLocals = windows.getwvar("wALLl_cache") -- returns all local variables in the backend sandbox
```
