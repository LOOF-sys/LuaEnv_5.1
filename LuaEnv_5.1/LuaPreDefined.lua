--// Main imported libs

windows = {}
obfuscate = {}
deobfuscate = {}
serialize = {}
casting = {}

--// _G V2
shared = {}

--// Local (Protected)
local __getgenv = {}
local CError = error

local oldrawset = rawset

function typeof(Type)
	if(type(Type)=="table"and getmetatable(Type)=="debugtable")then
		return "debugtable"
	end
	return type(Type)
end

function getgenv()
	return __getgenv
end

function setgenv(index,value)
	return oldrawset(__getgenv,index,value)
end

function callgenv(func,...)
	return hookfunction(func,func)(...)
end

function getglobals()
	return _G
end

function setglobal(index,v)	
	_G[index] = v
end

rawset = nil
function rawset(Table, Index, Value)
	if(getmetatable(Table)=="debugtable")then
		return warn("attempt to modify a readonly table")
	end
	if(getmetatable(Table)=="readonly")then
		return warn("attempt to modify a readonly table")
	end
	return oldrawset(Table,Index,Value)
end

--// Segemented Variables
local _pairs = pairs
local _typeof = typeof
local _rep = string.rep
local _wait = wait
local _print = print
local _random = math.random

casting.castint = castint
castint = nil

function math.round(number)
	return casting.castint(number)
end

--// Serialize Library

local Salt = math.random(1,10)
local AddSalt = math.random(1,10000)
local MultiplySalt = math.random(1,10000)
local DivideSalt = math.random(1,10000)
local RSalts = {math.random(10,100),math.random(10,100),math.random(10,100)}

local Letters = {
	"?",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	".",
	"%",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"!",
	"@",
	"#",
	"$",
	"^",
	"&",
	"*",
	"(",
	")",
	"-",
	"_",
	"+",
	"=",
	"~",
	"`",
	"[",
	"]",
	"\\",
	"/",
	":",
	";",
	"\"",
	"'",
	"<",
	">",
	",",
	".",
	"|",
	"{",
	"}"
}

