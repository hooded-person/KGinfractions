settings.define("KGtemplateForge.typeColors", {
    description = "Which colors too use for template types",
    default = {
        ["WARN"] = colors.orange,
        ["EVIC"] = colors.red,
        ["HIDE"] = colors.gray,
    },
    type = "table",
})
local args = {...}
local loop = false
if args[1] == "-l" then
    table.remove(args,1)
    loop = true
end
local argStr
if args[1] == "-f" then
    table.remove(args,1)
    local path = table.remove(args,1)
    path = fs.combine( shell.dir(), path )
    print(path)
    argStr = loadfile( path )()
else
    argStr = table.concat(args," ")
end
local colorNum = settings.get("KGtemplateForge.typeColors")[argStr:upper()]
local color
if colorNum then
    color = colors.toBlit(colorNum)
end
local lines
local i = 0
repeat
    if loop then
        i = i + 1
        term.clear()
        term.setCursorPos(1,1)
    end
    local output = loadfile("/main/alphabet.lua")()( argStr )

    lines = "shrekdoc-v02w25h21mR:"
    if colorNum then lines = lines.."\160c"..color end

    lines = lines..(#argStr/2 == 1 and "\160ac" or "" )
        ..output
        .."\160cf"

    print(output)
    print(i)
    if loop then sleep(0) end
until not loop
local spclib = require("../libs/spclib")
local printerHost = 15

rednet.open("back")
local success, reason = spclib.printDocument(printerHost, lines, 1, false)
if not success then
    print(reason)
end