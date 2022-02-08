local print = print
local UserScriptIdentity = 1 -- minimum
local CurrentScriptIdentity = 20 -- max
local currentDefined = {}
local NewSetIdentities = {}
thread = {}
lua = {}
console = {}
local oldGetProc = WProcAttach
windows = {
    gethandle = (function(...)
        local args = {...}
        local self = args[1] -- process
        return self
    end),
    write = (function (...)
        local args = {...}
        local self = args[1] -- process
        return self
    end),
    attach = (function(...)
        return windows.gethandle(...)
    end)
}

local function IdentityError(level)
    Error("Cannot Class Security Check (Identity 1) Requires Identity "..tostring(level)..".")
end
local function TypeError(f,arg,cType,_type)
    Error("LuaExec.lua:"..tostring(0/0)..": bad argument #"..tostring(arg).." to '"..f.."' ("..cType.." expected, got ".._type..")")
end

local oldpairs = pairs

local function pairs(...) -- anti metatable
    return next,...,nil
end

for i,v in pairs(_G)do
    currentDefined[i] = v
end
setmetatable(currentDefined,{__index = (function()
    IdentityError(3)
end)});
self = _G
--[[
    _G changing : identity 20
    currentDefined changing : identity 3
    exposing identity 20 : identity 20
    C++ functions : identity 20
    hooking _G with hooktable() : identity 20
]]
function getglobals()
    return _G
end
function typeof(v)
    return type(v)
end
function tostr(...)
    return tostring(...)
end
function table.find(t,str)
    local check
    for i,v in pairs(t)do
        if(t[i]==str)then
            check = true
        end
    end
    if(check==true)then
        return true
    else
        return nil
    end
end
function table.unconcat(str)
    local unconcated = {}
    for i=1,#str do
        local out = str:sub(i,i)
        unconcated[i] = out
    end
    return unconcated
end
function table.multibyte(tab,conversion)
    local output = {}
    for i,v in pairs(tab)do
        if(typeof(v)=="string")then
            if(not conversion)then
                local char = string.byte(v)
                output[i] = char
            else
                local char = "\\"..string.byte(v)
                output[i] = char
            end
        end
    end
    return output
end
function string.multibyte(str,conversion,concat)
    local output = {}
    for i=1,#str do
        local char = str:sub(i,i)
        if(not conversion)then
            char = string.byte(char)
            output[i] = char
        else
            char = "\\"..string.byte(char)
            output[i] = char
        end
    end
    if(concat==true)then
        return table.concat(output)
    end
    return output
end
characters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0",[[\]],"[","]","(",")",";","%","#","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","/","?","-","+","@",":","<",">","*","$","&","=",",",".","`","~","_","!",""," "}
function lua:deserialize(str_or_table,concatted_or_raw,do_what)
    local output = nil
    if(typeof(str_or_table)=="string")then
        local str_or_table = table.unconcat(str_or_table)
        local final_output = {}
        for i,v in pairs(str_or_table)do
            for i1,v1 in pairs(characters)do
                if(v==v1)then
                    final_output[i] = v1
                end
            end
        end
        output = final_output
    elseif(str_or_table=="table")then
        local final_output = {}
        for i,v in pairs(str_or_table)do
            for i1,v1 in pairs(characters)do
                if(v==v1)then
                    final_output[i] = v1
                end
            end
        end
        output = final_output
    end
    if(concatted_or_raw=="concat")then
        output = table.concat(output)
    end
    if(do_what~=nil and concatted_or_raw~="concat")then
        for i,v in pairs(output)do
            print(i,v)
        end
    elseif(do_what~=nil)then
        print(output)
    end
    return output
end
function invertTable(tbl)
    local intbl = {}
    for k,v in pairs(tbl) do
        intbl[v] = k
    end
    return intbl
