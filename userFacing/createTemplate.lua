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

local function checkValidType(str)
    local validChars = "qwertyuiopasdfghjklzxcvbnm1234567890"
    for i = 1, #str do
        if not validChars:find(str:sub(i, i), 1, true) then
            return false, str:sub(i, i)
        end
    end
    return true
end

centerTxt("[template creator]", "=")
repeat
    local valid = true
    print("Enter template type (4 chars)")
    local input = read()
    if #input ~= 4 then
        valid = false
        print("Please enter a type with a length of 4")
    end
    local isValid, invalidChar = checkValidType(input)
    if not isValid then
        valid = false
        print(("Please only use alphanumerical characters, '%s' is invalid"):format(invalidChar))
    end
until valid
