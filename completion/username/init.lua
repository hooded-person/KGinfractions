local completion = require"cc.completion"
mainPath = "completion/username"
local filePath = fs.combine(mainPath,"players.lon")

local h, er = fs.open(filePath,"r")
if not h then
    error(er)
end
local players = h.readAll()
h.close()
players = textutils.unserialise(players)
players = players[2]

return function(text) return completion.choice(text,players) end