end
local chars = {
    VhDbkjy92 = "a",
    FLk28S = "b",
    nCVjS2 = "c",
    VkjDHU2 = "d",
    vNL389 = "e",
    kponguu = "f",
    S5627rD = "g",
    kioDy37 = "h",
    lOooik8 = "i",
    jhCNSk2 = "j",
    lpomoI = "k",
    kDHUWI2 = "l",
    AQREw16 = "m",
    BJKNFTK2 = "n",
    LFJKIO3 = "o",
    lpOIPP2 = "p",
    AZXAwq1 = "q",
    NVNBEw2 = "r",
    LJBKLJW32 = "s",
    SVHJhjGEU2 = "t",
    GDhbu21 = "u",
    ZVVSQANMhj13 = "v",
    XSAHJru3g2ioW = "w",
    CJHDGEWUy2781 = "x",
    LGIureitg4o83 = "y",
    XBHJWFDGWQYtf2671 = "z",
    hhIKUDHUWY7i2 = "A",
    ncJKFHJy7843r = "B",
    pCPIPOIOuO2 = "C",
    ZCFGQADSe5E2 = "D",
    nvJKFHWIUFYCSIOD92 = "E",
    PPOIPOPOUIehi2 = "F",
    mMNNCHSGJK = "G",
    XVGHFDQRTEWRY227887 = "H",
    tYSUTUYYUncwq = "I",
    opIPOIODWI = "J",
    cVDvgvhvgDWJ = "K",
    lPOIPIoXNJKA = "L",
    XvxCFGSCfgA = "M",
    bVVCVGH2 = "N",
    LolMissedOne = "O",
    iIOoOEOPWEI = "P",
    kISWUHHukduw = "Q",
    jHHdbDHJbh = "R",
    ZAsguGSYuq1 = "S",
    llIOjioJFUIt = "T",
    YHDFYUUHWUhui = "U",
    BJHBWHdbywudyui2 = "V",
    poODdiohwawhpo = "W",
    iufeuifhuYfE34 = "X",
    xvHGVGHWVj10 = "Y",
    l23BHDJgfk = "Z",
    QUIWtiw273 = " ",
    VJHDWHk210 = "1",
    KOKBKRIu89 = "2",
    BJHDBWJHg67 = "3",
    ZFGXCcdfcgwhvh2y = "4",
    KJNLRJHIjiflfejwui = "5",
    oIFIuuYREy78 = "6",
    FDgDGgyududuk2 = "7",
    POOoppOIOI = "8",
    UYE5t62 = "9",
    ZvXVhjsgGYUSTui = "0",
    cbjkDGJHEWUiey2789BHD = "!",
    CJWGdjkJHKAgygei2 = "@",
    IIDHUWIHiudhCm = "#",
    CvSJFNlkKLOo39 = "$",
    uIUNDJbxxAAq = "%",
    AAYEyuyuXBUISUp1p28 = "^",
    CfDFHYEudnQAAwoeo = "&",
    oOiEIEDHUbCK = "*",
    LlOlOSKDJKIQjl1293s = "(",
    poEPODIPcJHbhjqxS = ")",
    jCJSzmZNxhS = "-",
    iIEockScSoe3 = "_",
    SfxVAjwo2 = "=",
    cBDHWJ2495d = "+",
    CBHJDBk24uiDl = "[",
    hFGgdUHJ45 = "]",
    pOodNJSBHkj2 = "\\",
    ZvGHVSDHGVjh = "|",
    CJBSJHHJB2qbjkheh2k = "\"",
    vcJHDbvjdg3bjkghKD = "/",
    cnbBJKDHKKHj2iku002 = "?",
    yEYUuEUbhJBSZHQKQ = "{",
    XvcFDf2jr889 = "}",
    gDHhDG2221uiy7 = ";",
    yUEuu289SghFQTfvhxC = ":",
    ZrWeWEwrqrw764327gDG = "`",
    CFDFDFEtduHHDhfu32j = "~",
    cHARy3h4hui3 = "'",
    chDGUYe390jnhS = ".",
    pOdjOIoi3 = "<",
    kVJJ22d = ">",
    lKkoDK136 = ",",
    bCJHBJHKSYgiu26iDb = "\n",
}
local invertedChars = invertTable(chars)
function serialize(str)
    local output = ""
    for i=1,#str do
        local char = str:sub(i,i)
        output = output..(invertedChars[char] or "QUIWtiw273")
    end
    return output
