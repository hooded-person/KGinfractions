-- v:5
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

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
end

local abortMeta = {}
abortMeta.__call = function() -- main abort function
    term.setTextColor(colors.red)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
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
---@param path string Path for which too make the file
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
    if err then
        response = failResponse;
    end;
    local statusCode = response.getResponseCode();
    local headers = response.getResponseHeaders();
    local body = response.readAll();
    response.close();
    if err then -- show http errors (will be double up with github, ex. "HTTP 404\n 404: not found")
        local errMsg = "HTTP " .. statusCode .. " " .. url .. "\n" .. body;
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

    assert(headers["Content-Type"] == "text/plain; charset=utf-8",
        "unexpected content type,\nResponse header 'Content-Type' did not match 'text/plain; charset=utf-8'"
    );

    local jsonData = textutils.unserialiseJSON(body);
    assert(jsonData ~= nil, "failed too unserialise response file");
    return jsonData, responseData
end

---@param url string The url from which to download the file
---@param filePath string The filepath too which to downlaod the file
---@param notify boolean|nil Wether too print what is happenening (lot of downloads after each other otherwise looks wierd)
local function downloadFile(url, filePath, notify)
    local success, responseData = getUrl(url)
    local headers = responseData.headers
    local body = responseData.body

    assert(headers["Content-Type"] == "text/plain; charset=utf-8",
        "unexpected content type,\nResponse header 'Content-Type' did not match 'text/plain; charset=utf-8'"
    );

    -- handle file existing
    if fs.exists(filePath) then
        warn(("The file '%s' already exists"):format(filePath))
        local input
        repeat
            print("would you like to overwrite this file (THIS CAN NOT BE UNDONE). y/n")
            input = read()
        until input == "y" or input == "n"
        if input ~= "y" then
            ---@diagnostic disable-next-line: undefined-global
            abort() -- currently undefined, will also end the installer :/
        end
    end
    makeFile(filePath, body)
    term.setCursorPos(1, 3)
    term.clearLine()
    print(("downloaded '%s'"):format(filePath))
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

-- always install
installItems(prgmFiles.directories, prgmFiles.files, prgmFiles.fileLocation)

-- handle external items

---@param external table All info about the external program
---@param external table All info about the external program
local function installExternal(external)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, 1)
    term.clear()
 
    local author
    if type(external.author) == "string" then
        author = { name = external.author }
    elseif type(external.author) == "table" then
        author = external.author
    else
        author = { name = "Unkown" }
    end
    author.socials = author.socials or {}
 
    -- external info and author credits
    print(external.name .. " by " .. author.name)
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
    term.setBackgroundColor(colors.black)
    if external.projectPage then
        local projectPageName = external.projectPage:gsub("^https?://", "")
        projectPageName = projectPageName:match("%w*.%w*")
        local projectPageSub = external.projectPage:gsub("^https?://%w.%w/", "")
        print(("view on %s: %s"):format(projectPageName, projectPageSub))
    end
    if external.github then
        local githubRepo = external.github:gsub("^https?://github.com/", "")
        print("view on github: " .. githubRepo)
    end
    -- actual installation
    local buttonSkip = " Skip  "
    local buttonInstall = "Install"
    if external.required then
        print("this external application is required")
        buttonSkip = "Cancel "
    end
    print("Would you like too install this external application?")
    local x, y = term.getCursorPos()
    local padding = 2
    local buttonWidth = 7 + 2*padding
    local spaceAround = (w - buttonWidth*2) / 3

    paintutils.drawFilledBox(spaceAround, y+1,
        spaceAround+buttonWidth -1, y+3,
        colors.gray
    )
    term.setCursorPos(spaceAround + padding, y + 2)
    write(buttonSkip)

    paintutils.drawFilledBox(2 * spaceAround + buttonWidth, y + 1,
        2*spaceAround + 2*buttonWidth-1, y + 3,
        colors.gray
    )
    term.setCursorPos(2*spaceAround + buttonWidth + padding, y + 2)
    write(buttonInstall)

    term.setCursorPos(1, y+4)
end


local externals = prgmFiles.external
for _, external in ipairs(externals) do
    installExternal(external)
end


-- handle optional modules/templates


-- abort()
