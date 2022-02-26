local string1 = [[
	print("from lua sandbox :) joeware")
]]
lloadstring(string1) -- lloadstring is a new function similar to "loadstring" but does not attempt to deserialize the text. (its a faster loadstring)

lloadallocate(string1,"joeware",(function(linker_table,...)
	linker_table.string = linker_table.string:gsub("joeware","noware")
	print("removed joeware but caller gave us "..(...))
end),"this magik")
lloadstring(string1) -- run it for yourself