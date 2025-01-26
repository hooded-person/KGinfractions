local args = { ... }
local showHidden = args[1] or "false"
showHidden = ({["true"]=true, ["false"]=false})[showHidden]

local function name(name) local namespace = "KGtemplateForge"; return namespace.."."..name end
settings.define(name("typeColors"), {
    description = "Which colors too use for template types",
    default = {
        ["WARN"] = colors.orange,
        ["EVIC"] = colors.red,
        ["HIDE"] = colors.gray,
    },
    type = "table",
})

local typeColors = settings.get(name("typeColors"))
local templates = fs.list("/templates/")
table.sort(templates)

local formatedTable = {}
for _, template in ipairs(templates) do
    if showHidden or template:sub(1,4) ~= "hide" then
        if type(formatedTable[template:sub(1,4):upper()]) ~= "table" then formatedTable[template:sub(1,4):upper()] = {} end
        table.insert(formatedTable[template:sub(1,4):upper()],template)
    end
end
local formatedList = {}
for k,v in pairs(formatedTable) do
    table.sort(v)
    table.insert(formatedList,typeColors[k])
    table.insert(formatedList,v)
end

textutils.pagedTabulate(table.unpack(formatedList))