end
function deserialize(str)
    local output = ""
    while (str ~= "") do
        for k,v in pairs(chars) do
            local chunk = str:sub(1, #k)
            if(chars[chunk]~=nil)then
                output = output .. chars[chunk]
                str = str:sub(#chunk + 1, #str)
                break
            end
        end
    end
    return output
end
function console.log(...)
    return print(...)
end
local function ClassPrint(type1,index,v)
    print(typeof(type1).." <- type, class name is"..tostring(index)..", outputted "..tostring(v))
end
function error(...)
    Error(tostring(...))
end
function hookstring(string, type)
    for i, v in pairs(_G) do
        if (v == string) then
            oldhook(v, type, "C")
        end
    end
end
function printidentity()
    print(tostring(UserScriptIdentity))
end
function printidentities()
    print("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19");
end
local __ = {}
function getenv()
    if(t~=nil)then
        return t
    else
        return _ENV
    end
end
function __print(v)
    if (typeof(v) == [[table]]) then
        for i, v1 in pairs(v) do
            if (v1 == nil) then
                print("nil")
            else
                print(tostring(v1))
            end
        end
    else
        if (v == nil) then
            print("nil")
        else
            print(tostring(v))
        end
    end
end
function warn(...)
    local text = tostring(...)
    io.write("[WARNING]: "..text.."\n")
end
function getgenv()
    return __
end
function setgenv(i, v)
    __[i] = v
end
function merge(t,t2)
    if(typeof(t)=="table")then
        if(typeof(t2)=="table")then
            for i,v in pairs(t)do
                t2[i] = v
            end
        else
            Error("Requires a table to import arguments to")
        end
    else
        Error("Requires a table to split arguments from")
    end
end
for i,v in pairs(getglobals())do
    self[i] = v
end
local CurrentGlobals = {}
for i,v in pairs(getglobals())do
    CurrentGlobals[i] = v
end
function dump()
    for i,v in pairs(getglobals())do
        if(not CurrentGlobals[i] and i~="deobfuscate")then
            print(i)
            if(typeof(v)=="table")then
                for i1,v1 in pairs(v)do
                    print("     "..i1)
                    if(typeof(v1)=="table")then
                        for i2,v2 in pairs(v1)do
                            print(string.rep(" ",10)..i2)
                        end
                    end
                end
            end
        end
    end
end
function thread:loop_function_until(f,properties)
    delay = properties.delay
    that = properties.that
    until_this_equals_that = properties.until_this_equals_that
    arguments = properties.arguments
    local protected_internal = {}
    setmetatable(protected_internal,{__metatable = "Identity 20",__newindex = (function()
        if(that~=until_this_equals_that)then
            wait(delay)
            f(arguments)
            protected_internal[math.random(0,999999999)] = math.random(0,999999999)
        else
            protected_internal = nil;
        end
    end)})
    protected_internal.start = true
end
function unpack(...)
    return table.unpack(...)
end

function debug.dumpfunction(f,...)
    local Index = 1
    local ActualOldEnv = _ENV
    local dumped = {}
    setmetatable(dumped,{
        __call = (function(value)
            dumped[Index] = value
            Index = Index + 1
        end)
    })
    local oldtableconcat = table.concat
    local oldstringbyte = string.byte
    local oldstringsub = string.sub
    local oldselect = select
    local oldstringchar = string.char
    local oldtype = type
    local oldunpack = unpack
    local oldsetmetatable = setmetatable
    local oldpcall = pcall
    local oldgetfenv = getfenv
    local oldsetfenv = setfenv
    local oldbyte = byte
    local oldtonumber = tonumber
    local oldtostring = tostring
    local oldenv = _ENV
    oldenv.table.concat = (function(...)
        dumped(...)
        return oldtableconcat(...)
    end)
    oldenv.tonumber = (function(...)
        dumped(...)
        return oldtonumber(...)
    end)
    oldenv.tostring = (function(...)
        dumped(...)
        return oldtostring(...)
    end)
    oldenv.string.byte = (function(...)
        dumped(...)
        return oldstringbyte(...)
    end)
    oldenv.string.sub = (function(...)
        dumped(...)
        return oldstringsub(...)
    end)
    oldenv.select = (function(...)
        dumped(...)
        return oldselect(...)
    end)
    oldenv.string.char = (function(...)
        dumped(...)
        return oldstringchar(...)
    end)
    oldenv.type = (function(...)
        dumped(...)
        return oldtype(...)
    end)
    oldenv.unpack = (function(...)
        dumped(...)
        return oldunpack(...)
    end)
    oldenv.setmetatable = (function(...)
        dumped(...)
        return oldsetmetatable(...)
    end)
    oldenv.getfenv = (function(...)
        dumped(...)
        return oldgetfenv(...)
    end)
    oldenv.setfenv = (function(...)
        dumped(...)
        return oldsetfenv(...)
    end)
    oldenv.byte = (function(...)
        dumped(...)
        return byte(...)
    end)
    local args = ...
    _ENV = oldenv
    pcall(function()
        print(f(args))
    end)
    _ENV = ActualOldEnv
    return dumped
end
local function StrSpaceAdder(str,space)
    if(space~=nil)then
        str = space..str
        return str
    else
        return str
    end
end
local stacking = 0
local function CalcStrSpace(number)
    stacking = stacking + 1
    if(stacking>20)then
        stacking = 0
    end
    return string.rep(" ",stacking)
end
local DisassemblerActive = false
local function SetDisasmState(...)
    DisassemblerActive = ...
    return DisassemblerActive
end
function table.unpackv2(...)
	if typeof(...) ~= "table" then
		Error("[Disassembler]: Cannot Disassemble a non-table Value")
	end
    SetDisasmState(true)
    local repeated = {}
    local overflowcount = 0
	local string_multiplier = 0
	local MainTable = ...
	local SecurityCheck = false
	local oldenv = _ENV
	local s, out = pcall(function()
		local pairs = pairs
		oldenv = oldenv
		_ENV = {next = next}
		for i,v in pairs(MainTable) do
			SecurityCheck = true
			break
		end
		return SecurityCheck
	end)
	_ENV = oldenv
	if(out~=true)then
        ClearConsole()
        print("Lua Output:\n")
		print("[Disassembler]: TABLE MALFORMITY/METATABLE PROTECTION DETECTED, VARAGS MAY NOT OUTPUT CORRECTLY")
	end
	local decompiled = {}
	local function MainCaller(t, space)
		for i,v in pairs(t) do
			--[[
            if(t~=MainTable)then
                string_multiplier = 0
            end
            ]]
			if(typeof(v) == "table")then
			    string_multiplier = string_multiplier + 1
                if(not repeated[v])then
                    repeated[v] = v
		            decompiled[StrSpaceAdder(tostr(i).." [TABLE]",space)] = v
                    MainCaller(v,CalcStrSpace(string_multiplier))
                else
                    overflowcount = overflowcount + 1
                    if(overflowcount>=10000)then
                        print("[Disassembler]: STACK OVERFLOW")
                    else
                        string_multiplier = string_multiplier - 1
                        decompiled[StrSpaceAdder(tostr(i).." [REPEATED TABLE]", space)] = v
                        MainCaller(v, CalcStrSpace(string_multiplier))
                    end
                end
			end
			if(typeof(v) == "string")then
				decompiled[StrSpaceAdder(tostr(i).." [STRING]",space)] = v
			end
			if(typeof(v) == "number")then
				decompiled[StrSpaceAdder(tostr(i).." [NUMBER]",space)] = v
			end
			if(typeof(v) == "function")then
				decompiled[StrSpaceAdder(tostr(i).." [FUNCTION]",space)] = v
			end
			if(typeof(v) == "nil")then
				decompiled[StrSpaceAdder(tostr(i).." [NIL]",space)] = v
			end
			if(typeof(v) == "boolean")then
				decompiled[StrSpaceAdder(tostr(i).." [BOOLEAN]",space)] = v
			end
			if(typeof(v) == "thread")then
				decompiled[StrSpaceAdder(tostr(i).." [THREAD]",space)] = v
			end
			if(typeof(v) == "userdata")then
				decompiled[StrSpaceAdder(tostr(i).." [USERDATA]",space)] = v
			end
		end
	end
	MainCaller(MainTable)
    SetDisasmState(false)
	return decompiled
end
function lua_breakdown(t,method)
    local output = {}
    local function Breakdown(t)
        for i,v in pairs(t)do
            output[i] = v
            if(typeof(v)=="table")then
                output[i] = v
                Breakdown(v)
            end
        end
    end
    Breakdown(t)
    if(method)then
        for i,v in pairs(output)do
            method(v)
        end
    end
    return output
end
function unpackv2(...)
    return table.unpackv2(...)
end
function lua:disassembler_active()
    return DisassemblerActive
end
function lua:dump_table(t,link)
    SetDisasmState(true)
    local alternative = unpackv2(t)
    for i,v in pairs(alternative)do
        if(v==t)then
            v = nil
        end
        if(i==t)then
            i = nil
        end
    end
    if(link~=nil)then
        for i,v in pairs(alternative)do
            link(i,v)
        end
    end
    SetDisasmState(false)
    return alternative
end
function lua:disassemble_table(t,link)
    SetDisasmState(true)
    local alternative = unpackv2(t)
    if(link~=nil)then
        for i,v in pairs(alternative)do
            link(i,v)
        end
    end
    SetDisasmState(false)
    return alternative
end
function lua:dump_function(f,method)
    SetDisasmState(true)
    local alternative = debug.dumpfunction(f)
    if(method~=nil)then
        for i,v in pairs(alternative)do
            method(i,v)
        end
    end
    SetDisasmState(false)
    return alternative
end
function disassemblerinfo()
    print("Due to the unpackv2 lua being new and pretty complex, Its output isnt perfect and you may notice a living shit ton of malformities in the table formatting and placement. This is due to the \"Guessing game effect\" for most decompilers/disassemblers, but thats not the case here, the reason the arguments are malformed, displaced and not formatted correctly is due to the fact that the lua has no control over how the table is aranged. It simply just dumps the entire table/tables and all of its varags and constants.")
    return true
end
local oldloadstring = loadstring
local function secure_loadstring(code)
    local s,e = pcall(function()
        local try = deserialize(code)
        oldloadstring(try)
    end)
    if(e)then
        return oldloadstring(code)
    end
end
function loadstring(...)
    function BackendOptional(string)
        if(typeof(string)=="string")then
            secure_loadstring(string)
        else
            Error("loadstring custom backend requires a string to operate")
        end
    end
    if(typeof(...)=="string")then
        secure_loadstring(...)
    else
        Error("loadstring requires a string to operate")
    end
    return ...
end
function executescript(f1,f2)
    if(f2==nil)then
        loadstring(f1)
    else
        loadstring(f1)(f2)
    end
end
local oldclipbaord = setclipboard
function setclipboard(...)
    local newstring = tostring(...)
    oldclipboard(newstring)
end
local oldclear = clear
function clear()
    return oldclear()
end
local function getlockedglobals()
    return self
end
local Cdefined = {
    wait = wait;
    Error = Error;
    loadstring = loadstring;
    hook = hook;
    getstack = getstack;
}
-- func lib
--------------------------------
--------------------------------
local allfuncs = {
    IdentityError = "IdentityError";
    SetIdentity = "SetIdentity";
    ClassPrint = "ClassPrint";
    getlockedglobals = "getlockedglobals";
    setclipboard = "setclipboard";
}
local alllocals = {
    print = "print";
    UserScriptIdentity = "UserScriptIdentity";
    NewSetIdentities = "NewSetIdentities";
}
local ProtectedVars = {
    getgenvglobals = "__";
    currentDefined = "currentDefined";
    CurrentScriptIdentity = "CurrentScriptIdentity";
}
local InternalDebug = {}
function InternalDebug:getlocalfunctions()
    return allfuncs
end
function InternalDebug:getlocalizedscopevariables()
    return alllocals
end
function InternalDebug:getlevel20threadidentities()
    return ProtectedVars
end
function InternalDebug:getlockedglobals()
    return getlockedglobals()
end
function InternalDebug:getcurrentfunctions()
    return self
end
function InternalDebug:clibidentify(...)
    local check = false
    local tof = ...
    for i,v in pairs(Cdefined)do
        if(v==tof)then
            check = true
        end
    end
    if(check==true)then
        return true
    else
        return false
    end
end

-- simple versions
function InternalDebug:clib(...)
    return self:clibidentify(...)
end
function InternalDebug:getcurrent(...)
    return self:getcurrentfunctions(...)
end
function InternalDebug:getlocked(...)
    return self:getlockedglobals(...)
end
function InternalDebug:getlev20(...)
    return self:getlevel20threadidentities(...)
end
function InternalDebug:getlocalv(...)
    return self:getlocalizedscopevariables(...)
end
function InternalDebug:getlocalf(...)
    return self:getlocalfunctions(...)
end
--

-- main get
function debug:getinternalthreadfunctions()
    return InternalDebug
end
--------------------------------
--------------------------------
WProcAttach = nil
local allglobals = {}
for i,v in pairs(getglobals())do
    allglobals[i] = v
end
local count = 0
setmetatable(_G,{__metatable = "_G Enviornment Protection",__close = (function()
    IdentityError(20)
end),__call = (function()
    return _G
end)})
setmetatable(__,{__index = (function()
    Error("G-Env Enviornment Error (nil value called)")
end),__metatable = "Protected By Identity Protection"})
