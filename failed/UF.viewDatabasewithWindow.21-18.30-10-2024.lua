local db = require "/database/addProcessing"

settings.define("kgTF.typeColors", {
    description = "Which colors too use for template types",
    default = {
        ["WARN"] = colors.orange,
        ["EVIC"] = colors.red,
        ["HIDE"] = colors.gray,
    },
    type = "table",
})
-- QOL functions
function fakeLoading(data) -- debug print that waits for a couple seconds so you can read it, for no reason whats o ever
    local text = data[1] or ""
    local time = data.time or 2

    parallel.waitForAny(
        function() -- rendering funky loading bar
            local x, y = term.getCursorPos()
            local list = { "|", "/", "-", "\\" }
            local i = 1
            write(list[1] .. " " .. text)
            while true do
                sleep(0.1)
                i = i + 1
                if i > #list then i = 1 end
                term.setCursorPos(x, y)
                write(list[i])
            end
        end,
        function() sleep(time) end -- actuall time
    )
end

-- handlers
function makeHandler(handler, reason, type) -- what did i have in mind for reason and type? no idea
    return function(...)
        local args = { ... }
        -- get windows too hide during execution 
        local windows
        if type( args[#args] ) == "table" then windows = table.remove(args) end
        if type( windows.write ) == "function" then windows = {windows} end
        for i,window in ipairs(windows) do 
            if not window.isVisible() then table.remove(windows,i) end -- do not redisplay windows that where hidden when suplied
            window.setVisible(false) -- hide the windows given
        end 
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

        for i,window in ipairs(windows) do window.setVisible(true) end -- redisplay the windows given
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
    entry.source = "handleExpiredWarn"
    entry.from = UUID
    db.add(entry) --push to db

    sleep(2)
end, "expired", "warn") -- what did i have in mind for these vars? no idea

-- main functions
function renderDB(listWin, uuids, items, expandedUUID, expandedFormatData, sort)
    if expandedFormatData == nil then expandedFormatData = false end

    -- rendering
    listWin.setTextColor(colors.white)
    listWin.clear()
    listWin.setCursorPos(1, 1)


    local typeColors = settings.get("kgTF.typeColors")

    listWin.setTextColor(colors.lightGray)
    write("type" .. (" "):rep(3)      -- 'type   '
        .. "template" .. (" "):rep(9) -- 'template         '
        .. "user" .. (" "):rep(6)     -- 'user      '
        .. "deadline"                 -- 'deadline'
    )                                 -- 'type   template         user      deadline'
    local sortPos = { type = 5, template = 16, user = 29, deadline = 43 }
    listWin.setCursorPos(sortPos[sort:sub(1, -2)], 1)
    write(({ [">"] = "/\\", ["<"] = "\\/" })[sort:sub(-1)])
    listWin.setCursorPos(1, 2)
    listWin.setTextColor(colors.white)
    local indexToUUID = {}
    for i, uuid in ipairs(uuids) do
        entry = items[uuid] -- set entry
        local x, y = listWin.getCursorPos()
        local isExpired
        if entry.handled == nil then entry.handled = false end                -- force handled to be a boolean (sorta)
        -- printing text
        if entry.handled and not (expandedUUID and expandedUUID == uuid) then -- if handled and not expanded, everything light gray
            listWin.setTextColor(colors.lightGray)
            write("[" .. entry.template[1] .. "] ")                           -- type
            write(entry.template[2])                                          -- tempalte

            listWin.setCursorPos(25, y)
            write(entry.user) -- username

            listWin.setCursorPos(35, y)
            if entry.deadline ~= -1 then
                write(os.date("%d/%m/%y", entry.deadline)) -- display deadline in 'DD/MM/YY'
            end
            listWin.setCursorPos(44, y)
            listWin.setTextColor(({ [true] = colors.lightGray, [false] = colors.white })[expandedUUID == uuid])
            write("[info]") -- 45 to 50
        else
            listWin.setTextColor(typeColors[entry.template[1]])
            write("[" .. entry.template[1] .. "] ")
            listWin.setTextColor(colors.white)
            write(entry.template[2])

            listWin.setCursorPos(25, y)
            write(entry.user)
            listWin.setCursorPos(35, y)
            isExpired = entry.deadline <=
                os.epoch("utc") /
                1000                                                                        -- if current epoch is more then the epoch of the deadline
                and entry.deadline ~= -1                                                    -- handle no deadline
            listWin.setTextColor(({ [true] = colors.red, [false] = colors.white })[isExpired]) -- display expired deadlines
            if entry.handled then listWin.setTextColor(colors.lightGray) end                   -- if handled display in gray (and expanded ofcourse, otherwise everything is gray)
            if entry.deadline ~= -1 then
                write(os.date("%d/%m/%y", entry.deadline))                                  -- display deadline in 'DD/MM/YY'
            end
            listWin.setCursorPos(44, y)
            listWin.setTextColor(({ [true] = colors.lightGray, [false] = colors.white })[expandedUUID == uuid])
            write("[info]") -- 44 to 49

            if entry.source then
                listWin.setCursorPos(51,y)
                local sourcesMap = {["^handle.*$"]="H",["selectMessage.lua"]="M"}
                for k,v in pairs(sourcesMap) do 
                    if entry.source:find(k) ~= nil then 
                        write(v)
                        break
                    end
                end
            end
        end
        listWin.setTextColor(colors.white)
        table.insert(indexToUUID, uuid)

        -- expanded info
        if expandedUUID and expandedUUID == uuid then
            write("\n") -- newline for info page
            -- insert marker so skip this one and too correct offset made by info page.
            table.insert(indexToUUID, "buttonRow"); table.insert(indexToUUID, "selected")

            write("created: " .. os.date("%d/%m/%y", entry.time))
            listWin.setCursorPos(30, y + 1)
            if entry.handled then
                listWin.setTextColor(colors.lime)
                write("[handled]")
            else
                listWin.setTextColor(({ [true] = colors.red, [false] = colors.gray })[isExpired])
                write("[handle]")
            end
            listWin.setCursorPos(39, y + 1)
            listWin.setTextColor(({ [true] = colors.lightGray, [false] = colors.white })[expandedFormatData])
            write("[formatData]\n")
            listWin.setTextColor(colors.white)

            if expandedFormatData then
                for k, v in pairs(entry.formatData) do
                    table.insert(indexToUUID, "selected")
                    print("  " .. k .. " = " .. v)
                end
            end

            listWin.setTextColor(colors.gray) -- uuid in gray cause its 'advanced info'
            if entry.from then write("from: " .. entry.from.."\n") end
            write("uuid: " .. uuid)        -- display uuid at the bottom of info page
            listWin.setTextColor(colors.white)
        end
        -- end with newline
        write("\n")
    end
    return expandedUUID, expandedFormatData, indexToUUID
end

function captureInputForDB(listWin, items, indexToUUID, sort)
    local event, button, x, y = os.pullEvent("mouse_click")
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
            handleExpiredWarn(items[indexToUUID[y - 2]], indexToUUID[y - 2], listWin)
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
    end
    return expandedUUID, expandedFormatData, sort
end

function displayDB()
    -- defaults
    local indexToUUID = {} -- for keeping track of rows and clicks
    local expandedUUID, expandedFormatData = nil, false
    local items, uuids
    local sortFuncs = {
        ["type<"] = function(a, b) return items[a].template[1] < items[b].template[1] end,     -- Ascending
        ["type>"] = function(a, b) return items[a].template[1] > items[b].template[1] end,     -- Descending
        ["template<"] = function(a, b) return items[a].template[2] < items[b].template[2] end, -- Ascending
        ["template>"] = function(a, b) return items[a].template[2] > items[b].template[2] end, -- Descending
        ["user<"] = function(a, b) return items[a].user < items[b].user end,                   -- Ascending
        ["user>"] = function(a, b) return items[a].user > items[b].user end,                   -- Descending
        ["deadline<"] = function(a, b) return items[a].deadline < items[b].deadline end,       -- Ascending
        ["deadline>"] = function(a, b) return items[a].deadline > items[b].deadline end,       -- Descending
    }
    for k, v in pairs(sortFuncs) do
        sortFuncs[k] = function(items)
            return v
        end
    end
    local sort = "type<"
    -- viewing window
    local width, height = term.getSize()
    local listWin = window.create(term.current(), 1, 1, width, height-1)
    -- loop
    while true do
        uuids = {} -- for sorting
        items = db.get()
        for uuid, _ in pairs(items) do table.insert(uuids, uuid) end
        table.sort(uuids, sortFuncs[sort](items))
        --print(textutils.serialise(uuids))
        --sleep(1)

        expandedUUID, expandedFormatData, indexToUUID = renderDB(listWin, uuids, items, expandedUUID, expandedFormatData, sort) -- rendering

        expandedUUID, expandedFormatData, sort = captureInputForDB(listWin, items, indexToUUID, sort)
    end
end

displayDB()