settings.define("KGinfractions.root", {
        description = "The program root",
        default = "/",
        type = "string"
    })
local projectRoot = settings.get("KGinfractions.root")


local completions = fs.list("/completion")
for i,v in ipairs(completions) do
    local filepath = "/completion/"..v.."/loop.lua"
    if fs.exists(filepath) then
        shell.openTab(fs.combine(projectRoot, filepath))
    end
end