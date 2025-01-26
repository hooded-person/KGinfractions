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


local completions = fs.list(combinePath("/completion"))
for i,v in ipairs(completions) do
    local filepath = "/completion/"..v.."/loop.lua"
    if fs.exists(combinePath(filepath)) then
        shell.openTab(combinePath(filepath))
    end
end