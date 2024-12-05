term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()

local fileHost = "https://raw.githubusercontent.com/";
local repoLoc = "hooded-person".."/".."KGinfractions";
local inbeteenShit = "/refs/heads/";
local file = "main/setup/prgmFiles.json";
local pgrmFilesURL = fileHost..repoLoc..inbeteenShit..file;

local function softError(err)
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
        local errMsg = "HTTP "..statusCode.."\n"..body;
        error(errMsg);
    end;
    return not err, {
        statusCode = statusCode,
        headers = headers,
        body = body
    };
end


---@param url string the url to get json data from
---@return table unserialised JSON data
---@return table full response data
local function getJsonData(url)
    local success, responseData = getUrl(url)
    local statusCode = responseData.statusCode
    local headers = responseData.headers
    local body = responseData.body

    assert(headers["Content-Type"] == "text/plain; charset=utf-8", 
        "unexpected content type,\nResponse header 'Content-Type' did not match 'text/plain; charset=utf-8'"
        );

    local jsonData = textutils.unserialiseJSON(body);
    assert(prgmFiles ~= nil, "failed too unserialise response file");
    return jsonData, responseData
end

local function downloadFile(url)
    local success, responseData = getUrl(url)
    
end

local prgmFiles = getJsonData(pgrmFilesURL)

-- configure a project root
local success = false
local projectRoot
repeat
    print("Enter filepath for program location (or 'abort' to abort)")
    projectRoot = read()
    if projectRoot == "" then softError("please input a value")
    elseif projectRoot == "abort" then 
        error("install aborted")
    elseif fs.isReadOnly(projectRoot) then 
        softError("Path is read only")
    elseif projectRoot ~= "/" then
        softError("Currently only installing in root is supported")
    else 
        success = true
        projectRoot = projectRoot..(projectRoot:sub(-1)=="/" and "" or "/")
    end
until success
settings.define("KGinfractions.root", {
    description = "The program root",
    default = "/",
    type = "string"
})
settings.set("KGinfractions.root", projectRoot)
settings.save()

local function installItems(directories, files)
    for directory in ipairs(directories) do
        local dirPath = settings.get("KGinfractions.root")..directory
        fs.makeDir(dirPath)
    end
    for file in ipairs(files) do
        downloadFile(fileLocation..file)
    end
end
-- always install
installItems(prgmFiles.directories, prgmFiles.files)
-- handle optional modules/templates