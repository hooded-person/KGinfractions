local db = require "/database/addProcessing"

-- vars
local selection, running
local query = {
    enabled = false,
    queryFn = nil,
    history = {}
}
-- settings
settings.define("kgTF.typeColors", {
    description = "Which colors too use for template types",
    default = {
        ["WARN"] = colors.orange,
        ["EVIC"] = colors.red,
        ["HIDE"] = colors.gray,
    },
    type = "table",
})

-- aa
local popup = { show = false }
function popup:show()
    self.show = true
end

function popup:hide()
    self.hide = true
end

function popup:set(popupObj)
    self.content = popupObj
end

function popup:get()
    return self.content
end

-- handlers
local function makeHandler(handler, reason, type) -- what did i have in mind for reason and type? no idea
    return function(...)
        local args = { ... }
        local entry = args[1]
        -- vars
        local typeColors = settings.get("kgTF.typeColors")
        -- handler main design
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
        write("handling ")
        term.setTextColor(typeColors[entry.template[1]])
        write("[" .. entry.template[1] .. "] ") -- type
        term.setTextColor(colors.white)
        write(entry.template[2])                -- template/reason
        print(" for " .. entry.user)            -- username

        local results = { handler(typeColors, table.unpack(args)) }
        return table.unpack(results)
    end
end

local handleExpiredWarn = makeHandler(function(typeColors, entry, UUID)
    write("creating ")
    entry.template[1] = "EVIC" -- new type

    term.setTextColor(typeColors[entry.template[1]])
    write("[" .. entry.template[1] .. "] ") -- type
    term.setTextColor(colors.white)
    write(entry.template[2])                -- template/reason

    entry.deadline = -1
    entry.source = "H.handleExpiredWarn"
    entry.from = UUID
    db.add(entry) --push to db


    sleep(2)
end, "expired", "warn") -- what did i have in mind for these vars? no idea

-- boolean getter functions
local function isShown(item, barButtons)
    local showPending = barButtons[2].submenu[1].typeData.toggled
    local showHandled = barButtons[2].submenu[2].typeData.toggled
    local showExpired = barButtons[2].submenu[3].typeData.toggled
    if item.handled then
        return showHandled
    elseif item.deadline <=
        os.epoch("utc") /
        1000 -- if current epoch is more then the epoch of the deadline
        and item.deadline ~= -1 then
        return showExpired
    else
        return showPending
    end
end

