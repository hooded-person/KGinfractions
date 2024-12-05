    local fileHost = "https://raw.githubusercontent.com/";
    local repoLoc = "hooded-person".."/".."KGinfractions";
    local inbeteenShit = "/refs/heads/";
    local file = "main/setup/prgmFiles.json";
    local pgrmFilesURL = fileHost..repoLoc..inbeteenShit..file;

    local canRequest, err = http.checkURL(pgrmFilesURL);
    if not canRequest then
        error(err);
    end;
    local response, err, failResponse = http.get({
        url = pgrmFilesURL,
    });
    if err then
        response = failResponse
    end
    local statusCode = response.getResponseCode()
    local headers = response.getResponseHeaders()
    local body = response.readAll()
    response.close()
    if err then -- show http errors (will be double up with github, ex. "HTTP 404\n 404: not found")
        local errMsg = "HTTP "..statusCode.."\n"..body
        error(errMsg)
    end

    if headers["Content-Type"] ~= "text/plain; charset=utf-8" then
        error("unexpected content type,\nResponse header 'Content-Type' did not match 'text/plain; charset=utf-8'")
    end