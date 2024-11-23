local function printC(sText, cColor,win)
    if type(cColor) == "string" and #cColor > 1 then
        cColor = colors[cColor] 
    elseif type(cColor) == "string" and #cColor == 1 then
        local blitColors = {["0"]=1, ["1"]=2, ["2"]=4, ["3"]=8, ["4"]=16, ["5"]=32, ["6"]=64, ["7"]=128, ["8"]=256, ["9"]=512, ["a"]=24, ["b"]=48, ["c"]=96, ["d"]=8192, ["e"]=16384, ["f"]=32768}
        cColor = blitColors[cColor]
    end
    local oldWin = term.current()
    if win then term.redirect(win) end
    local oldColor = term.getTextColor()
    term.setTextColor(cColor)
    if type(sText) == "table" then
        print(table.unpack(sText))
    else 
        print(sText)
    end
    term.setTextColor(oldColor)
    if win then term.redirect(oldWin) end
end
local mainPath = "completion/username"
local filePath = fs.combine(mainPath,"players.lua")

local ratio = 35
local width,height = term.getSize()
local widthC = ratio/51*width
local consoleWin = window.create( term.current(), 1, 1, widthC, height)
local widthL = (51-ratio)/51*width
local listWin = window.create(term.current(),
    widthC+1, 1,
    widthL, height )

--term.setBackgroundColor(colors.gray)
term.clear()

consoleWin.setBackgroundColor(colors.black)
consoleWin.clear()

listWin.setBackgroundColor(colors.gray)
listWin.clear()


function main()
    os.queueEvent("updated",0,width,height)
    while true do
        local event, user, dimension = os.pullEvent("playerJoin")
        printC("player joined: '"..user.."'","white",consoleWin)
        local h, er = fs.open(filePath,"r")
        if not h then
            error(er)
        end
        local players = h.readAll()
        h.close()
        players = textutils.unserialise(players)
        if not players[1][user] then
            table.insert(players[2],user)
            players[1][user] = true
            printC("added '"..user.."' to cache","green",consoleWin)
        else
            printC("'"..user.."' already in cache","orange",consoleWin)
        end
        table.sort(players[2])
        players = textutils.serialise(players)
        local h = fs.open(filePath,"w")
        h.write(players)
        h.close()
        os.queueEvent("updated",0,width,height)
    end
end

function dispList(items,win)
    for i,v in ipairs(items) do
        win.write(v)
        local x,y = win.getCursorPos()
        win.setCursorPos(1,y+1)
    end
end

function list()
    print("running list()")
    local width,height = term.getSize()

    local h = fs.open(filePath,"r")
    local players = h.readAll()
    h.close()
    players = textutils.unserialise(players)
    players = players[2]


    listWin.clear()
    listWin.setCursorPos(1,1)
    local cX, cY = 1, 1
    while true do
        local event, dir, x, y = os.pullEvent()
        
        if event == "updated" then 
            local h = fs.open(filePath,"r")
            local playersR = h.readAll()
            h.close()
            playersR = textutils.unserialise(playersR)
            players = playersR[2]
        end
        if (event == "mouse_scroll" or event == "updated") and x > ratio/51*width+1 then
            listWin.clear()
            cY=cY-dir
            if cY > 1 then cY = 1 end
            if cY < 2-#players then cY = 2-#players end
            listWin.setCursorPos(cX,cY)
            
            dispList(players,listWin)
        end
    end
end

parallel.waitForAll(main,list)