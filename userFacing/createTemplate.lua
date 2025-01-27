---@param ... string strings for paths to combine
---@return string
local function combinePath(...)
    settings.define("KGinfractions.root", {
        description = "The program root",
        default = "/",
        type = "string"
    })
    local projectRoot = settings.get("KGinfractions.root")
    return "/" .. fs.combine(projectRoot, ...)
end

local templateDir = combinePath("templates/")
-- load and prepare templates
settings.define("KGtemplateForge.typeColors", {
    description = "Which colors too use for template types",
    default = {
        ["WARN"] = colors.orange,
        ["EVIC"] = colors.red,
        ["HIDE"] = colors.gray,
    },
    type = "table",
})

term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

---@param message string The message too center
---@param encasingStr? string Optional string too repeat instead of " " on the sides
local function centerTxt(message, encasingStr)
    encasingStr = encasingStr or " "
    local w, h = term.getSize()
    local messageWidth = #message
    local encasingStrWidth = #encasingStr
    local remainingWidth = (w - messageWidth)
    local sideWitdh = remainingWidth / 2
    local sideRepetions = sideWitdh / encasingStrWidth
    local remainingsideWitdh = sideWitdh % encasingStrWidth
    local sideStrings = encasingStr:rep(sideRepetions) .. encasingStr:sub(0, remainingsideWitdh)
    local evenStr = messageWidth % 2 == 0 and encasingStr:sub(remainingsideWitdh + 1, remainingsideWitdh + 1) or ""
    print(sideStrings .. message .. sideStrings .. evenStr)
end

---@param str string String the check
---@param additionalValidChars? string Additional valid characters
---@return boolean valid Wether the string is valid
---@return string|nil invalidChar The character that was invalid
local function checkValidType(str, additionalValidChars)
    local alphabetic = "abcdefghijklmnopqrstuvwxyz"
    alphabetic = alphabetic .. alphabetic:upper()
    local numerical = "0123456789"
    local alphanumerical = alphabetic .. numerical
    local validChars = alphanumerical .. (additionalValidChars or "")
    for i = 1, #str do
        if not validChars:find(str:sub(i, i), 1, true) then
            return false, str:sub(i, i)
        end
    end
    return true
end


---@param templateType string Type of the template
---@param templateName string Name of the template
---@return boolean available Wether the template does not exist in file system
local function templateAvailable(templateType, templateName)
    local templateFileName = templateType .. templateName .. ".sdoc"
    return fs.exists(templateDir .. templateFileName)
end

centerTxt("[template creator]", "=")
local templateType
repeat -- template type
    local valid = true
    print("Enter template type (4 chars)")
    templateType = read()
    if #templateType ~= 4 then
        valid = false
        print("Please enter a type with a length of 4")
    end
    local isValid, invalidChar = checkValidType(templateType)
    if not isValid then
        valid = false
        print(("Please only use alphanumerical characters, '%s' is invalid"):format(invalidChar))
    end

    if valid then -- confirm the template type
        print(("template type: '%s', proceed? y/n"):format(templateType:upper()))
        local proceed = read():lower()
        valid = proceed == "y" or proceed == "yes"
    end
until valid

if settings.get("KGtemplateForge.typeColors")[templateType:upper()] == nil then
    local colorsL = { "white", "orange", "magenta", "lightBlue", "yellow", "lime", "pink", "gray", "lightGray", "cyan",
        "purple", "blue", "brown", "green", "red", "black" }
    local colorsT = {
        white = colors.white,
        orange = colors.orange,
        magenta = colors.magenta,
        lightBlue = colors.lightBlue,
        yellow = colors.yellow,
        lime = colors.lime,
        pink = colors.pink,
        gray = colors.gray,
        lightGray = colors.lightGray,
        cyan = colors.cyan,
        purple = colors.purple,
        blue = colors.blue,
        brown = colors.brown,
        green = colors.green,
        red = colors.red,
        black = colors.black
    }
    print("Template type '%s' does not have a color yet, would you like to asign a color? (empty for none)")
    local color = read(nil, nil, function(text) return require("cc.completion").choice(text, colorsL) end)
    if color ~= "" and colorsT[color] then
       local typeColors = settings.get("KGtemplateForge.typeColors")
       typeColors[templateType:upper()] = colorsT[color]
       settings.set("KGtemplateForge.typeColors", typeColors)
       settings.save()
    end
end



local templateName
repeat -- template name
    local valid = true
    print("Enter template name")
    templateName = read()
    local isValid, invalidChar = checkValidType(templateName, " _-")
    if not isValid then
        valid = false
        print(("Please only use alphanumerical characters or ' _-', '%s' is invalid"):format(invalidChar))
    end

    templateName = templateName:gsub("[_-]", " ")                    -- replace _ and - with spaces
        :gsub("(%l)(%w*)", function(a, b) return a:upper() .. b end) -- capitalize all words
        :gsub(" ", "")                                               -- remove spaces, now we have PascalCase

    local available = templateAvailable(templateType, templateName)
    if valid then -- confirm template name
        print(("template name: '%s', proceed? y/n"):format(templateName))
        local proceed = read():lower()
        valid = proceed == "y" or proceed == "yes"
    end
until valid

local templateFileName = templateType:lower() .. templateName .. ".sdoc"
local templateFilePath = fs.combine(templateDir, templateFileName)

local files = fs.list(templateDir)
local baseTemplates = { {}, {} }
for _, file in ipairs(files) do
    file = file:sub(1, -6)
    if file:sub(1, 4) == "hide" then
        table.insert(baseTemplates[1], file)
        baseTemplates[2][file] = true
    end
end
local function baseTemplatesCompFunc(str)
    return require("cc.completion").choice(str, baseTemplates[1])
end

local selectedBaseTemplate
repeat -- template name
    local valid = true
    print("Select a base template or '' for none")
    selectedBaseTemplate = read(nil, nil, baseTemplatesCompFunc)

    if not '' and not baseTemplates[2][selectedBaseTemplate] then
        valid = false
        print(("Please select one of the suggested templates or ''"))
    end

    if valid then -- confirm template name
        print(selectedBaseTemplate ~= '' and
            (("base template: '%s', proceed? y/n"):format(selectedBaseTemplate))
            or "no base template, proceed y/n")
        local proceed = read():lower()
        valid = proceed == "y" or proceed == "yes"
    end
until valid

if selectedBaseTemplate ~= "" then
    fs.copy(fs.combine(templateDir, selectedBaseTemplate .. ".sdoc"), templateFilePath)
elseif not fs.exists(templateFilePath) then
    local h = fs.open(templateFilePath, "w") -- create file
    h.write("shrekdoc-v02w25h21mR:")         -- add correct headers
    h.close()
end
print("launching sword.lua with " .. templateFilePath)
sleep(2)
shell.run(combinePath("/sword.lua") .. " " .. templateFilePath)
