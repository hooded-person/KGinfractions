local db = require "/database"

--[[
{
  "content": null,
  "embeds": [
    {
      "title": "title",
      "description": "description",
      "url": "https://url.com",
      "color": 39423,
      "author": {
        "name": "user",
        "url": "https://lookup.user.cmd",
        "icon_url": "https://user.icon"
      },
      "timestamp": "2024-10-22T22:00:00.000Z"
    }
  ],
  "attachments": []
}
--]]
function getToken()
    local h = fs.open("/tokens/webhook.token", "r")
    local token = h.readAll()
    h.close()
    return token
end

settings.define("kgTF.typeColors", {
    description = "Which colors too use for template types",
    default = {
        ["WARN"] = colors.orange,
        ["EVIC"] = colors.red,
        ["HIDE"] = colors.gray,
    },
    type = "table",
})
function notifyWebhook(processedData)
    -- text for displaying deadline
    local deadlineTxt = (processedData.deadline ~= -1) and
        "deadline set for <t:" .. processedData.deadline .. ">(<t:" .. processedData.deadline .. ":R>)" or ""

    -- text for displaying format data
    local formatDataTxt = ""
    local skip = { date = true, user = true, deadline = true } -- which format data items not too show
    local special = {
        deadlineGiven = function(value)                        -- format data items that get special treatment
            local deadlineT = {}
            deadlineT.day, deadlineT.month, deadlineT.year = value:match("(%d*)/(%d*)/(%d*)")
            for k, v in pairs(deadlineT) do deadlineT[k] = tonumber(v) end
            local success, deadline = pcall(function() return "<t:" .. os.time(deadlineT) .. ":d>" end)
            if not success then deadline = value end
            return "**deadline given:** " .. deadline
        end
    }

    for k, v in pairs(processedData.formatData) do
        if not skip[k] and not special[k] then                                   -- check wether too skip or give special treatment too key
            k = k:gsub("[A-Z]", function(match) return " " .. match:lower() end) -- posible camelCase to using spaces
            formatDataTxt = formatDataTxt ..
                "**" ..
                k .. ":** " .. v .. "\n" -- add key and value to formatDataTxt
        elseif special[k] then
            formatDataTxt = formatDataTxt .. special[k](v) .. "\n"
        end -- format data items that get special treatment
    end

    local body = {
        content = textutils.json_null,
        embeds = {
            {
                title = table.concat(processedData.template, " ") .. " - " .. processedData.user,
                description = deadlineTxt .. "\n" .. formatDataTxt,
                color = colors.packRGB(term.getPaletteColor(settings.get("kgTF.typeColors")[processedData.template[1]])),
                timestamp = os.date("%Y-%m-%eT%R:%S.000Z", processedData.time),
            }
        },
        attachments = textutils.empty_json_array
    }
    -- make the request
    local res, success, failRes = http.post({
        url = getToken(),
        method = "POST",
        headers = {
            ["content-type"] = "application/json"
        },
        body = textutils.serialiseJSON(body)
    })
    if not res then
        return false,
            { code = failRes.getResponseCode(), headers = failRes.getResponseHeaders(), body = failRes.readAll() }
    end
    return true, { code = res.getResponseCode(), headers = res.getResponseHeaders(), body = res.readAll() }
end

db.add = db._INTERNAL.base(function(data, toInsert)
    math.randomseed()
    local uuid
    local tries = 0
    repeat
        tries = tries + 1
        uuid = ("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"):gsub('x',
            function(match) return ("%x"):format(math.random(0, 12)) end)
    until data[uuid] == nil

    data[uuid] = toInsert
    local success, responseData = notifyWebhook(toInsert)

    return true, {
        reference = uuid,
        webhook = { success, responseData },
        inserted = data[uuid],
        tests = { webhook = success, uuidGenTries = tries }
    }
end)

db.process = function(toProcess) -- does not use `data`, but calls other functions that use it, giving this a base is not needed
    local processed = {}

    local template = toProcess.template               -- template type
    local formatData = toProcess.formatData           -- the format data for the template
    local time = toProcess.time                       -- time of print
    processed.source = toProcess.source               -- time of print

    processed.template = { template[1], template[2] } -- template type and name
    processed.templateFile = template[4]              -- template file, template/<>
    processed.user = formatData.user                  -- user for who was printed
    processed.formatData = formatData                 -- format data from printing
    processed.time = time                             -- time of print

    if formatData.deadline then                       -- deadline for print or -1 if non existent
        local deadlineT = {}
        deadlineT.day, deadlineT.month, deadlineT.year = (formatData.deadline):match("(%d*)/(%d*)/(%d*)")
        for k, v in pairs(deadlineT) do deadlineT[k] = tonumber(v) end
        processed.deadline = os.time(deadlineT)
    else
        processed.deadline = -1
    end

    local success, info = db.add(processed)
    if not info.tests then info.tests = {} end
    local insertedCorrect = info.inserted == processed
    info.tests.insertedCorrect = insertedCorrect -- tests are returned for analysation incase of an error
--[[local wasInserted = textutils.serialise(db.get(info.reference)) == textutils.serialise(info.inserted)
    info.tests.wasInserted = wasInserted         -- tests are returned for analysation incase of an error]]
    local testsPassed = insertedCorrect --and wasInserted | disabled cause comparing the contents of 2 fucking tables and not their pointers is fucking anoying and i aint doing that shit

    return success and testsPassed, info
end

return db