-- main functions
local function renderDB(uuids, items, expandedUUID, expandedFormatData, sort, scroll, barButtons, selection)
    if expandedFormatData == nil then expandedFormatData = false end

    -- rendering
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)


    local typeColors = settings.get("kgTF.typeColors")

    term.setTextColor(colors.lightGray)
    write("type" .. (" "):rep(3)      -- 'type   '
        .. "template" .. (" "):rep(9) -- 'template         '
        .. "user" .. (" "):rep(6)     -- 'user      '
        .. "deadline"                 -- 'deadline'
    )                                 -- 'type   template         user      deadline'
    local sortPos = { type = 5, template = 16, user = 29, deadline = 43 }
    term.setCursorPos(sortPos[sort:sub(1, -2)], 1)
    write(({ [">"] = "/\\", ["<"] = "\\/" })[sort:sub(-1)])
    term.setCursorPos(1, 2)
    term.setTextColor(colors.white)
    local indexToUUID = {}
    local width, height = term.getSize()
    for i, uuid in ipairs(uuids) do
        if i > scroll and i - scroll + 1 < height and isShown(items[uuid], barButtons) then
            if selection:contains(uuid) then
                term.setBackgroundColor(colors.blue)
            else
                term.setBackgroundColor(colors.black)
            end
            term.clearLine()
            local entry = items[uuid] -- set entry
            local x, y = term.getCursorPos()
            local isExpired
            if entry.handled == nil then entry.handled = false end                -- force handled to be a boolean (sorta)
            -- printing text
            if entry.handled and not (expandedUUID and expandedUUID == uuid) then -- if handled and not expanded, everything light gray
                term.setTextColor(colors.lightGray)
                write("[" .. entry.template[1] .. "] ")                           -- type
                write(entry.template[2])                                          -- tempalte

                term.setCursorPos(25, y)
                write(entry.user) -- username

                term.setCursorPos(35, y)
                if entry.deadline ~= -1 then
                    write(os.date("%d/%m/%y", entry.deadline)) -- display deadline in 'DD/MM/YY'
                end
                term.setCursorPos(44, y)
                term.setTextColor(({ [true] = colors.lightGray, [false] = colors.white })[expandedUUID == uuid])
                write("[info]") -- 45 to 50
            else
                term.setTextColor(typeColors[entry.template[1]])
                write("[" .. entry.template[1] .. "] ")
                term.setTextColor(colors.white)
                write(entry.template[2])

                term.setCursorPos(25, y)
                write(entry.user)
                term.setCursorPos(35, y)
                isExpired = entry.deadline <=
                    os.epoch("utc") /
                    1000                                                                        -- if current epoch is more then the epoch of the deadline
                    and entry.deadline ~= -1                                                    -- handle no deadline
                term.setTextColor(({ [true] = colors.red, [false] = colors.white })[isExpired]) -- display expired deadlines
                if entry.handled then term.setTextColor(colors.lightGray) end                   -- if handled display in gray (and expanded ofcourse, otherwise everything is gray)
                if entry.deadline ~= -1 then
                    write(os.date("%d/%m/%y", entry.deadline))                                  -- display deadline in 'DD/MM/YY'
                end
                term.setCursorPos(44, y)
                term.setTextColor(({ [true] = colors.lightGray, [false] = colors.white })[expandedUUID == uuid])
                write("[info]") -- 44 to 49

                if entry.source then
                    term.setCursorPos(51, y)
                    write(entry.source:sub(1, 1):upper())
                    -- local sourcesMap = { ["^handle.*$"] = "H", ["selectMessage.lua"] = "M" }
                    -- for k, v in pairs(sourcesMap) do
                    --     if entry.source:find(k) ~= nil then
                    --         write(v)
                    --         break
                    --     end
                    -- end
                end
            end
            term.setTextColor(colors.white)
            table.insert(indexToUUID, uuid)

            -- expanded info
            if expandedUUID and expandedUUID == uuid then
                write("\n") -- newline for info page
                -- insert marker so skip this one and too correct offset made by info page.
                table.insert(indexToUUID, "buttonRow"); table.insert(indexToUUID, "selected")

                write("created: " .. os.date("%d/%m/%y", entry.time))
                term.setCursorPos(30, y + 1)
                if entry.handled then
                    term.setTextColor(colors.lime)
                    write("[handled]")
                else
                    term.setTextColor(({ [true] = colors.red, [false] = colors.gray })[isExpired])
                    write("[handle]")
                end
                term.setCursorPos(39, y + 1)
                term.setTextColor(({ [true] = colors.lightGray, [false] = colors.white })[expandedFormatData])
                write("[formatData]\n")
                term.setTextColor(colors.white)

                if expandedFormatData then
                    for k, v in pairs(entry.formatData) do
                        table.insert(indexToUUID, "selected")
                        print("  " .. k .. " = " .. v)
                    end
                end

                term.setTextColor(colors.gray) -- uuid in gray cause its 'advanced info'
                if entry.from then write("from: " .. entry.from .. "\n") end
                write("uuid: " .. uuid)        -- display uuid at the bottom of info page
                term.setTextColor(colors.white)
            end
            -- end with newline
            write("\n")
        end
    end
    return expandedUUID, expandedFormatData, indexToUUID
end

