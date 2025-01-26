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
local mainPath = combinePath("completion/deadline")
local filePath = fs.combine(mainPath,"times.lon")

local times = {}
--[[
local conversionTable = {
    ["d"] = 24 * 60 * 60,
    ["w"] = 7 * 24 * 60 * 60,
}
for k,v in pairs(conversionTable) do
    local limit = 9
    if k == "s" or k=="m" then limit = 60 end
    for i=1,limit do
        table.insert(times,i..k)
    end
end
local h=fs.open(filePath,"w")
h.write(textutils.serialise(times))
h.close()--]]

local h, err = fs.open(filePath,"r")
if not h then
    error(err)
end
local times = textutils.unserialise(h.readAll())
h.close()

return function(text) return completion.choice(text,times) end