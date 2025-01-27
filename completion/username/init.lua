---@param ... string strings for paths to combine
---@return string
local function combinePath(...)
    settings.define("KGinfractions.root", {
        description = "The program root",
        default = "/",
        type = "string"
    })
    local projectRoot = settings.get("KGinfractions.root")
    return "/"..fs.combine(projectRoot, ...)
end
local completion = require"cc.completion"
local mainPath = combinePath("completion/username")
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