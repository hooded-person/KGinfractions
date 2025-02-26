local version = 4

print("testing installer")
shell.setAlias("reinstall","startupScripts/startup.lua")

local fileHost = "https://raw.githubusercontent.com/";
local repoLoc = "hooded-person".."/".."KGinfractions";
local inbeteenShit = "/refs/heads/";
local branch = "main/";
local HTTProot = fileHost..repoLoc..inbeteenShit..branch
HTTProot = "http://127.0.0.1:3000/"
local installerTestFileURL = HTTProot.."setup/installerTesterStartup.lua";
local installerFileUrl = HTTProot.."setup/installer.lua";

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
local function getJsonData(url)
    local _, responseData = getUrl(url)
    local headers = responseData.headers
    local body = responseData.body

    -- assert(headers["Content-Type"] == "text/plain; charset=utf-8",
    --     "unexpected content type,\nResponse header 'Content-Type' did not match 'text/plain; charset=utf-8', got:\n"..headers["Content-Type"]
    -- );

    local jsonData = textutils.unserialiseJSON(body);
    assert(jsonData ~= nil, "failed too unserialise response file");
    return jsonData, responseData
end

local function getInstallerInfo(installerURL)
    local success, responseData = getUrl(installerURL)
    local info = {}
    for infoItem in responseData.body:match("^-- ([^\n]*)"):gmatch("([^,]*),?") do
        local seperatorI = infoItem:find(":")
        local k = infoItem:sub(0,seperatorI-1)
        local v = infoItem:sub(seperatorI+1)
        info[k]=v
    end
    local prgmFiles = getJsonData(HTTProot.."setup/prgmFiles.json")
    info.dataVersion = prgmFiles.version
    return info
end

local h = fs.open("expectedVersion.txt","r")
local expectedVersions = h.readAll() or "0|0"
local versionIt = expectedVersions:gmatch("([^|]*)|?")
local expectedSelfVersion = versionIt()
local expectedVersion = versionIt()
local expectedDataVersion = versionIt()
h.close()

print("checking installer version")
local installerInfo = getInstallerInfo(installerFileUrl)
print(("version: %f\ninstaller version: %s\ninstaller data version: %s"):format(version, installerInfo.v, installerInfo.dataVersion))

local outdated = (tonumber(version) < tonumber(expectedSelfVersion) and {"self",expectedSelfVersion}) or (tonumber(installerInfo.v) < tonumber(expectedVersion) and {"installer",expectedVersion}) or (tonumber(installerInfo.dataVersion) < tonumber(expectedDataVersion) and {"installer data", expectedDataVersion}) or {}
local outdatedItem = outdated[1]
if outdatedItem then
    if outdatedItem == "self" then
        term.setTextColor(colors.gray)
        fs.delete("startup.lua")
        shell.run("wget "..installerTestFileURL.." startup.lua")
        term.setTextColor(colors.white)
    end
    local h = fs.open("rebootTimeout.txt","r")
    local rebootTimeout
    if h then
        rebootTimeout = tonumber(h.readAll())*3 or 5
        h.close()
    else
        rebootTimeout = 5
    end
    local h = fs.open("rebootTimeout.txt","w")
    h.write(tostring(rebootTimeout))
    h.close()
    print(("older %s version, expected %f"):format(outdatedItem, tonumber(outdated[2])))
    local _, y  = term.getCursorPos()
    for i = rebootTimeout, 1, -1 do
        term.setCursorPos(1, y)
        term.clearLine()
        print(("retrying in %d/%d seconds"):format(i,  rebootTimeout))
        sleep(1)
    end
    os.reboot()
end
fs.delete("rebootTimeout.txt")

local input
repeat
    term.setTextColor(colors.red)
    print("THIS WILL WIPE THE PC AND IS A DEV TOOL, IF YOU ARE A USER ENTER N AND DELETE THIS FILE")
    term.setTextColor(colors.orange)
    print("Are you sure? y/n")
    term.setTextColor(colors.white)
    input = read()
until input == "y" or input == "n"
if input ~= "y" then error("installer testing aborted, computer will not be wiped") end


shell.run("rm *")
shell.run("wget "..installerTestFileURL.." startup.lua")

local h = fs.open("expectedVersion.txt","w")
h.write(expectedVersions)
h.close()

shell.run("wget run "..installerFileUrl)