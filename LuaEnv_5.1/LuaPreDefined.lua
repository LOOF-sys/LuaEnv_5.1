--// Main imported libs

windows = {}
obfuscate = {}
deobfuscate = {}
serialize = {}

--// Local (Protected)
local __getgenv = {}
local CError = Error

Error = nil --// Once again, for security

function typeof(Type)
	return type(Type)
end

function getgenv()
	return __getgenv
end

function setgenv(index,value)
	getgenv()[index] = value
end

function callgenv(func,...)
	return hookfunction(func,func)(...)
end

--// Segemented Variables
local _pairs = pairs
local _typeof = typeof
local _rep = string.rep
local _wait = wait
local _print = print
local _random = math.random

function table.find(t,sig)
	for i,v in _pairs(t)do
		if(v==sig)then
			return true
		end
	end
end

function setrawmetatable(Table, index, value)
	local meta = getrawmetatable(Table)
	meta[index] = value
	return meta
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

local _warn = __warn
function warn(...)
	local args = {...}
	local onebig = ""
	for i,v in _pairs(args)do
		onebig = onebig..tostring(v).."   "
	end
	_warn(onebig)
	return true;
end
__warn = nil --// for safety reasons

setmetatable(_G,{
	__metatable = "_G Environment Protection",
	__call = (function()return _G end),
	__close = (function()return CError("Missing Permissions")end)
})
setmetatable(__getgenv,{
	__metatable = "_G Environment Protection",
	__call = (function()CError("Missing Permissions")end),
	__close = (function()return CError("Missing Permissions")end)
})