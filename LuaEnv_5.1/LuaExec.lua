local Salt = math.random(1,10)
local AddSalt = math.random(1,10000)
local MultiplySalt = math.random(1,10000)
local DivideSalt = math.random(1,10000)
local RSalts = {math.random(10,100),math.random(10,100),math.random(10,100)}
local Characters = {}

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

function LoopNumber(number)
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

function CreateCharacter(Letter)
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

function DecodeCharacter(Chars)
	for i,v in pairs(sigs)do
		if(v==Chars)then
			return i
		end
	end
end

local Encoded = {
	CreateCharacter("n"),CreateCharacter("i"),CreateCharacter("g"),CreateCharacter("g"),CreateCharacter("e"),CreateCharacter("r")
}
print(table.concat(Encoded))

local Decoded = Encoded
for i,v in pairs(Decoded)do
	Decoded[i] = DecodeCharacter(v)
end
print(table.concat(Decoded))