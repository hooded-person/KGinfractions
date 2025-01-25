local db = require "addProcessing"

local toProcess = {
    time = os.epoch("utc")/1000,
    template = {
        "EVIC",
        "laggy farm",
        {
            "user:username",
            "deadlineGiven",
            "date",
        },
        "evicLaggyFarm.sdoc",
    },
    formatData = {
        date = "28/10/2024",
        deadlineGiven = "29/10/2024",
        user = "testUser",
    },
}

local success, results = db.process(toProcess)
term.setTextColor( ({
    [true]=colors.green,
    [false]=colors.red
})[success] )
print(success)
term.setTextColor(colors.white)
print(textutils.serialise(results))

--[[
local h = fs.open("/tokens/webhook.token","r")
local token = h.readAll()
h.close()

local res, reason, failRes = http.post({
    url = token,
    method = "POST",
    body = textutils.serialiseJSON({
        content="hi"
    }),
    headers = {
        ["content-type"] = "application/json"
    }
})
if not res then
    print(reason)
    print(failRes.readAll())
end
-]]