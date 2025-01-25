settings.define("KGinfractions.startup", {
    description = "wether to launch user interface on startup",
    default = true,
    type = "boolean"
})
if settings.get("KGinfractions.startup") then
    shell.run("fg userFacing/viewDatabase.lua")
end