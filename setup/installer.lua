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
    local canRequest, err = http.checkURL(pgrmFilesURL);
    if not canRequest then
        error(err);
    end;
    local response, err, failResponse = http.get({
        url = pgrmFilesURL,
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

local function downloadFile(url)
    local success, responseData = getUrl(url)
    
end

local canRequest, err = http.checkURL(pgrmFilesURL);
if not canRequest then
    error(err);
end;
local response, err, failResponse = http.get({
    url = pgrmFilesURL,
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

assert(headers["Content-Type"] == "text/plain; charset=utf-8", 
    "unexpected content type,\nResponse header 'Content-Type' did not match 'text/plain; charset=utf-8'"
    );

local prgmFiles = textutils.unserialiseJSON(body);
assert(prgmFiles ~= nil, "failed too unserialise response file");

local success = false
local projectRoot
while not success do
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
end

for directory in ipairs(prgmFiles.directories) do
    local dirPath = projectRoot..directory
    fs.makeDir(dirPath)
end