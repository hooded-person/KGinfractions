local args = { ... }
local auto = false
if args[1] == "-a" then auto = true, table.remove(args,1) end

local templateDir = "templates/"
if templateDir:sub(-1) ~= "/" then templateDir = templateDir .. "/" end

-- load and prepare templates
settings.define("kgTF.typeColors", {
    description = "Which colors too use for template types",
    default = {
        ["WARN"] = colors.orange,
        ["EVIC"] = colors.red,
        ["HIDE"] = colors.gray,
    },
    type = "table",
})
local typeColors = settings.get("kgTF.typeColors")
local templatesStrings = fs.list(templateDir)
--local templateExists = { {}, {} }
local templateListBuild = {
    ["type"] = {},
--    ["reason"] = {}
}
local templates = {}
for i, templatePath in ipairs(templatesStrings) do
    local validTemplate = templatePath:sub(-5) == ".sdoc" 
        and templatePath:sub(1,4) ~= "hide"
    if validTemplate then
        template = templatePath:gsub(".sdoc", "")
        local keywords = {}
        local str = template:gsub("^%U*", "")
        for wrd in str:gmatch("%u%U*") do
            table.insert(keywords, string.lower(wrd))
        end
        -- load template
        local h = fs.open(templateDir .. templatePath, "r")
        local templateContent = h.readAll()
        h.close()
        -- get data vars in template
        local dataVars = {}
        for match in templateContent:gmatch("<([^>]*)>") do
            table.insert(dataVars, match)
        end
        -- setup table
        typeIndex = string.upper(template:match("^%U*")) -- warn or evic
        if not templates[typeIndex] then templates[typeIndex] = {} end
        templates[typeIndex][table.concat(keywords, " ")] = {
            string.upper(template:match("^%U*")),
            table.concat(keywords, " "),
            dataVars,
            templatePath,
        }
        -- setup values while preventing duplicates
        templateListBuild["type"][typeIndex] = true
        --templateListBuild["reason"][table.concat(keywords, " ")] = true
    end
end
--error(textutils.serialise(templates))

-- building the values into the array
local templateList = {
    ["type"] = {},
--    ["reason"] = {}
}
for k, _ in pairs(templateListBuild["type"]) do
    table.insert(templateList["type"], k)
end

local selectedType = table.remove(args,1) -- "WARN"
local selectedTemp = table.concat(args," ") -- "no stock"
if not auto then
    print(selectedType)
    print(selectedTemp)
end

local template = templates[ selectedType ][selectedTemp]
if auto then
    return template
end
print(textutils.serialise(template))