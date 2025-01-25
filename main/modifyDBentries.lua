-- v: 1.1
error("Due to risks of corrupting the db this feature has been disabled")

local db = require "../database"

local args = { ... }
assert(#args <= 1,
    "To many arguments. Got " .. #args .. ", expected 0 to 1. Provide the selected entry uuids as a (serialised) table")
local arg = args[1]
if #args == 1 then
    assert(type(arg) == "table" or type(arg) == "string", "Provided argument is neither a table nor a string")
    if type(arg) == "string" then arg = textutils.unserialise(arg) end
    assert(arg, "The provided string could not be unserialised to a table")
else
    term.setTextColor(colors.red)
    print("Manual entry selecting has not been implemented.")
    term.setTextColor(colors.white)
    local input
    local looped = false
    repeat
        if looped then
            term.setTextColor(colors.red)
            print("please input 'y' or 'n'")
            term.setTextColor(colors.white)
        end
        print("Would you like to open the db viewer? (y/n)")
        input = read()
        looped = true
    until input == "y" or input == "n"
    if input == "y" then
        shell.run(require("./makePath")("/userFacing/viewDatabase"))
    end
    error("")
end

local entryUuids = arg
--[[
==================[ "temporary" system, don't know how this should actually look with multiple. ]==================
--]]
assert(#entryUuids == 1,
    [[a "temporary" system has been implemented, limiting to 1 entry. Don't know how this should actually look with multiple.]])

-- preview of how an entry might look (for easy of development)
local entryItemsTable = {
    template = {
        "WARN",
        "illegal item",
    },
    user = "4Rust_CZ",
    time = 1730578013.739,
    deadline = 1730895132,
    formatData = {
        date = "30/10/2024",
        deadline = "06/11/2024",
        item = "a",
        user = "4Rust_CZ",
    },
    source = "M.re-print",
    templateFile = "warnIllegalItem.sdoc",
}
-- entry items in order of display
local entryItems = {
    "template",
    "user",
    "time",
    "deadline",
    "formatData",
    "source",
    "templateFile",
}
local rowTracking = {}

term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)
local entry = db.get(entryUuids[1])

local function prepareValue(value)
    if type(value) == "string" then
        term.setTextColor(colors.red)
        return '"' .. value .. '"'
    elseif type(value) == "boolean" then
        local booleanColor = {
            [true] = colors.green,
            [false] = colors.red,
        }
        term.setTextColor(booleanColor[value])
        return value
    elseif type(value) == "number" then
        term.setTextColor(colors.magenta)
        return value
    elseif type(value) == "nil" then
        term.setTextColor(colors.lightGray)
        return value
    else
        term.setTextColor(colors.white)
        return value
    end
end

local function printValue(value)
    value = prepareValue(value)
    print(value)
    term.setTextColor(colors.white)
end
---@param loopTable table
---@param trackTable table
---@param depth? number
---@param maxDepth? number
---@return nil
local function showTable(loopTable, trackTable, depth, maxDepth)
    depth = depth or 0
    maxDepth = maxDepth or -1

    if depth == 0 then
        for _, key in ipairs(loopTable) do
            local seperator = type(key) == "string" and "." or ","
            table.insert(trackTable, { seperator .. key, #tostring(key) + 3 })
            local value = entry[key]
            write(key)
            write(" = ")
            if type(value) == "table" then
                print("{")
                showTable(value, trackTable, depth + 1, maxDepth)
                table.insert(trackTable, { "}", nil })
                print("}")
            else
                printValue(value)
            end
        end
    else
        local backtrackI = #trackTable
        for key, value in pairs(loopTable) do
            local keyStr = (type(key) == "number") and "[" .. key .. "]" or key
            local seperator = type(key) == "string" and "." or ","
            local trackStr = trackTable[backtrackI][1] .. seperator .. key
            table.insert(trackTable, { trackStr, depth * 2 + #keyStr + 3 })

            write(("  "):rep(depth or 0))
            write(keyStr)
            write(" = ")
            if type(value) == "table" then
                print("{")
                showTable(value, trackTable, depth + 1, maxDepth)
                table.insert(trackTable, { "}", nil })
                print("}")
            else
                printValue(value)
            end
        end
    end
end

local function getInput(entry, rowTracking)
    local event, button, x, y = os.pullEvent("mouse_click")
    local clickedItem = rowTracking[y]
    if clickedItem[1] == "}" then return false end

    print(clickedItem[1])
    
    local query = ""
    for typeChar, match in clickedItem[1]:gmatch("([.,])([^.,]*)") do
        if typeChar == "." then
            match = '["' .. match .. '"]'
        elseif typeChar == "," then
            match = '[' .. match .. ']'
        end
        query = query .. match
    end
    print("LINE 168")
    local functionTxt = "return searchingTable" .. query
    print(functionTxt)
    local currentValue = load(functionTxt, "=generatedIndexing", "t", { searchingTable = entry })()
    print("LINE 171")
    
    --print(clickedItem[1])
    term.setCursorPos(clickedItem[2] + 1, y)
    local preparedValue = prepareValue(currentValue)
    local newValue = read(nil, nil, nil, tostring(preparedValue))
    term.setTextColor(colors.white)

    local func, err = load("searchingTable" .. query .. " = " .. newValue .. ";return searchingTable", "=generatedIndexing", "t",
        { searchingTable = entry })
    if err or func == nil then
        error(err)
    else
        entry = func()
    end
    return true
end

local running = true
while running do
    showTable(entryItems, rowTracking)
    local success = getInput(entry, rowTracking)
    if success then running = false end
end

db.set(entryUuids[1], entry)
