local spclib = require("/libs/spclib")
local printerHost = 15

local templateDir = "templates/"
if templateDir:sub(-1) ~= "/" then templateDir = templateDir .. "/" end

function getTemplateDoc(template, formatData)
    local tempType, reason, _, path = table.unpack(template)
    local h = fs.open(templateDir .. path, "r")
    local template = h.readAll()
    h.close()
    print("formating")
    template = template:gsub("<([^>]*)>", function(var)
        var = var:gsub(":.*", "")
        write(var)
        write(" = ")
        print(formatData[var])
        return formatData[var]
    end)
    return template
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

return function(template, formatData, source, printOnly)
    if printOnly == nil then printOnly = false end
    local processDB = not printOnly
    -- get document string
    local toPrint = getTemplateDoc(template, formatData)
    -- add type label in color to document
    local Hstart, Hend = toPrint:find("[^\n]*\n")
    local header = toPrint:sub(Hstart, Hend)
    local rest = toPrint:sub(Hend + 1)
    local color = colors.toBlit(settings.get("kgTF.typeColors")[template[1]])
    local title = "\160c" .. color -- color
        .. "\160ac"              -- align center
    -- get alphabet table
    local alphabet = require("/main/alphabet")
    title = title .. alphabet(template[1])

    title = title .. "\160cf\n"

    local toPrint = header .. title .. rest

    local amount = redstone.getAnalogInput("left")
    if amount == 0 then
        print("[WARN] amount is 0, printing 2")
        amount = 2
    end
    local success, result
    if processDB then
        local db = require("/database/addProcessing")
        success, result = db.process({
            template = template,
            formatData = formatData,
            source = source,
            time = os.epoch("utc") -- get epoch in utc cause local not give CET but utc and by getting utc we make sure too actually get utc
                / 1000,            -- convert to unit usable with os.date
            -- discord timestamps use UTC        +60*60, -- add 1 hour (in seconds) to get CET again
        })
    end

    if not success then
        term.setTextColor(colors.red)
        print((printOnly and "database processing disabled" or "database processing failed")..", printing without db entry")
        term.setTextColor(colors.white)
    end

    term.setTextColor(colors.gray)
    print("reference: " .. tostring(result.reference))
    term.setTextColor(colors.white)

    rednet.open("back")
    spclib.printDocument(printerHost, toPrint, amount, false)


    print("finished")
end
