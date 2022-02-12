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

local try_again = {}
setmetatable(try_again,{__metatable = "protected lol",__call = (function()return try_again end)}) -- for metatables we will do a little trolling (there is 3 ways you can go about handling this)
-- method 1
local old -- currently hookmetamethod only hooks functions (this will be fixed in a later update)
old = hookmetamethod(try_again,"__call",(function(...)
    return {"joeware"}
end))
-- method 2
local old -- preferably i like this method the most for hooking the function because it is faster then the common method (method 3)
old = hookfunction(getrawmetatable(try_again).__call,(function(...)
    return {"lol","rekt"}
end))
-- method 3
local MT = getrawmetatable(try_again)
local oldcall = MT.__call
local oldMetatable = MT.__metatable -- this is a very useful aspect of method 3 as you can (CURRENTLY) only replace non-functions with method 3 as hookmetamethod is shit right now

MT.__call = newcclosure(function(...)
    return {"classic"}
end))
MT.__metatable = "changed lol"
```
This sandbox has currently a few major uses and a few key uses for its existence void from the top listings.

* You can secure your code with the "serialize" function located in the "LuaPreDefined.lua" file with all of the backend lua sandbox powering functions.
* You can deobfuscate chaos that isnt directed to any specialized syntax or any seperate type of error handling, examples: luau, Versions lua 5.1.4+ with the help of the functions located in the "LuaPreDefined.lua" and cpp functionality for the sandbox.
