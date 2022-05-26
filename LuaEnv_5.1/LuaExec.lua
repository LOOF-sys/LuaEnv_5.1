deobfuscate.dumpTable(deobfuscate.disassembleTable(deobfuscate.sandboxFunction(function(...)
	local packed = {}
	local function pack(arg)
		packed[math.random(1,10000)] = {
			[math.random(1,10000)] = {
				[math.random(1,10000)] = math.random(1,10000),
				[math.random(1,10000)] = math.random(1,10000),
				[math.random(1,10000)] = math.random(1,10000)
			},
			[math.random(1,10000)] = {
				[math.random(1,10000)] = {
					[math.random(1,10000)] = math.random(1,10000),
					[math.random(1,10000)] = math.random(1,10000),
					[math.random(1,10000)] = math.random(1,10000)
				},
				[math.random(1,10000)] = {
					[math.random(1,10000)] = {
						[math.random(1,10000)] = math.random(1,10000),
						[math.random(1,10000)] = math.random(1,10000),
						[math.random(1,10000)] = math.random(1,10000)
					},
					[math.random(1,10000)] = math.random(1,10000),
					[math.random(1,10000)] = arg,
					[math.random(1,10000)] = math.random(1,10000)
				}
			}
		}
	end
	local protected = {...}
	for i,v in pairs(protected)do
		pack(v)
	end
	return packed
end,"joe")))