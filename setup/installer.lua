-- v:6.3
---@type any
local args = {...}
args = table.concat(args," ")
args = textutils.unserialise(args)
args = args or {}
args.source = args.source or "installer"

---@param fgColor? number
---@param bgColor? number
---@param x? number
---@param y? number
local function clearTerm(fgColor, bgColor, x, y)
    fgColor = fgColor or colors.white
    bgColor = bgColor or colors.black
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(x or 1, y or 1)
end
clearTerm()

local fileHost = "https://raw.githubusercontent.com/";
local repoLoc = "hooded-person" .. "/" .. "KGinfractions";
local inbeteenShit = "/refs/heads/";
local file = "main/setup/prgmFiles.json";
local pgrmFilesURL = fileHost .. repoLoc .. inbeteenShit .. file;

local fsChanges = {}

local function progressBar(amount, max, barWidth)
    local fillPercentage = amount / max
    local w, h = term.getSize()
    local x, y = term.getCursorPos()
    barWidth = barWidth or w - x
    local bars = barWidth * 2
    local filledBars = fillPercentage * bars

    term.setTextColor(colors.gray)
    term.setBackgroundColor(colors.white)
    write((" "):rep(filledBars / 2))

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.gray)
    write(filledBars % 2 == 1 and "\x95" or "")

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.gray)
    write((" "):rep(((bars - filledBars) / 2) - (filledBars % 2)))

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end

-- aborting installation and rollback filesystem
local abort = { rollback = {} }
abort.rollback.new = function(fsChange)
    fs.delete(fsChange.path)
    print(("rolledback %s %s '%s'"):format(fsChange.action, fsChange.type, fsChange.path))
end
abort.rollback.move = function(fsChange)
    fs.move(fsChange.to, fsChange.from) -- was moved "fsChange.from" to "fsChange.to", now reversing that action
    print(("moved back '%s' to '%s'"):format(fsChange.to, fsChange.from))
end