local ButtonLib = {}
ButtonLib.getLabel = function(button, subMenu)
    local prefix = ""
    local sufix = ""
    if subMenu then
        local containsType = {}
        local longest = 0
        for i, v in ipairs(subMenu) do
            if v.type then containsType[v.type] = true end
            if #v.label > longest then longest = #v.label end
        end
        prefix = containsType.toggle and "    " or ""
        sufix = (containsType.menu and "  " or "") ..
            (" "):rep(longest - #button.label)
    end

    if not button.type or button.type == "normal" then
        return prefix .. button.label .. sufix
    elseif button.type == "toggle" then
        return "[" .. (button.typeData.toggled and "*" or " ") .. "] " .. button.label
    elseif button.type == "menu" then
        return button.label .. " >"
    end
end
-- if selection:size() == 0 then return false end
local function renderBottomBar(barButtons)
    term.setBackgroundColor(colors.gray)
    local width, height = term.getSize()
    term.setCursorPos(1, height)
    term.clearLine()
    if not query.enabled then
        for i, button in ipairs(barButtons) do
            if button.expanded and i ~= barButtons.newExpanded then barButtons[i].expanded = false end
            if button.expanded then
                local x, y = term.getCursorPos()
                term.setTextColor(colors.black)
                term.setBackgroundColor(colors.lightGray)

                local menuTop = y - #button.submenu - 1
                button.submenu.pos = { x, menuTop + 1 }
                button.submenu.size = { 0, #button.submenu }
                for i, subButton in ipairs(button.submenu) do
                    term.setCursorPos(x, menuTop + i)
                    if subButton.expanded then term.setBackgroundColor(colors.white) end
                    local label = ButtonLib.getLabel(subButton, button.submenu)
                    write(label)
                    if #label > button.submenu.size[1] then button.submenu.size[1] = #label end
                    term.setBackgroundColor(colors.lightGray)
                end
                term.setCursorPos(x, y)
                write(button.label)
                barButtons[i] = button
            else
                term.setTextColor(colors.white)
                term.setBackgroundColor(colors.gray)
                write(button.label)
            end
            term.setBackgroundColor(colors.gray)
            write(" ")
        end
        local x = width - 14 - #tostring(selection:size()) -- length of "selecting "(10) - 1 + length of " exit"(5)
        term.setCursorPos(x, height)
        if selection:isSelecting() or selection:size() ~= 0 then
            term.setTextColor(colors.black)
            term.setBackgroundColor(colors.lightBlue)
            write(selection:isSelecting() and "selecting " or "selected  ")
            write(tostring(selection:size()))
        else
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.blue)
            write("  select   ")
        end
    else
        term.setCursorPos(1, height)
        term.blit("query\x9d", "00000b", "bbbbb8")
        term.setBackgroundColor(colors.lightGray)
        write((" "):rep(width - 13))
        term.blit("\x9d", "8", "7")
    end
    term.setCursorPos(width - 4, height)
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.red)
    write(" exit")

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    return barButtons
end

local function containsExpandedButton(buttonMenu, indexList)
    if not indexList then indexList = {} end
    local expandedButton
    for i, button in ipairs(buttonMenu) do
        if button.expanded then
            expandedButton = containsExpandedButton(button.submenu, table.insert(indexList, 1, i)) -- allow for pushing changes back to starting menu
            if expandedButton then
                return expandedButton
            else
                return button
            end
        end
    end
    return nil
end

local function restoreBackToMain(button, indexList)
    local buttonMenu
    for i, v in ipairs(indexList) do

    end
    return buttonMenu
end

