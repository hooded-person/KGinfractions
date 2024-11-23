--[[
=====[ better startup ]=====
--]]
local sBasePath = "/startupScripts/"
local tPrioStartups = { "loadUserInterface.lua" } -- startups that will be ran first, in order of suplied
local tPostStartups = {}                          -- startups that will be ran last, in order of suplied
local tStartups = {}
local isSpecialStartup = {}

--
for _, v in ipairs(tPrioStartups) do
    local sPath = "/" .. fs.combine(sBasePath, v)
    isSpecialStartup[sPath] = true
end
for _, v in ipairs(tPostStartups) do
    local sPath = "/" .. fs.combine(sBasePath, v)
    isSpecialStartup[sPath] = true
end
-- add prio startups
for _, v in ipairs(tPrioStartups) do
    local sPath = "/" .. fs.combine(sBasePath, v)
    tStartups[#tStartups + 1] = sPath
end

-- add normal startups
local tFiles = fs.list(sBasePath)
for _, v in pairs(tFiles) do
    local sPath = "/" .. fs.combine(sBasePath, v)
    if not fs.isDir(sPath) then
        if not isSpecialStartup[sPath] then
            tStartups[#tStartups + 1] = sPath
        end
    end
end

-- add post startups
for _, v in ipairs(tPostStartups) do
    local sPath = "/" .. fs.combine(sBasePath, v)
    tStartups[#tStartups + 1] = sPath
end

if tStartups then
    for _, v in pairs(tStartups) do
        shell.run(v)
    end
end