local abortMeta = {}
abortMeta.__call = function() -- main abort function
    clearTerm(colors.red)
    print(" ABORTING INSTALATION")
    local width, height = term.getSize()
    term.setCursorPos(2, 2)
    term.clearLine()
    progressBar(0, #fsChanges, width - 2)
    term.setTextColor(colors.orange)
    for i, fsChange in ipairs(fsChanges) do
        local action = fsChange.action
        local type = fsChange.type -- file or directory
        term.setCursorPos(1, 4)
        term.clearLine()
        term.setCursorPos(1, 3)
        term.clearLine()
        abort.rollback[action](fsChange)
        term.setCursorPos(2, 2)
        term.clearLine()
        progressBar(i, #fsChanges, width - 2)
    end
    term.setCursorPos(1, 5)

    -- aborting installation finished
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    print("aborted installation")
    error("")
end
setmetatable(abort, abortMeta)
local errors = {}
errors.fatal = function(err)
    term.setTextColor(colors.red)
    print(err);
    print("Installation will be aborted")
    term.setTextColor(colors.white)
    sleep(3)
    abort()
end
errors.err = function(err)
    term.setTextColor(colors.red)
    print(err);
    term.setTextColor(colors.white)
    sleep(3)
end


---@param filePath string Path of new file
---@param fileContent string Content of the new file
---@return boolean success Wether file was made successfully
---@return string? error Error if file was not made successfully
local function makeFile(filePath, fileContent)
    local h, err = fs.open(filePath, "w")
    table.insert(fsChanges, { action = "new", type = "file", path = filePath })
    if err then return false, err end
    h.write(fileContent)
    h.close()
    return true
end
---@param path string Path for which to make the file
local function makeDir(path)
    if not fs.exists(path) then
        fs.makeDir(path)
        table.insert(fsChanges, { action = "new", type = "dir", path = path })
    end
end

local function warn(err)
    local oldColor = term.getTextColor()
    term.setTextColor(colors.red)
    print(err)
    term.setTextColor(oldColor)
end
---@param url string
---@param notFatal? boolean If false errors during getting of url will abort
---@return boolean success
---@return table responseData
local function getUrl(url, notFatal)
    local errSystem = notFatal and errors.err or errors.fatal
    local canRequest, err = http.checkURL(url);
    if not canRequest then
        errSystem(err);
        return false, { error = err }
    end;
    local response, err, failResponse = http.get({
        url = url,
    });
    if err and failResponse then
        response = failResponse;
    elseif err and not failResponse then
        errSystem(err)
        return false, { error = err }
    end;
    if response == nil then
        errSystem(err)
        return false, { error = err }
    end
    local statusCode = response.getResponseCode();
    local headers = response.getResponseHeaders();
    local body = response.readAll();
    response.close();
    if err then -- show http errors (will be double up with github, ex. "HTTP 404\n 404: not found")
        local errMsg = err .. "\nHTTP " .. statusCode .. " " .. url .. "\n" .. body;
        errSystem(errMsg);
        return false, {
            statusCode = statusCode,
            headers = headers,
            body = body
        };
    end;
    return not err, {
        statusCode = statusCode,
        headers = headers,
        body = body
    };
end


---@param url string the url to get json data from
---@return table jsonData unserialised JSON data
---@return table responseData full response data
local function getJsonData(url)
    local success, responseData = getUrl(url)
    local headers = responseData.headers
    local body = responseData.body

    if headers["Content-Type"] then
        assert(
            string.lower(headers["Content-Type"]) == "text/plain; charset=utf-8" or
            string.lower(headers["Content-Type"]) == "application/json; charset=utf-8",
            "unexpected content type,\nResponse header 'Content-Type' did not match 'text/plain; charset=utf-8', got:\n" ..
            headers["Content-Type"]
        );
    end

    local jsonData = textutils.unserialiseJSON(body);
    assert(jsonData ~= nil, "failed to unserialise response file");
    return jsonData, responseData
end

---@param url string The url from which to download the file
---@param filePath string The filepath to which to downlaod the file
---@param notify? boolean Wether to print what is happenening (lot of downloads after each other otherwise looks weird)
---@param notFatal? boolean Wether errors during download of this file are fatal
local function downloadFile(url, filePath, notify, notFatal)
    local success, responseData = getUrl(url, notFatal)
    if not success then return false end
    local body = responseData.body

    clearTerm()

    -- handle file existing
    if fs.exists(filePath) then
        warn(("The file '%s' already exists"):format(filePath))
        local input
        repeat
            print("Would you like to overwrite this file (THIS CAN NOT BE RESTORED). y/n")
            input = read()
        until input == "y" or input == "n"
        if input ~= "y" then
            ---@diagnostic disable-next-line: undefined-global
            abort()
        end
    end
    makeFile(filePath, body)
    term.setCursorPos(1, 3)
    term.clearLine()
    if notify then
        print(("downloaded '%s'"):format(filePath))
    end
end

local prgmFiles = getJsonData(pgrmFilesURL)

-- configure a project root
local success = false
local projectRoot
repeat
    print("Enter filepath for program location (or 'abort' to abort)")
    projectRoot = read()
    if projectRoot == "" then
        warn("please input a value")
    elseif projectRoot == "abort" then
        error("install aborted")
    elseif fs.isReadOnly(projectRoot) then
        warn("Path is read only")
        -- elseif projectRoot ~= "/" then
        --     warn("Currently only installing in root is supported")
    else
        projectRoot = shell.resolve(projectRoot)
        projectRoot = projectRoot .. (projectRoot:sub(-1) == "/" and "" or "/")
        print("Setting project root to '" .. projectRoot .. "', is this correct (y/n)")
        local input = read():lower()
        success = input == "y" or input == "yes" or input == "correct"
    end
until success
settings.define("KGinfractions.root", {
    description = "The program root",
    default = "/",
    type = "string"
})
settings.set("KGinfractions.root", projectRoot)
settings.save()

---@param directories table
---@param files table
---@param fileSource string Start of the url to which requested files will be appended (for getting from github: 'https://raw.githubusercontent.com/USER/REPO//refs/heads/BRANCH/')
---@param notFatal? boolean Wether errors during download of this file are fatal
local function installItems(directories, files, fileSource, notFatal)
    for _, directory in ipairs(directories) do
        local forceRoot = directory:sub(1, 1) == "/"
        local dirPath = (forceRoot and "" or settings.get("KGinfractions.root")) .. directory
        makeDir(dirPath)
    end
    for _, file in ipairs(files) do
        local forceRoot = file:sub(1, 1) == "/"
        local filePath = (forceRoot and "" or settings.get("KGinfractions.root")) .. file
        downloadFile(fileSource .. file, filePath, true, notFatal)
    end
end


-- always install
installItems(prgmFiles.directories, prgmFiles.files, prgmFiles.fileLocation)

-- install prompt
local types = {
    external = {
        name = "external application",
        hasAuthor = true,
        hasSocials = true,
        hasDescription = false,
        alwaysThisDevice = false,
        install = function(data)
            shell.run(data.installCmd:gsub("__ROOT__", settings.get("KGinfractions.root")))
        end
    },
    module = {
        name = "module",
        hasAuthor = false,
        hasSocials = false,
        hasDescription = true,
        alwaysThisDevice = true,
        install = function(data)
            installItems(data.dirs, data.files, (data.fileLocation or prgmFiles.fileLocation))
        end
    }
}

local function renderPromptInstall(data, dataType)
    if type(dataType) == "string" then
        dataType = types[dataType]
    elseif type(dataType) == "table" and type(dataType[1]) == "string" then
        dataType = types[dataType[1]]
    end
    assert(type(dataType) == "table", "unsuported data type")

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, 1)
    term.clear()

    local author
    if type(data.author) == "string" then
        author = { name = data.author }
    elseif type(data.author) == "table" then
        author = data.author
    else
        author = { name = "Unkown" }
    end
    -- display author name enabled
    if dataType.hasAuthor then
        print(data.name .. " by " .. author.name)
    else
        print(data.name)
    end
    -- display author socials
    if dataType.hasSocials then
        author.socials = author.socials or {}
        term.setTextColor(colors.gray)
        local w, h = term.getSize()
        for k, v in pairs(author.socials) do
            local x, y = term.getCursorPos()
            local socialMsg = (x == 1 and "" or " | ") .. k .. ": " .. v
            if x + #socialMsg <= w then
                write(socialMsg)
            end
        end
        print("")
        term.setTextColor(colors.white)
    end
    -- sources
    if data.projectPage then
        print(("view on %s"):format(data.projectPage:gsub("^https?://", "")))
    end
    if data.github then
        local githubRepo = data.github:gsub("^https?://github.com/", "")
        print("view on github: " .. githubRepo)
    end
    if dataType.hasDescription then
        print(data.description)
    end
    print("")

    -- Drawing the buttonSkip
    dataType.labels = dataType.labels or { " Skip  ", "Install" }
    local buttonSkipLabel = dataType.labels[1]
    local buttonInstallLabel = dataType.labels[2]
    local buttonDoneLabel = "  Done  "
    if data.required then
        term.setTextColor(colors.lightGray)
        write("This external application is required")
        term.setTextColor(colors.red)
        print("*")
        term.setTextColor(colors.white)
        buttonSkipLabel = "Cancel "
    end
    if data.thisDevice or dataType.alwaysThisDevice then
        print("Would you like to install this " .. dataType.name .. "?")
    else
        local instructions = data.instruction
        local instructionText = (instructions.type == "website" and " at:\n" .. instructions.url) or
            (instructions.type == "text" and ":\n" .. instructions.description)
        print("This " ..
            dataType.name ..
            " has to be installed on a diferent device, please follow the install instructions" .. instructionText)
    end
    local w, h = term.getSize()
    local x, y = term.getCursorPos()
    local padding = 2
    local buttonWidth = 7 + 2 * padding
    local spaceAround = (w - buttonWidth * 2) / 3
    local buttonDoneWidth = 8 + 2 * padding
    local spaceAroundButtonDone = (w - buttonDoneWidth) / 2

    ---@param corners table A list containing 2 lists containing the x and y of each point {{x,y},{x,y}}
    ---@param label string The text for on the button
    ---@param padding number Padding around the text
    ---@param color number Background color of the button
    local function button(corners, label, padding, color)
        padding = padding or 0
        local tButton = {
            click = function(x, y)
                return x >= corners[1][1] and x <= corners[2][1] and y >= corners[1][2] and y <= corners[2][2]
            end,
            draw = function()
                paintutils.drawFilledBox(corners[1][1], corners[1][2],
                    corners[2][1], corners[2][2], color
                )
                local txtY = corners[1][2] + ((corners[2][2] - corners[1][2]) / 2)
                term.setCursorPos(corners[1][1] + padding, txtY)
                write(label)
            end,
            label = label
        }
        tButton.draw()
        return tButton
    end
    local buttonSkip
    local buttonInstall
    local buttonDone
    if data.thisDevice or dataType.alwaysThisDevice then
        local buttonSkipCorners = { { spaceAround, y + 1 }, { spaceAround + buttonWidth - 1, y + 3 } }
        buttonSkip = button(buttonSkipCorners, buttonSkipLabel, padding, colors.gray)

        local buttonInstallCorners = { { 2 * spaceAround + buttonWidth, y + 1 }, { 2 * spaceAround + 2 * buttonWidth - 1, y + 3 } }
        buttonInstall = button(buttonInstallCorners, buttonInstallLabel, padding, colors.gray)
    else
        local buttonDoneCorners = { { spaceAroundButtonDone, y + 1 }, { spaceAroundButtonDone + buttonDoneWidth - 1, y + 3 } }
        buttonDone = button(buttonDoneCorners, buttonDoneLabel, padding, colors.gray)
    end

    term.setCursorPos(1, y + 4)
    return buttonSkip, buttonInstall, buttonDone
end

---@param data table The data about the thing that is being prompted to be installed
---@param dataType string|table Info about the type of the application and how the data has to be processed
local function promptInstall(data, dataType)
    if type(dataType) == "string" then
        dataType = types[dataType]
    elseif type(dataType) == "table" and type(dataType[1]) == "string" then
        dataType = types[dataType[1]]
    end
    assert(type(dataType) == "table", "unsuported data type")

    local buttonSkip, buttonInstall, buttonDone = renderPromptInstall(data, dataType)

    -- Await user input and install the program when confirmed
    repeat
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        local success = true
        local eventData = { os.pullEvent() }
        local skip, install, done
        if eventData[1] == "mouse_click" then
            local event, mouse, x, y = table.unpack(eventData)
            skip = buttonSkip and buttonSkip.click(x, y)
            install = buttonInstall and buttonInstall.click(x, y)
            done = buttonDone and buttonDone.click(x, y)
        elseif eventData[1] == "key" then
            local event, keyNum, is_held = table.unpack(eventData)
            --[[ keys
                enter: 257 -> install|done
                y:     89  -> install
                n:     78  -> cancel

            ]]
            skip = buttonSkip and (keyNum == 78)
            install = buttonInstall and (keyNum == 89 or keyNum == 257)
            done = buttonDone and (keyNum == 257)
        end
        if skip then
            print("Skipped installing " .. dataType.name)
            if data.required then
                term.setTextColor(colors.red)
                term.setBackgroundColor(colors.black)
                term.setCursorPos(1, 1)
                term.clear()
                print("This " ..
                    dataType.name ..
                    " is required\nNot installing this " .. dataType.name .. " will abort the installation.")
                repeat
                    term.setTextColor(colors.orange)
                    print("abort the installation? y/n")
                    term.setTextColor(colors.white)
                    local input = read()
                    local valid = false
                    if input == "y" then
                        abort()
                    elseif input == "n" then
                        valid = true
                        success = false
                        renderPromptInstall(data, dataType)
                    end
                until valid
            end
            if dataType.cancel then dataType.cancel(data) end
        elseif install then
            print("Installing " .. dataType.name)
            dataType.install(data)
        elseif done then
            success = true
        else
            success = false
        end
    until success
end

-- handle external items
local externals = prgmFiles.external
for _, external in ipairs(externals) do
    promptInstall(external, "external")
    --installExternal(external)
end
--]]

