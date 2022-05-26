local encode = "hello"
encode = obfuscate.multibyte(encode,{
     Type = "string",
     Withslashes = true
})
encode = encode:sub(3,#encode)
print(encode)
--// The string is now encoded (try it)