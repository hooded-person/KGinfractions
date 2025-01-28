settings.define("KGinfractions.startup", {
    description = "wether to launch user interface on startup",
    default = true,
    type = "boolean"
})
settings.define("KGinfractions.root", {
    description = "The program root",
    default = "/",
    type = "string"
})
local projectRoot = settings.get("KGinfractions.root")

shell.setAlias("viewDatabase", fs.combine(projectRoot, "userFacing/viewDatabase.lua"))
if settings.get("KGinfractions.startup") then
    shell.run("fg " .. fs.combine(projectRoot, "userFacing/viewDatabase.lua"))
end