-- Handle settings
for setting, info in pairs(prgmFiles.settings) do
    clearTerm()
    if args.settings == nil or args.settings[setting] == nil then
        local repChar = type(info.obscure) == "string" and info.obscure or (info.obscure and "*" or nil)
        print(info.prompt)
        local input = read(repChar)
        settings.set(setting, input)
    elseif args.settings ~= nil and args.settings[setting] ~= nil then
        settings.set(setting, args.settings[setting])
    end
    settings.save()
end

-- handle optional modules/templates
---@param processData table
---@param infoOpened boolean
---@param data table
---@param dataType table|string
local function genLine(processData, infoOpened, data, dataType)
    local w, h = term.getSize()
    processData = processData or {}
    processData.checked = processData.checked or true

    local checkedTxt = "[" .. (processData.checked and "x" or " ") .. "]"
    local infoBtn = infoOpened and "[i]" or "(i)"
    local startSnapTxt = checkedTxt .. " " .. data.name
    local endSnapTxt = infoBtn
    local filler = (" "):rep(w - #startSnapTxt - #endSnapTxt)
    return startSnapTxt .. filler .. endSnapTxt, processData
end
---@param data table
---@param processDataInfo table
---@return nil
local function renderInfo(data, processDataInfo)
    local w, h = term.getSize()
    local infoW, infoH = w / 3 * 2, h / 3 * 2
    local infoX1, infoY1 = w / 6, h / 6 + 1
    local infoX2, infoY2 = infoX1 + infoW, infoY1 + infoH
    processDataInfo.x = { infoX1, infoX2 }
    processDataInfo.y = { infoY1, infoY2 }

    local oldTerm = term.current()
    local infoWindow = window.create(oldTerm, infoX1, infoY1, infoW, infoH, false)
    term.redirect(infoWindow)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.gray)
    term.clear()
    term.setCursorPos(1, 1)

    ---@param str any
    ---@param width? any
    local function printCentered(str, width)
        width = width or term.getSize()
        local remaining = width - #str
        local sideLength = remaining / 2
        local side = (" "):rep(sideLength)
        print(side .. str .. side)
    end

    paintutils.drawFilledBox(1, 1, infoW, infoH, colors.lightGray)
    paintutils.drawLine(1, 1, infoW, 1, colors.gray)
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(1, 1)
    printCentered(data.name)
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.setCursorPos(1, 2)
    printCentered(data.description)
    print("")

    local _, y = term.getCursorPos()
    local remainingLines = infoH - y - 1
    local amountDirs = math.floor(remainingLines / 3)
    local hiddenDirs = amountDirs < #data.dirs
    amountDirs = hiddenDirs and amountDirs or #data.dirs
    local amountFiles = remainingLines - (amountDirs + 1)
    local hiddenFiles = amountFiles < #data.files
    amountFiles = hiddenFiles and amountFiles or #data.files

    if amountDirs ~= 0 then
        print("Contains directories:")
        for i = 1, amountDirs do
            local dir = data.dirs[i]
            write(" ")
            term.setBackgroundColor(colors.white)
            print(dir)
            term.setBackgroundColor(colors.lightGray)
        end
        if hiddenDirs then
            term.setTextColor(colors.gray)
            print(" and " .. math.ceil(#data.dirs - amountDirs) .. " more")
            term.setTextColor(colors.black)
        end
    else
        print("Contains " .. #data.dirs .. " directories")
    end
    if amountFiles ~= 0 then
        print("Contains files:")
        for i = 1, amountFiles do
            local file = data.files[i]
            write(" ")
            term.setBackgroundColor(colors.white)
            print(file)
            term.setBackgroundColor(colors.lightGray)
        end
        if hiddenFiles then
            term.setTextColor(colors.gray)
            write(" and " .. math.ceil(#data.files - amountFiles) .. " more")
            term.setTextColor(colors.black)
        end
    else
        print("Contains " .. #data.files .. " files")
    end

    infoWindow.setVisible(true)
    term.redirect(oldTerm)
    return processDataInfo
end
---@param processData table
---@param dataList table List containing data items
---@param dataType string|table Type for all data items in dataList or a table for each item specifically
---@return table processData
---@return table lineToId
local function render(processData, dataList, dataType)
    clearTerm()
    term.setTextColor(colors.white)
    local w, h = term.getSize()
    paintutils.drawLine(1, 1, w, 1, colors.gray)
    local confirm = " done "
    term.setCursorPos(w - #confirm + 1, 1)
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.lightGray)
    print(confirm)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    local lineToId = {}
    for id, data in pairs(dataList) do
        table.insert(lineToId, id)
        local _, y = term.getCursorPos()
        local itemData = processData[y - 1]
        local line, itemData = genLine(itemData, processData.info.index == id, data, dataType)
        processData[y - 1] = itemData
        print(line)
    end
    if processData.info.index then
        processData.info = renderInfo(dataList[processData.info.index], processData.info)
    end
    return processData, lineToId
end
---@param processData table
---@param lineToId table
---@return table processData
---@return boolean? done
local function getInput(processData, lineToId)
    local w, h = term.getSize()
    local results = { os.pullEvent() }
    if results[1] == "mouse_click" then
        local event, btn, x, y = table.unpack(results)
        if processData.info.index then
            local info = processData.info
            if x >= info.x[1] and x <= info.x[2] and y >= info.y[1] and y <= info.y[2] then

            else
                processData.info = { index = nil }
            end
        elseif y == 1 then     -- catch all clicks on the top bar
            if x >= w - 4 then -- click done button
                return processData, true
            end
        elseif (y - 1) > (#processData) then
            -- do nothing and wait for return
        elseif x >= 1 and x <= 3 then
            processData[y - 1].checked = not processData[y - 1].checked
        elseif x >= w - 2 and x <= w then
            processData.info = { index = lineToId[y - 1] }
        end
    elseif results[1] == "key" then
        local event, keyNum, is_held = table.unpack(results)
        if keyNum == 257 then -- press enter
            return processData, true
        end
    end
    return processData
end
---@param dataList table List containing data items
---@param dataType string|table Type for all data items in dataList or a table for each item specifically
---@return nil
local function promptInstallList(dataList, dataType)
    local processData = { info = { index = nil } }
    local done = false
    local lineToId = {}
    while not done do
        processData, lineToId = render(processData, dataList, dataType)
        processData, done = getInput(processData, lineToId)
        sleep(0)
    end
    for i = 1, #processData do
        local id = lineToId[i]
        local item = dataList[id]
        installItems(item.dirs, item.files, item.fileSource or prgmFiles.fileLocation, true)
    end
end

local modules = prgmFiles.modules
promptInstallList(modules, "module")

-- Install startup file and move existing one to startupScripts/
if fs.exists("startup.lua") then
    table.insert(fsChanges, { action = "move", type = "file", from = "startup.lua", to = "startupScripts/startup.lua" })
    fs.move("startup.lua", "startupScripts/startup.lua")
    print("Moved old startup.lua to startupScripts/startup.lua")
end
downloadFile(prgmFiles.fileLocation .. "startup.lua", "startup.lua")

clearTerm()

-- Prompt entering webhook token
write(
    "This application supports sending messages to a discord webhook.\nPlease enter a webhook token or leave empty (token will be stored ")
term.setTextColor(colors.orange)
write("UNENCRYPTED")
term.setTextColor(colors.white)
print(" on this computer)")
local success = false
local validToken, reason, token, id
repeat
    if reason then
        print("Invalid token: " .. reason)
    end
    token = read("*")
    if token ~= "" then
        local httpSuccess
        httpSuccess, reason = http.checkURL(token)
        if httpSuccess then
            local response = http.get(token)
            local body = response.readAll()
            local webhook = textutils.unserialiseJSON(body)
            if webhook then
                print("Found webhook with name '" .. webhook.name .. "'")
                local resToken = webhook.token
                local urlToken = token:match("[%w_-]*$")
                local matchingToken = resToken == urlToken
                if not matchingToken then
                    term.setTextColor(colors.orange)
                    print("!! Token from url and http response do not match !!")
                    term.setTextColor(colors.white)
                    print("use token? (y/n) or reenter it")
                    local input = read()
                    if input == "y" then
                        validToken = true
                    end
                end
                validToken = validToken ~= nil and validToken or (true)
            end
        end
    end
    success = (token == "") or validToken
until success
if token ~= "" then
    local UTCoffset = (os.time("utc") - os.time("local"))
    ---@diagnostic disable-next-line: cast-local-type
    UTCoffset = UTCoffset == 0 and "" or ((UTCoffset == math.abs(UTCoffset)) and " + " or " - ") .. tostring(math.abs(UTCoffset))
    local timezone = "UTC" .. UTCoffset

    local redstoneState = ""
    for i, side in ipairs(redstone.getSides()) do
        local input = redstone.getAnalogInput(side)
        local output = redstone.getAnalogOutput(side)
        redstoneState = redstoneState .. ("%x"):format(input) .. ("%x"):format(output)
    end

    local function uuid()
        math.randomseed(os.time()+os.epoch()/(tonumber(redstoneState,16)+1))
        local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        return string.gsub(template, '[xy]', function (c)
            local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', v)
        end)
    end
    local randomKey = uuid()
    local idInfo = "Computer id: " .. tostring(os.getComputerID())
        .. (os.getComputerLabel() and ("\nComputer label: " .. tostring(os.getComputerLabel())) or "")
        .. "\nTimezone: " .. timezone
        .. "\nRedstone state: " .. redstoneState
        .. "\nRandom key: " .. randomKey


    local content =
        "Webhook was successfully added to your KGinfractions instance.\nHere is some info to confirm it was you:```ansi\n"
        .. "[2;33m" .. os.version() .. "[0m\n"
        .. idInfo
        .. "```"
    local body = {
        content = textutils.json_null,
        embeds = {
            {
                title = "Successfully added webhook token",
                description = content,
                color = colors.packRGB(term.getPaletteColor(colors.lime)),
                footer = {
                    text = "If this wasn't you, you should probably remake your webhook token"
                }
            }
        },
        attachments = textutils.empty_json_array
    }
    -- make the request
    local res, success, failRes = http.post({
        url =
        "https://discord.com/api/webhooks/1310331059858051082/LF3DqgplLhv0S__GIF385B21HAA6cEgr9Rqdbr_6FBZ0r4NG-tHw0-W0BEXo5OslZ4Gp",
        method = "POST",
        headers = {
            ["content-type"] = "application/json"
        },
        body = textutils.serialiseJSON(body)
    })
    print("Send a message to your webhook with following identifing info:")
    term.setTextColor(colors.yellow)
    print(os.version())
    term.setTextColor(colors.white)
    print(idInfo)
    print("press any key to continue...")
    os.pullEvent("key")

    local h = fs.open(projectRoot .. "/tokens/webhook.token", "w")
    h.write(token)
    h.close()
    print("Webhook token was added to file")
    sleep(3)
end

if args.bootStartup == nil then
-- prompt running UI on startup
settings.define("KGinfractions.startup", {
    description = "wether to launch user interface on startup",
    default = true,
    type = "boolean"
})

local w, h = term.getSize()
local halfWidth = (w - 21) / 2
local stripes = ("="):rep(halfWidth)

promptInstall({
    name = stripes .. "[ LAUNCH ON STARTUP ]" .. stripes,
    description = "Would you like to launch the user interface on startup?"
}, {
    name = "startup",
    hasAuthor = false,
    hasSocials = false,
    hasDescription = true,
    alwaysThisDevice = true,
    labels = { "  No   ", "  Yes  " },
    install = function(data)
        settings.set("KGinfractions.startup", true)
        settings.save()
    end,
    cancel = function(data)
        settings.set("KGinfractions.startup", false)
        settings.save()
    end
})
else
    settings.set("KGinfractions.startup", args.bootStartup)
    settings.save()
end
clearTerm()

local input
if args.reboot == nil then
    repeat
        print("Rebooting is required for full functionality, would you like to reboot now y/n")
        input = read()
    until input == "y" or input == "n"
else
    input = args.reboot and "y" or " n"
end
if input == "y" then
    os.reboot()
end

clearTerm()

shell.setAlias("viewDatabase", fs.combine(projectRoot, "userFacing/viewDatabase.lua"))
print("installed successfully, run 'viewDatabase' to start")
