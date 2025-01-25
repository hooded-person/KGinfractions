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
if settings.get("KGinfractions.startup") then
    local projectRoot = settings.get("KGinfractions.root")
    shell.run("fg " .. fs.combine(projectRoot, "userFacing/viewDatabase.lua"))
end
