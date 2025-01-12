-- v:6.3
---@param fgColor? number
---@param bgColor? number
---@param x? number
---@param y? number
local function clearTerm(fgColor, bgColor,x,y)
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
pgrmFilesURL = "http://127.0.0.1:3000/setup/prgmFiles.json"

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

local function getUrl(url)
    local canRequest, err = http.checkURL(url);
    if not canRequest then
        error(err);
    end;
    local response, err, failResponse = http.get({
        url = url,
    });
    if err and failResponse then
        response = failResponse;
    elseif err and not failResponse then
        error(err)
    end;
    if response == nil then
        error(err)
    end
    local statusCode = response.getResponseCode();
    local headers = response.getResponseHeaders();
    local body = response.readAll();
    response.close();
    if err then -- show http errors (will be double up with github, ex. "HTTP 404\n 404: not found")
        local errMsg = err .. "\nHTTP " .. statusCode .. " " .. url .. "\n" .. body;
        error(errMsg);
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
    local statusCode = responseData.statusCode
    local headers = responseData.headers
    local body = responseData.body

    assert(
        string.lower(headers["Content-Type"]) == "text/plain; charset=utf-8" or
        string.lower(headers["Content-Type"]) == "application/json; charset=utf-8",
        "unexpected content type,\nResponse header 'Content-Type' did not match 'text/plain; charset=utf-8', got:\n" ..
        headers["Content-Type"]
    );

    local jsonData = textutils.unserialiseJSON(body);
    assert(jsonData ~= nil, "failed to unserialise response file");
    return jsonData, responseData
end

---@param url string The url from which to download the file
---@param filePath string The filepath to which to downlaod the file
---@param notify? boolean Wether to print what is happenening (lot of downloads after each other otherwise looks wierd)
local function downloadFile(url, filePath, notify)
    local success, responseData = getUrl(url)
    local headers = responseData.headers
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
    elseif projectRoot ~= "/" then
        warn("Currently only installing in root is supported")
    else
        success = true
        projectRoot = projectRoot .. (projectRoot:sub(-1) == "/" and "" or "/")
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
local function installItems(directories, files, fileSource)
    for _, directory in ipairs(directories) do
        local dirPath = settings.get("KGinfractions.root") .. directory
        makeDir(dirPath)
    end
    for _, file in ipairs(files) do
        downloadFile(fileSource .. file, file, true)
    end
end

--[[
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
---@param data table
---@param dataType string|table
local function promptInstall(data, dataType)
    clearTerm()

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
        local instructionText = (instructions.type == "website" and " at:\n"..instructions.url) or (instructions.type == "text" and ":\n"..instructions.description)
        print("This "..dataType.name.." has to be installed on a diferent device, please follow the install instructions"..instructionText)
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
        local event, mouse, x, y = os.pullEvent("mouse_click")
        if buttonSkip and buttonSkip.click(x, y) then
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
        elseif buttonInstall and buttonInstall.click(x, y) then
            print("Installing " .. dataType.name)
            dataType.install(data)
        elseif buttonDone and buttonDone.click(x, y) then
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

-- handle optional modules/templates
local modules = prgmFiles.modules
for id, moduleData in pairs(modules) do
    promptInstall(moduleData, "module")
end

-- new module system with checkboxes
---@param processData table
---@param data table
---@param dataType table|string
local function genLine(processData, data, dataType)
    local w,h = term.getSize()

    local checkedTxt = "["..processData.checked and "x" or " ".."]"
    local infoBtn = processData.infoOpen and "[i]" or "(i)"
    local startSnapTxt = checkedTxt.." "..data.name
    local endSnapTxt = infoBtn
    local filler = (" "):rep(w-#startSnapTxt-#endSnapTxt)
    return startSnapTxt..filler..endSnapTxt
end
---@param dataList table List containing data items
---@param dataType table Type table for all data items in dataList
---@return nil
local function promptInstallList(dataList, dataType)

end
promptInstallList(modules, "module")


-- Install startup file and move existing one to startupScripts/
if fs.exists("startup.lua") then
    table.insert(fsChanges, { action = "move", type = "file", from = "startup.lua", to = "startupScripts/startup.lua" })
    fs.move("startup.lua", "startupScripts/startup.lua")
    print("Moved old startup.lua to startupScripts/startup.lua")
end
downloadFile(prgmFiles.fileLocation .. "startup.lua", "startup.lua")

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
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

local input
repeat
    print("Rebooting is required for full functionality, would you like to reboot now y/n")
    input = read()
until input == "y" or input == "n"
if input == "y" then
    os.reboot()
end

term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

print("installed successfully, run 'userfacing/viewDatabase.lua' to start")