local function LoopNumber(number)
	number = ((math.sqrt(number) + Salt) * MultiplySalt) / #Letters
	while(number>5000000)do
		number = number / 2
	end
	number = math.round(number)
	while(number>#Letters)do
		number = number - #Letters
		if(number<1)then
			number = number - 1
			number = math.abs(number)
			if(number>#Letters)then
				number = 1
			end
		end
	end
	return number
end

function serialize.CreateCharacter(Letter)
	for i,v in pairs(Letters)do
		if(Letter==v)then
			i = (0-i)
			i = math.abs(i)
			local Temp = math.pow(i,Salt)
			local Temp1 = math.sqrt(i + AddSalt) * RSalts[1]
			local Temp2 = math.sqrt(i * MultiplySalt) * RSalts[2]
			local Temp3 = math.sqrt(i / DivideSalt) * RSalts[3]

			if(math.round(Temp3)<=0)then
				Temp3 = 10
			end

			local Final = math.round(math.pow((((Temp + Temp1) * Temp2) / Temp3),Salt))
			local Final2 = Final * 2
			local Final3 = Final * 3
			local Final4 = Final * 4
			local Final5 = Final * 5

			Final = LoopNumber(Final)
			Final2 = LoopNumber(Final2)
			Final3 = LoopNumber(Final3)
			Final4 = LoopNumber(Final4)
			Final5 = LoopNumber(Final5)
			return (Letters[Final]..Letters[Final2]..Letters[Final3]..Letters[Final4]..Letters[Final5])
		end
	end
end

local sigs = {}

for i,v in pairs(Letters)do
	i = (0-i)
	i = math.abs(i)
	local Temp = math.pow(i,Salt)
	local Temp1 = math.sqrt(i + AddSalt) * RSalts[1]
	local Temp2 = math.sqrt(i * MultiplySalt) * RSalts[2]
	local Temp3 = math.sqrt(i / DivideSalt) * RSalts[3]

	if(math.round(Temp3)<=0)then
		Temp3 = 10
	end

	local Final = math.round(math.pow((((Temp + Temp1) * Temp2) / Temp3),Salt))
	local Final2 = Final * 2
	local Final3 = Final * 3
	local Final4 = Final * 4
	local Final5 = Final * 5

	Final = LoopNumber(Final)
	Final2 = LoopNumber(Final2)
	Final3 = LoopNumber(Final3)
	Final4 = LoopNumber(Final4)
	Final5 = LoopNumber(Final5)

	sigs[v] = (Letters[Final]..Letters[Final2]..Letters[Final3]..Letters[Final4]..Letters[Final5])
end

function serialize.DecodeCharacter(Chars)
	for i,v in pairs(sigs)do
		if(v==Chars)then
			return i
		end
	end
end

--\\ Serialize Library End

function table.find(t,sig)
	for i,v in _pairs(t)do
		if(v==sig)then
			return true
		end
	end
end

function hookmetamethod(Table, method, value)
	local meta = getrawmetatable(Table)
	if(typeof(meta[method])=="function"and typeof(value)=="function")then
		return hookfunction(meta[method],value)
	end
	meta[method] = value
	return meta
end

function obfuscate.unconcat(str)
	local temp = {}
	local nxttemp = 1
	local len = 1
	while(len<#str+1)do
		temp[nxttemp] = str:sub(len,len)
		nxttemp = nxttemp + 1
		len = len + 1
	end
	return temp
end


function obfuscate.multibyte(str,options)
	local out = nil
	local current = 1
	local nextidx = 1

	--// Settings
	local Type = options["Type"] or "string"
	local Withslashes = options["Slashes"] or true

	if(Type=="string")then
		out = ""
		nextidx = nil
		if(Withslashes==true)then
			while(current<#str+1)do
				out = out.."\\"..string.byte(str:sub(current,current))
				current = current + 1
			end
		end
		if(Withslashes==false)then
			while(current<#str+1)do
				out = out..string.byte(str:sub(current,current))
				current = current + 1
			end
		end
		return out
	end
	if(Type=="table")then
		out = {}
		if(Withslashes==true)then
			while(current<#str+1)do
				out[nextidx] = "\\"..str:sub(current,current)
				current = current + 1
				nextidx = nextidx + 1
			end
		end
		if(Withslashes==false)then
			while(current<#str+1)do
				out[nextidx] = str:sub(current,current)
				current = current + 1
				nextidx = nextidx + 1
			end
		end
		return out
	end
end

local chars = {
	'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
	'1','2','3','4','5','6','7','8','9','0',
	'-','_','+','=','[',']','{','}','|','\\','/','?','.','>',',','<',';',':','"','!','@','#','$','%','^','&','*','(',')','~','`'
}
function deobfuscate.undobytes(str)
	local strpos = 1
	while(strpos<#str+1)do
		CError("function has been disabled until further notice")
		return false
	end
end

function deobfuscate.disassembleTable(t)
	local dumped_table = {}
	local nxt = 1
	local logged = {}
	local function DumpNextTable(t1,space,index)
		if(not logged[t1])then
			logged[t1] = {
				Table = t1,
				Calls = 1
			}
		end
		logged[t1].Calls = logged[t1].Calls + 1
		if(logged[t1].Calls>3)then
			return
		end
		dumped_table[nxt] = (_rep(" ",space-2).."["..index.."]: {")
		nxt = nxt + 1
		for i,v in _pairs(t1)do
			if(_typeof(v)=="string")then
				dumped_table[nxt] = (_rep(" ",space).."["..i.."]: ".."\""..tostring(v).."\",")
				nxt = nxt + 1
			end
			if(_typeof(v)=="number")then	
				dumped_table[nxt] = (_rep(" ",space).."["..i.."]: "..tostring(v)..",")
				nxt = nxt + 1
			end
			if(_typeof(v)=="function")then
				dumped_table[nxt] = (_rep(" ",space).."["..i.."]: "..tostring(v)..",")
				nxt = nxt + 1
			end
			if(_typeof(v)=="userdata")then
				dumped_table[nxt] = (_rep(" ",space).."["..i.."]: "..tostring(v)..",")
				nxt = nxt + 1
			end
			if(_typeof(v)=="table")then
				DumpNextTable(v,space+2,i)
			end
		end
		dumped_table[nxt] = (_rep(" ",space-2).."}")
		nxt = nxt + 1
	end
	for i,v in _pairs(t)do
		if(_typeof(v)=="string")then
			dumped_table[nxt] = ("["..i.."]: ".."\""..tostring(v).."\",")
			nxt = nxt + 1
		end
		if(_typeof(v)=="number")then
			dumped_table[nxt] = ("["..i.."]: "..tostring(v)..",")
			nxt = nxt + 1
		end
		if(_typeof(v)=="function")then
			dumped_table[nxt] = ("["..i.."]: "..tostring(v)..",")
			nxt = nxt + 1
		end
		if(_typeof(v)=="userdata")then
			dumped_table[nxt] = ("["..i.."]: "..tostring(v)..",")
			nxt = nxt + 1
		end
		if(_typeof(v)=="table")then
			DumpNextTable(v,2,i)
		end
	end
	return dumped_table
end

function deobfuscate.dumpTable(t,noindex)
	if(noindex==true)then
		for i,v in _pairs(t)do
			_print(v)
		end
	else
		for i,v in _pairs(t)do
			_print(i,v)
		end
	end
	return 0
end

function deobfuscate.reverseTable(t)
	for i,v in _pairs(t)do
		t[v] = i
	end
end

local __LWA = LWA
--// Win Lib
function windows.write(...)
	io.write(...)
	return true
end

function windows.closeprompt()
	return __LWA(1)
end
	
function windows.messagebox(Title, Message, Code)
	return __LWA(2,Title, Message, Code)
end

function windows.echo(...)
	local str = tostring(...)
	return __LWA(3,str)
end

function windows.clear()
	return __LWA(4)
end
LWA = nil --// Security

function messagebox(Title, Message, Code)
	return windows.messagebox(Title, Message, Code)
end

local broken_functions = {
	"tostring",
	"warn",
	"echo",
	"clear"
}

function deobfuscate.unpack(t,option)
	if(option=="string")then
		local strout = ""
		for i,v in _pairs(t) do
			if(i~=#t)then
				strout = strout..tostring(v)..", "
			else
				strout = strout..tostring(v)
			end
		end
		return strout
	end
	if(option=="table")then
		local tabout = {}
		local nxt = 1
		for i,v in _pairs(t) do
			tabout[nxt] = v
			nxt = nxt + 1
		end
		return tabout
	end
	return false
end

local function InterceptFuncArgs(...)
	return {...}
end	
	
function deobfuscate.sandboxFunction(f,...)
	local env = getfenv()
	local AlreadyHooked = {}
	local Hooks = {}
	local HIndex = 1
	local Seen = {}
	local InterceptedArgs = {}
	local IAI = {}
	local function Rebound(t)
		if(Seen[t])then
			return
		end
		Seen[t] = t
		for i,v in _pairs(t)do
			_wait(.01)
			if(_typeof(v)=="function"and not AlreadyHooked[i]and not table.find(broken_functions,i))then
				local SelfIndex = HIndex
				warn("hooking "..i.."...")
				if(not InterceptedArgs[i])then
					InterceptedArgs[i] = {
						Name = i,
						Args = {},
						ArgsIndex = 1
					}
				end
				AlreadyHooked[i] = i
				Hooks[HIndex] = v
				t[i] = (function(...)
					InterceptedArgs[i].Args[InterceptedArgs[i].ArgsIndex] = {...}
					InterceptedArgs[i].ArgsIndex = InterceptedArgs[i].ArgsIndex + 1
					windows.echo("["..i.." CALLED]: "..deobfuscate.unpack({...},"string"))
					return Hooks[SelfIndex](...)
				end)
				--[[
				Hooks[HIndex] = hookfunction(v,(function(...)
					windows.echo("["..i.." CALLED]: "..tostring(...))
					return Hooks[SelfIndex]
				end))
				]]
				HIndex = HIndex + 1
			end
			if(_typeof(v)=="table")then
				Rebound(v)
			end
		end
	end
	for i,v in _pairs(env)do
		if(_typeof(v)=="function"and not AlreadyHooked[i]and not table.find(broken_functions,i))then
			local SelfIndex = HIndex
			warn("hooking "..i.."...")
			if(not InterceptedArgs[i])then
				InterceptedArgs[i] = {
					Name = i,
					Args = {},
					ArgsIndex = 1
				}
			end
			Hooks[HIndex] = v
			env[i] = (function(...)
				InterceptedArgs[i].Args[InterceptedArgs[i].ArgsIndex] = {...}
				InterceptedArgs[i].ArgsIndex = InterceptedArgs[i].ArgsIndex + 1
				windows.echo("["..i.." CALLED]: "..deobfuscate.unpack({...},"string"))
				return Hooks[SelfIndex](...)
			end)
			--[[
			Hooks[HIndex] = hookfunction(v,(function(...)
				windows.echo("["..i.." CALLED]: "..tostring(...))
				return Hooks[SelfIndex]
			end))
			]]
			HIndex = HIndex + 1
		end
		if(_typeof(v)=="table")then
			Rebound(v)
		end
	end
	setfenv(1,env)
	windows.clear()
	warn("logging calls...")
	InterceptedArgs["MAIN_CALLING_FUNCTION_"..tostring(_random(1,999999999))] = deobfuscate.unpack(InterceptFuncArgs(f(...)),"table")
	return InterceptedArgs
end

setreadonly(obfuscate,true)
setreadonly(deobfuscate,true)
setreadonly(windows,true)
setreadonly(serialize,true)

setmetatable(_G,{
	__metatable = "_G Environment Protection",
	__call = (function()return _G end),
	__close = (function()return CError("Missing Permissions")end)
})
setmetatable(__getgenv,{
	__metatable = "readonly",
	__call = (function()CError("Missing Permissions")end),
	__close = (function()return CError("Missing Permissions")end),
	__newindex = (function()return CError("attempt to modify a readonly table") end)
})