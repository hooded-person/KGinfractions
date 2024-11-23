local completion = require"cc.completion"
local mainPath = "completion/deadline"
local filePath = fs.combine(mainPath,"times.lua")

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

local h = fs.open(filePath,"r")
if not h then
    error(er)
end
local times = textutils.unserialise(h.readAll())
h.close()

return function(text) return completion.choice(text,times) end