local function captureInputForDB(items, indexToUUID, sort, scroll, uuids, barButtons, selection, expandedUUID,
                                 expandedFormatData)
    local width, height = term.getSize()
    local results = { os.pullEvent() }
    if query.enabled then
        local inputWindow = window.create(term.current(), 7, height, width - 13, 1)
        local oldTerm = term.current()
        term.redirect(inputWindow)
        --inputWindow.restoreCursor()
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.lightGray)
        term.clearLine()
        local queryInput = read(nil, query.history, nil, query.history[#query.history])
        if queryInput ~= "" then
            table.insert(query.history, queryInput)
            query.queryFn = load(
                "input=...; input.type=input.template[1]; input.template=input.template[2]; input.reason=input.template[2];_ENV = setmetatable({setmetatable = setmetatable}, {__index = input}) return " ..
                queryInput,
                "=query",
                "t", { setmetatable = setmetatable })
            selection:clear()
        else
            query.enabled = false
        end
        if query.enabled and query.queryFn then
            for i = 1, #uuids do
                local uuid = uuids[i]
                local success, res = pcall(query.queryFn, items[uuid])
                if success and res then
                    selection:add(uuid)
                end
            end
        else
            query.queryFn = nil
        end

        term.redirect(oldTerm)
    end
    if results[1] == "mouse_click" then
        -- is there an expanded button?
        local expandedButton, indexList = containsExpandedButton(barButtons)

        local event, button, x, y = table.unpack(results)
        if selection:isSelecting() and y > 1 and y < height then
            selection:startDrag(x, y)
            local clickedItem
            local offset = 0
            repeat
                clickedItem = indexToUUID[y - 1 + offset]
                if ({ selected = true, buttonRow = true })[clickedItem] then
                    offset = offset - 1
                end
            until not ({ selected = true, buttonRow = true })[clickedItem]
            selection:toggle(clickedItem)
            return expandedUUID, expandedFormatData, sort, scroll, barButtons
        elseif selection:isSelecting() and (y == 1 or y == height) and x <= width - 16 then
            selection:isSelecting(false)
        end
        -- expanded button thing | if the button is expanded process click, or close the menu and return
        if expandedButton and x >= expandedButton.submenu.pos[1] and x <= (expandedButton.submenu.pos[1] + expandedButton.submenu.size[1]) and y >= expandedButton.submenu.pos[2] and y < height then
            local i = y - expandedButton.submenu.pos[2] + 1
            local clickedButton = expandedButton.submenu[i]
            if not clickedButton.type or clickedButton.type == "normal" then
                clickedButton.click()
            elseif clickedButton.type == "toggle" then
                clickedButton.typeData.toggled = not clickedButton.typeData.toggled
            elseif clickedButton.type == "menu" then
                -- just no, i ain't nesting the menu's
            end
            --expandedButton.submenu[i] = clickedButton
            --barButtons = restoreBackToMain(expandedButton, indexList)
        elseif expandedButton and y ~= height then
            barButtons.newExpanded = 0
            return expandedUUID, expandedFormatData, sort, scroll, barButtons
        end
        -- info button
        if button == 1 and x >= 44 and x <= 49 and y >= 2 and y <= #indexToUUID + 1 and not ({ selected = true, buttonRow = true })[indexToUUID[y - 1]] then
            if expandedUUID == indexToUUID[y - 1] then
                expandedUUID = nil
            else
                expandedUUID = indexToUUID[y - 1]
            end
            expandedFormatData = false

            -- formatData button
        elseif button == 1 and x >= 39 and x <= 50 and y >= 2 and y <= #indexToUUID + 1 and indexToUUID[y - 1] == "buttonRow" then
            expandedFormatData = not expandedFormatData

            -- handle button
        elseif button == 1 and x >= 30 and x <= 38 and y >= 2 and y <= #indexToUUID + 1 and indexToUUID[y - 1] == "buttonRow" and items[indexToUUID[y - 2]].deadline ~= -1 and items[indexToUUID[y - 2]].deadline <= os.epoch("utc") / 1000 and not items[indexToUUID[y - 2]].handled then
            if items[indexToUUID[y - 2]].template[1] == "WARN" then
                handleExpiredWarn(items[indexToUUID[y - 2]], indexToUUID[y - 2])
            end

            -- sorting buttons
        elseif button == 1 and y == 1 and x >= 1 and x <= 5 then   -- type
            sort = (sort == "type>") and "type<" or "type>"
        elseif button == 1 and y == 1 and x >= 8 and x <= 16 then  -- template
            sort = (sort == "template>") and "template<" or "template>"
        elseif button == 1 and y == 1 and x >= 25 and x <= 29 then -- user
            sort = (sort == "user>") and "user<" or "user>"
        elseif button == 1 and y == 1 and x >= 35 and x <= 43 then -- deadline
            sort = (sort == "deadline>") and "deadline<" or "deadline>"
        elseif button == 1 and y == height and x >= width - 4 then -- exit button
            term.clear()
            term.setCursorPos(1, 1)
            print("Successfully closed database interface")
            running = false
        elseif button == 1 and y == height and x >= width - 15 and x <= width - 5 and not selection:isSelecting() then
            selection:isSelecting(true)
        elseif not query.enabled and button == 1 and y == height then -- bottom bar
            local buttonI
            local backlog = 0
            for i, v in ipairs(barButtons) do -- find clicked button
                backlog = backlog + #v.label
                if x <= backlog then
                    buttonI = i
                    break
                end
                backlog = backlog + 1
            end
            if not buttonI then return expandedUUID, expandedFormatData, sort, scroll, barButtons end
            if barButtons[buttonI].click then
                barButtons[buttonI].click()
                --barButtons.newExpanded = nil
            end
            if barButtons[buttonI].submenu then
                barButtons[buttonI].expanded = true
                barButtons.newExpanded = buttonI
            end
        end
    elseif results[1] == "mouse_drag" then
        local event, button, x, y = table.unpack(results)
        if selection:hasDrag() and selection:isSelecting() and y > 1 and y < height then
            local oldDrag = selection:moveDrag(x, y)
            if oldDrag[2] ~= y then
                local y, y1, y2 = selection:getDragY(3)

                local indexList = (y == y2) and { y, y1 } or { y }
                --local dir = (startY > y) and -1 or 1
                for _, i in ipairs(indexList) do
                    local clickedItem
                    local offset = 0
                    repeat
                        clickedItem = indexToUUID[i - 1 + offset]
                        if ({ selected = true, buttonRow = true })[clickedItem] then
                            offset = offset - 1
                        end
                    until not ({ selected = true, buttonRow = true })[clickedItem]
                    selection:toggle(clickedItem)
                end
            end
        end
    elseif results[1] == "mouse_up" then
        local event, button, x, y = table.unpack(results)
        if selection:hasDrag() and selection:isSelecting() and y > 1 and y < height then
            local startX, startY = selection:endDrag()
        end
    elseif results[1] == "mouse_scroll" then
        local event, dir, x, y = table.unpack(results)
        scroll = scroll + dir
        if scroll < 0 then
            scroll = 0
        elseif scroll >= #uuids then
            scroll = #uuids - 1
        end
    end
    return expandedUUID, expandedFormatData, sort, scroll, barButtons
end

local function getBarButtons(selection)
    local barButtons
    barButtons = {
        {
            label = "New",
            type = "menu",
            submenu = { {
                label = "Issue",
                click = function()
                    local func, err = loadfile("/userFacing/selectMessage.lua", nil, _ENV)
                    if err then
                        error(err)
                    elseif func == nil then
                        error("function from file '/userFacing/selectMessage.lua' is nil but no error was given")
                    end
                    func()
                end,
            },{
                label = "Template",
                click = function()
                    local func, err = loadfile("/userFacing/createTemplate.lua", nil, _ENV)
                    if err then
                        error(err)
                    elseif func == nil then
                        error("function from file '/userFacing/createTemplate.lua' is nil but no error was given")
                    end
                    func()
                end,
            },
            },
        },
        {
            label = "View",
            type = "menu",
            submenu = { {
                label = "Pending",
                type = "toggle",
                typeData = { toggled = true },
                click = function() end,
            }, {
                label = "Handled",
                type = "toggle",
                typeData = { toggled = true },
                click = function() end,
            }, {
                label = "Expired",
                type = "toggle",
                typeData = { toggled = true },
                click = function() end,
            },
            },
            expanded = false,
        },
        {
            label = "Selection",
            type = "menu",
            submenu = { {
                label = "Select",
                type = "normal",
                click = function()
                    selection:isSelecting(true)
                    barButtons.newExpanded = nil
                end,
            }, {
                label = "Query",
                type = "normal",
                click = function()
                    -- how tf we gonna do dis
                    query.enabled = true
                    -- rest of this is in captureInputForDB() because a rerender is needed first
                    barButtons.newExpanded = nil
                end,
            }, {
                label = "Deselect",
                type = "normal",
                click = function() selection:clear() end,
            },
            },
            expanded = false,
        },
        {
            label = "Entries",
            type = "menu",
            submenu = { {
                label = "rePrint",
                type = "normal",
                click = function()
                    if selection:size() == 0 then return false end
                    for i, uuid in ipairs(selection:get()) do
                        term.clear()
                        term.setCursorPos(1, 1)
                        term.setTextColor(colors.white)
                        term.setBackgroundColor(colors.black)
                        local entry = db.get(uuid)
                        local template = loadfile("/main/getTemplate.lua")("-a", entry.template[1], entry.template[2])
                        local formatData = entry.formatData
                        require("/main/printMessage")(template, formatData, "M.re-print", true)
                    end
                    selection:clear()
                end,
            }, {
                label = "Modify",
                type = "normal",
                click = function()
                    if selection:size() == 0 then return false end
                    local func, err = loadfile("/main/modifyDBentries.lua", nil, _ENV)
                    if func then
                        func(selection:get())
                    else
                        error(err)
                    end
                    selection:clear()
                end,
            }, {
                label = "Delete",
                type = "normal",
                click = function()
                    if selection:size() == 0 then return false end
                    for i, uuid in ipairs(selection:get()) do
                        db.set(uuid, nil)
                    end
                    selection:clear()
                end,
            },
            },
            expanded = false,
        },
        newExpanded = nil,
    }
    return barButtons
end

local function displayDB()
    -- defaults
    local indexToUUID = {} -- for keeping track of rows and clicks
    local expandedUUID, expandedFormatData = nil, false
    local items, uuids
    -- manage selection
    selection = require("/libs/selectionManager"):new() -- add an tracking var too the selection to know when too do shit
    -- vars for sorting
    local function sortFuncGen(sortFunc)
        return function(...)
            local a, b = ...
            local result, same = sortFunc(a, b)
            if same and not (items[b].handled and items[a].handled) then
                return items[b].handled -- put handled items at the bottom
            else
                return result
            end
        end
    end

    local sortFuncs = {
        ["type<"] = sortFuncGen(function(a, b)
            return items[a].template[1] < items[b].template[1],
                items[a].template[1] == items[b].template[1]
        end), -- Ascending
        ["type>"] = sortFuncGen(function(a, b)
            return items[a].template[1] > items[b].template[1],
                items[a].template[1] == items[b].template[1]
        end), -- Descending
        ["template<"] = sortFuncGen(function(a, b)
            return items[a].template[2] < items[b].template[2],
                items[a].template[2] == items[b].template[2]
        end), -- Ascending
        ["template>"] = sortFuncGen(function(a, b)
            return items[a].template[2] > items[b].template[2],
                items[a].template[2] == items[b].template[2]
        end),                                                                                                             -- Descending
        ["user<"] = sortFuncGen(function(a, b) return items[a].user < items[b].user, items[a].user == items[b].user end), -- Ascending
        ["user>"] = sortFuncGen(function(a, b) return items[a].user > items[b].user, items[a].user == items[b].user end), -- Descending
        ["deadline<"] = sortFuncGen(function(a, b)
            return items[a].deadline < items[b].deadline,
                items[a].deadline == items[b].deadline
        end), -- Ascending
        ["deadline>"] = sortFuncGen(function(a, b)
            return items[a].deadline > items[b].deadline,
                items[a].deadline == items[b].deadline
        end), -- Descending
    }
    for k, v in pairs(sortFuncs) do
        sortFuncs[k] = function(items)
            return v
        end
    end
    local sort = "type<"

    -- vars for bottom bar (is big table, so moved to dif function)
    local barButtons = getBarButtons(selection)

    -- defaults for scrolling
    local scroll = 0
    -- loop
    running = true
    while running do
        uuids = {} -- for sorting
        items = db.get()
        for uuid, _ in pairs(items) do table.insert(uuids, uuid) end
        table.sort(uuids, sortFuncs[sort](items))

        expandedUUID, expandedFormatData, indexToUUID = renderDB(uuids, items, expandedUUID, expandedFormatData, sort,
            scroll, barButtons, selection) -- rendering

        barButtons = renderBottomBar(barButtons)

        expandedUUID, expandedFormatData, sort, scroll, barButtons = captureInputForDB(items, indexToUUID, sort, scroll,
            uuids,
            barButtons, selection, expandedUUID, expandedFormatData)
    end
end

displayDB()
