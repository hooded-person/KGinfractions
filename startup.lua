--[[
=====[ better startup ]=====
--]]
local nameThing = "--[[\n=====[ better startup ]=====\n--]]"
local sBasePath = "/startupScripts/"
local tPrioStartups = {} -- startups that will be ran first, in order of suplied
local tPostStartups = {}                          -- startups that will be ran last, in order of suplied
local tStartups = {}
local isSpecialStartup = {}

local function doIgnore(filePath)
    local h = fs.open(filePath)
    for _i=1,#nameThing do 
        local c  = nameThing:sub(i,i)
        if h.read() ~= h then return false end
    end
    return true
end

if settings.get("KGinfractions.startup") then
    table.insert(tPrioStartups,"loadUserInterface.lua")
end

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
        if not doIgnore(v) then
            shell.run(v)
        end
    end
end
