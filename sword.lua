---@diagnostic disable: missing-parameter
local sdoc = {}

local mbar = {}

local supdate = {}

local spclib = {}


sdoc._VERSION = "1.1.0"

local ESCAPE_CHAR = "\160"


local escapeCharWidth = { c = 3, r = 2, a = 3, p = 2, t = 34 }

function sdoc.extractEscapeCodes(s)
local escapeCharMap = {}
local output = {}
local oidx = 1
local sidx = 1
while sidx <= #s do
local ch = s:sub(sidx, sidx)
if ch == ESCAPE_CHAR then
local esch = s:sub(sidx + 1, sidx + 1)
local w = assert(escapeCharWidth[esch], ("Invalid escape code %s"):format(esch))
escapeCharMap[oidx] = escapeCharMap[oidx] or {}
local code = s:sub(sidx + 1, sidx + w - 1)
table.insert(escapeCharMap[oidx], code)
sidx = sidx + w
else
output[oidx] = ch
oidx = oidx + 1
sidx = sidx + 1
end
end
return output, escapeCharMap
end

function sdoc.wrapString(s, width)
local str, map = sdoc.extractEscapeCodes(s)
local ccstr = table.concat(str, "")
local idx = 1
local row, col = 1, 1
local output = {}
local function writeChar(ch)
if col > width then
col = 1
row = row + 1
end
output[row] = output[row] or {}
output[row][col] = ch
col = col + 1
end
local function handleEscapeCodes(codes)
end
while idx <= #str do
local ch = str[idx]
if ch:match("%S") then
local length = 1
while str[idx + length - 1]:match("%S") do
length = length + 1
if idx + length - 1 > #str then
break
end
end
if width - col < length and length < width then
row = row + 1
col = 1
end
for i = 1, length - 1 do
handleEscapeCodes(map[idx + i - 1])
writeChar(str[idx + i - 1])
end
idx = idx + length - 1
elseif ch == "\n" then
handleEscapeCodes(map[idx])
writeChar("\n")
col = 1
row = row + 1
idx = idx + 1
else
handleEscapeCodes(map[idx])
writeChar(ch)
idx = idx + 1
end
end
for i, v in ipairs(output) do
output[i] = table.concat(v, "")
end
return output, map
end




local headerMatch = "^shrekdoc%-v(%d%d)w(%d%d)h(%d%d)m([RS]):"
local headerExample = "shrekdoc-v01w00h00mR:"

local validVersions = {
["01"] = true,
["02"] = true
}
local function decodeHeader(str)
local version, w, h, mode = str:match(headerMatch)
assert(version, "Invalid document (missing header!)")
assert(validVersions[version], ("Unsupported document version v%s"):format(version))
w, h = tonumber(w), tonumber(h)
assert(w and h, "Invalid document dimensions.")
if mode == "R" then
str = str:sub(#headerExample + 1)
elseif mode == "S" then
local s = textutils.unserialise(str:sub(#headerExample + 1))
assert(type(s) == "string", "Invalid serialized document.")
str = s
end
return str, w, h
end

local function encode(editable)
local color = "f"
local alignment = "l"
local str = {}
str[1] = ("shrekdoc-v02w%02dh%02dmR:"):format(editable.pageWidth, editable.pageHeight)
if editable.title then
assert(#editable.title <= 32, "Title is more than 32 characters!")
str[2] = ESCAPE_CHAR .. "t" .. ("%-32s"):format(editable.title)
end
for i = 1, #editable.content[1] do
local fg, bg = editable.content[1]:sub(i, i), editable.content[2]:sub(i, i)
local line = editable.linestart[i]
if fg == ESCAPE_CHAR then
str[#str + 1] = ESCAPE_CHAR end
if bg ~= color then
color = bg
str[#str + 1] = ESCAPE_CHAR .. "c" .. color
end
if editable.pages[i] then
for n = 1, editable.pages[i] do
str[#str + 1] = ESCAPE_CHAR .. "p"
end
end
if line and line.alignment ~= alignment then
alignment = line.alignment
str[#str + 1] = ESCAPE_CHAR .. "a" .. alignment
end
str[#str + 1] = fg
end
return table.concat(str, "")
end

local docmeta__index = {}
local docmeta = { __index = docmeta__index }

local function deepClone(t)
if type(t) == "table" then
local nt = {}
for k, v in pairs(t) do
nt[k] = deepClone(v)
end
return nt
end
return t
end

function docmeta__index:remove(a, b)
a, b = math.min(a, b), math.max(a, b)
local sectionWidth = b - a + 1
local editable = deepClone(self.editable)

for i = a, b do
editable.linestart[i] = nil
editable.pages[i] = nil
end

for i = b + 1, #editable.content[1] do
if editable.linestart[i] then
editable.linestart[i - sectionWidth] = editable.linestart[i]
editable.linestart[i] = nil
end
if editable.pages[i] then
editable.pages[i - sectionWidth] = editable.pages[i]
editable.pages[i] = nil
end
end
editable.content[1] = editable.content[1]:sub(1, a - 1) .. editable.content[1]:sub(b + 1)
editable.content[2] = editable.content[2]:sub(1, a - 1) .. editable.content[2]:sub(b + 1)
return encode(editable)
end

function docmeta__index:setAlignment(idx, alignment, b)
local editable = deepClone(self.editable)

if b then
for i = b, idx, -1 do
local nl = editable.linestart[i]
if nl then
nl.alignment = alignment
end
end
end
for i = idx, 1, -1 do
local nl = editable.linestart[i]
if nl then
nl.alignment = alignment
break
end
end

return encode(editable)
end

function docmeta__index:setColor(color, a, b)
a, b = math.min(a, b), math.max(a, b)
local size = b - a + 1
local editable = deepClone(self.editable)
local s = editable.content[2]
editable.content[2] = s:sub(1, a - 1) .. color:rep(size) .. s:sub(b + 1, -1)

return encode(editable)
end

function docmeta__index:insertAt(idx, str, color)
local sectionWidth = #str
local editable = deepClone(self.editable)
for i = #editable.content[1], idx, -1 do
if editable.linestart[i] then
editable.linestart[i + sectionWidth] = editable.linestart[i]
editable.linestart[i] = nil
end
if editable.pages[i] then
editable.pages[i + sectionWidth] = editable.pages[i]
editable.pages[i] = nil
end
end
editable.content[1] = editable.content[1]:sub(1, idx - 1) .. str .. editable.content[1]:sub(idx)
editable.content[2] = editable.content[2]:sub(1, idx - 1) .. (color):rep(#str) .. editable.content[2]:sub(idx)
return encode(editable)
end

function docmeta__index:insertPage(idx)
local editable = deepClone(self.editable)
editable.pages[idx] = (editable.pages[idx] or 0) + 1
return encode(editable)
end

function sdoc.decode(str)
local str, w, h = decodeHeader(str)
local s, m = sdoc.wrapString(str, w)
local doc = {
pages = { {} },
indicies = {},
indexlut = {},
pageWidth = w,
pageHeight = h,
editable = { content = {}, linestart = {}, pages = {}, pageHeight = h, pageWidth = w }
}
local color = "f"
local alignment = "l"
local idx = 1
local page = 1
local ln = 1
local chn = 1
local lineColor = {}
local lineText = {}

local function writeLine()
doc.pages[page] = doc.pages[page] or {}
doc.pages[page][ln] = {}
doc.pages[page][ln][1] = table.concat(lineText, "")
doc.pages[page][ln][2] = table.concat(lineColor, "")
doc.pages[page][ln].alignment = alignment
lineColor, lineText = {}, {}
ln = ln + 1
chn = 1
end

local function parseEscapeCode(code, y)
for _, s in ipairs(code) do
if s:sub(1, 1) == "r" then
color, alignment = "f", "l"
elseif s:sub(1, 1) == "c" then
color = s:sub(2, 2)
elseif s:sub(1, 1) == "a" then
alignment = s:sub(2, 2)
elseif s:sub(1, 1) == "p" then
writeLine()
page = page + 1
ln = 1
doc.editable.pages[idx] = (doc.editable.pages[idx] or 0) + 1
elseif s:sub(1, 1) == "t" then
local title = s:sub(2, 33):match("^(.-)%s-$")
if title == "" then
error("???")
end
doc.editable.title = title
else
error(("Invalid escape code %s"):format(s))
end
end
end

for i, line in ipairs(s) do
if ln - 1 == h then
page = page + 1
ln = 1
end
for x = 1, #line do
local ch = line:sub(x, x)
if m[idx] then
parseEscapeCode(m[idx], i)
end
doc.indicies[idx] = { line = ln, col = chn, page = page }
doc.indexlut[page] = doc.indexlut[page] or {}
doc.indexlut[page][ln] = doc.indexlut[page][ln] or {}
doc.indexlut[page][ln][chn] = idx
lineColor[chn] = color
lineText[chn] = ch
idx = idx + 1
chn = chn + 1
end
writeLine()
end
local last = doc.indicies[idx - 1] or { line = 1, col = 1, page = 1 }
doc.indicies[idx] = { line = last.line, col = last.col + 1, page = last.page }

local lastSeenIdx = 1
local lastPage = page

for page = 1, lastPage do
doc.indexlut[page] = doc.indexlut[page] or {}
local pageHeight = #doc.indexlut[page]
for line = 1, doc.pageHeight do
local lineLength = #(doc.indexlut[page][line] or {})
doc.indexlut[page][line] = doc.indexlut[page][line] or {}
for chn = 1, doc.pageWidth do
if doc.indexlut[page][line][chn] then
lastSeenIdx = doc.indexlut[page][line][chn]
else
doc.indexlut[page][line][chn] = lastSeenIdx
end
if page == lastPage and line == pageHeight and chn == lineLength then
lastSeenIdx = lastSeenIdx + 1
end
end
end
end
doc.pages[1][1] = doc.pages[1][1] or { "", "", alignment = "l", lineX = 1 }

local fgstring = {}
local bgstring = {}
local lastLineHadNewline = true
for pn, page in ipairs(doc.pages) do
for ln, line in ipairs(page) do
fgstring[#fgstring + 1] = line[1]
bgstring[#bgstring + 1] = line[2]
if lastLineHadNewline then
local index = doc.indexlut[pn][ln][1]
doc.editable.linestart[index] = { alignment = line.alignment }
lastLineHadNewline = false
end
local chn = line[1]:find("\n")
lastLineHadNewline = not not chn
end
if #page < doc.pageHeight and pn < #doc.pages then
lastLineHadNewline = true
end
end
doc.editable.content[1] = table.concat(fgstring, "")
doc.editable.content[2] = table.concat(bgstring, "")

doc.blit = sdoc.render(doc)

return setmetatable(doc, docmeta)
end

function sdoc.encode(doc)
return encode(doc.editable)
end

local highlightColor = "8"
local newpageColor = "1"

function sdoc.render(doc, a, b, renderNewlines, renderNewpages, renderControl)
b = b or a
if a and b then
a, b = math.min(a, b), math.max(a, b)
end
local blit = {}
local lastSeenColor = "f"
local lineEndsInHighlight = false
local lineStartsInHighlight = false
local y = 1
for pn, page in ipairs(doc.pages) do
local pblit = {}
y = 1
for ln = 1, doc.pageHeight do
local line = page[ln] or { "", "", "", alignment = "l" }
line[3] = ""
local sx = 1
for i = 1, #line[1] do
local idx = doc.indexlut[pn][ln][i]
if a and b and idx >= a and idx <= b then
lineEndsInHighlight = true
else
lineEndsInHighlight = false
end
if renderNewpages and (doc.editable.pages[idx] or 0) > 0 then
line[3] = line[3] .. newpageColor
else
line[3] = line[3] .. (lineEndsInHighlight and highlightColor or "0")
end
end
local alignment = line.alignment
if alignment == "c" then
sx = math.floor((doc.pageWidth - #line[1]) / 2) + 1
elseif alignment == "r" then
sx = doc.pageWidth - #line[1] + 1
end
local colorStart = line[2]:sub(1, 1)
local colorEnd = line[2]:sub(#line[2], #line[2])
if #line[2] == 0 then
colorStart, colorEnd = lastSeenColor, lastSeenColor
else
lastSeenColor = colorEnd
end
if page[ln] then
page[ln].lineX = sx
end
pblit[y] = {}
pblit[y][1] = (" "):rep(sx - 1) .. line[1] .. (" "):rep(doc.pageWidth - sx + 1 - #line[1])
if renderNewlines then
pblit[y][1] = pblit[y][1]:gsub("\n", "\182")
end
pblit[y][2] = (colorStart):rep(sx - 1) .. line[2] .. (colorEnd):rep(doc.pageWidth - sx + 1 - #line[2])
local sbg = (lineStartsInHighlight and highlightColor or "0")
local ebg = (lineEndsInHighlight and highlightColor or "0")
pblit[y][3] = sbg:rep(sx - 1) .. line[3] .. ebg:rep(doc.pageWidth - sx + 1 - #line[3])
y = y + 1
lineStartsInHighlight = lineEndsInHighlight
end
blit[pn] = pblit
end
return blit
end

local function setColor(dev, fg, bg)
local obg, ofg = dev.getBackgroundColor(), dev.getTextColor()
if bg then dev.setBackgroundColor(bg) end
if fg then dev.setTextColor(fg) end
return ofg, obg
end

function sdoc.blitOn(doc, page, x, y, dev, border)
local pageWidth = #doc[1][1][1]
local pageHeight = #doc[1]
dev = dev or term
if border == nil then border = true end
local w, h = dev.getSize()
x = x or math.ceil((w - pageWidth) / 2)
y = y or math.ceil((h - pageHeight) / 2)
local ofg, obg = setColor(dev, colors.black, colors.white)
if border then
dev.setCursorPos(x - 1, y - 1)
dev.write("\159")
dev.write(("\143"):rep(pageWidth))
setColor(dev, colors.white, colors.black)
dev.setCursorPos(x - 1, y + pageHeight)
dev.write("\130")
for i = 1, pageHeight do
setColor(dev, colors.black, colors.white)
dev.setCursorPos(x - 1, y + i - 1)
dev.write("\149")
setColor(dev, colors.white, colors.lightGray)
dev.setCursorPos(x + pageWidth, y + i - 1)
dev.write("\149")
end
setColor(dev, colors.white, colors.black)
dev.setCursorPos(x + pageWidth, y - 1)
dev.write("\144")
setColor(dev, colors.white, colors.lightGray)
dev.setCursorPos(x, y + pageHeight)
dev.write(("\131"):rep(pageWidth))
dev.write("\129")
end

for i, line in ipairs(doc[page]) do
dev.setCursorPos(x, y + i - 1)
dev.blit(table.unpack(line))
end
setColor(dev, ofg, obg)
end

function sdoc.dump(fn, t)
local s = textutils.serialise(t)
local f = assert(fs.open(fn, "w"))
f.write(s)
f.close()
end





mbar.license = [[
Copyright 2024 Mason

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

mbar._VERSION = "1.1.1"










local dev

local state = {}

local fg, bg = colors.white, colors.gray
local hfg, hbg = colors.black, colors.white
local mfg, mbg = colors.black, colors.lightGray

local function color(fg, bg)
local ofg = dev.getTextColor()
local obg = dev.getBackgroundColor()
dev.setTextColor(fg or ofg)
dev.setBackgroundColor(bg or obg)
return ofg, obg
end

local function getLine(y)
return dev.getLine(y)
end

function mbar.corner(x, y, w, h, shadow)
local cfg = dev.getTextColor()
local cblit = colors.toBlit(cfg)

local tw, th = dev.getSize()
if y + h <= th then
local _, _, bgline = getLine(y + h)
local sw = math.min(w, tw - x + 1)
dev.setCursorPos(x, y + h)
dev.blit(("\131"):rep(sw), cblit:rep(sw), bgline:sub(x, x + sw - 1))
if x + w <= tw then
dev.setCursorPos(x + w, y + h)
dev.blit("\129", cblit, bgline:sub(x + w, x + w))
end
if shadow then
dev.setCursorPos(x, y + h)
dev.blit("\130", cblit, bgline:sub(x, x))
end
end
if x + w <= tw then
for i = 1, h do
local yp = y + i - 1
if yp <= th and yp >= 1 then
local _, _, bgline = getLine(yp)
dev.setCursorPos(x + w, yp)
dev.blit("\149", cblit, bgline:sub(x + w, x + w))
end
end
if shadow and y <= th then
dev.setCursorPos(x + w, y)
local _, _, bgline = getLine(y)
dev.blit("\148", cblit, bgline:sub(x + w, x + w))
end
end
end

function mbar.box(x, y, w, h)
local cfg = dev.getTextColor()
local cblit = colors.toBlit(cfg)
mbar.corner(x, y, w, h)
local tw, th = dev.getSize()
local yp = y - 1
if yp <= th and yp >= 1 then
dev.setCursorPos(x - 1, yp)
local _, _, bgline = getLine(yp)
dev.blit("\159", bgline:sub(x - 1, x - 1), cblit)
dev.setCursorPos(x, yp)
dev.blit(("\143"):rep(w), bgline:sub(x, x + w - 1), cblit:rep(w))
dev.setCursorPos(x + w, yp)
dev.blit("\144", cblit, bgline:sub(x + w, x + w))
end


for dy = 1, h do
local yp = y + dy - 1
if yp <= th and yp >= 1 then
local _, _, bgline = getLine(yp)
dev.setCursorPos(x - 1, yp)
dev.blit("\149", bgline:sub(x - 1, x - 1), cblit)
end
end
local yp = y + h
if yp <= th and yp >= 1 then
local _, _, bgline = getLine(y + h)
dev.setCursorPos(x - 1, y + h)
dev.blit("\130", cblit, bgline:sub(x - 1, x - 1))
end
end

local contrastBlitLut = {
["0"] = "f",
["1"] = "f",
["2"] = "f",
["3"] = "f",
["4"] = "f",
["5"] = "f",
["6"] = "f",
["7"] = "0",
["8"] = "f",
["9"] = "f",
["a"] = "f",
["b"] = "f",
["c"] = "0",
["d"] = "0",
["e"] = "f",
["f"] = "0",
}
local function drawInkRequirements(x, y, ink)
dev.setTextColor(colors.gray)
mbar.box(x, y, 12, 4)
for i = 0, 15 do
local color = 2 ^ i
local ch = colors.toBlit(color)
local level = ink[ch] or 0
local dx = (i % 4) * 3
local dy = math.floor(i / 4)
dev.setCursorPos(x + dx, y + dy)
local s = ("%3d"):format(level)
if level > 999 then
s = "+++"
end
dev.blit(s, contrastBlitLut[ch]:rep(3), ch:rep(3))
end
end

function mbar.popupPrint(ink, paper, string, leather)
local w = 14 + 8
local h = 6 + 3
local tw, th = dev.getSize()
local x, y = math.floor((tw - w) / 2), math.floor((th - h) / 2)
dev.setTextColor(colors.gray)
mbar.corner(x, y, w, h, true)
local ofg, obg = color(mfg, mbg)
mbar.fill(x, y, w, h)
dev.setTextColor(colors.white)
dev.setBackgroundColor(colors.gray)
mbar.fill(x, y, w, 1)
local title = "Print?"
local tx = math.floor((tw - #title) / 2)
dev.setCursorPos(tx, y)
dev.write("Print?")
drawInkRequirements(x + 1, y + 2, ink)
dev.setTextColor(colors.black)
dev.setBackgroundColor(colors.lightGray)
dev.setCursorPos(x + 15, y + 2)
dev.blit("\130", "8", "0")
dev.write((" %3d"):format(paper))
dev.setCursorPos(x + 15, y + 4)
dev.blit("@", "0", "8")
dev.write((" %3d"):format(string))
dev.setCursorPos(x + 15, y + 5)
dev.blit("\164", "c", "8")
dev.write((" %3d"):format(leather))
local optionX = x + w - 12
local optionY = y + h - 2
local options = { "No", "Yes" }
local optionPos = {}
for i, v in ipairs(options) do
color(hfg, hbg)
dev.setCursorPos(optionX, optionY)
dev.write(" " .. v .. " ")
color(bg, fg)
mbar.corner(optionX, optionY, #v + 2, 1, true)
optionPos[i] = optionX
optionX = optionX + #v + 3
end
color(bg, obg)
mbar.corner(x, y, w, h, true)
color(ofg, obg)
while true do
local _, _, x, y = os.pullEvent("mouse_click")
if y == optionY and x < optionX then
for i = #options, 1, -1 do
if x >= optionPos[i] then
return i == 2
end
end
end
end
end

local function intelligentCorner(menu)
local parent = menu.parent.parent
if not parent.bar and (menu.x ~= parent.x + parent.width) then
mbar.box(menu.x, menu.y, menu.width, menu.height)
return
end
local ofg, obg = color()
local cblit = colors.toBlit(ofg)
mbar.corner(menu.x, menu.y, menu.width, menu.height)
local _, fgline, bgline = getLine(menu.y - 1)
local tw, th = dev.getSize()
if menu.y > 2 then
local sx = 1
if menu.y > menu.parent.parent.y then
sx = 2
dev.setCursorPos(menu.x, menu.y - 1)
dev.blit("\138", bgline:sub(menu.x, menu.x), cblit)
end
for dx = sx, menu.width do
local x = menu.x + dx - 1
if x <= tw and x >= 1 then
dev.setCursorPos(x, menu.y - 1)
dev.blit("\143", bgline:sub(x, x), cblit)
end
end
local x = menu.x + menu.width
if x < tw then
dev.blit("\144", cblit, bgline:sub(x, x))
end
end
if not menu.parent.parent.bar and menu.y < menu.parent.parent.y then
local y = menu.parent.parent.y - 1
local x = menu.x - 1
_, _, bgline = getLine(y)
dev.setCursorPos(x, y)
dev.blit("\133", fgline:sub(x, x), cblit)
if menu.y > 2 then
y = menu.y - 1
_, _, bgline = getLine(y)
dev.setCursorPos(x, y)
dev.blit("\159", bgline:sub(x, x), cblit)
end
local ly = menu.parent.parent.y - menu.y
for dy = 1, ly do
y = menu.y + dy - 1
_, _, bgline = getLine(y)
dev.setCursorPos(x, y)
dev.blit("\149", bgline:sub(x, x), cblit)
end
end
if menu.x > 1 then
local sy = 1
if not menu.parent.parent.bar then
sy = menu.height - ((menu.y + menu.height) - (menu.parent.parent.y + menu.parent.parent.height)) + 2
end
for dy = sy, menu.height do
local y = menu.y + dy - 1
if y > th then
break
end
_, _, bgline = getLine(y)
local x = menu.x - 1
dev.setCursorPos(x, y)
dev.blit("\149", bgline:sub(x, x), cblit)
end
if not menu.parent.parent.bar and sy < menu.y + menu.height and menu.y + menu.height > menu.parent.parent.y + menu.parent.parent.height then
local y = menu.y + sy - 2
local x = menu.x - 1
_, _, bgline = getLine(y)
if not menu.parent.parent.bar then
dev.setCursorPos(x, y)
dev.blit("\148", bgline:sub(x, x), cblit)
end
elseif not menu.parent.parent.bar and menu.y + menu.height < menu.parent.parent.y + menu.parent.parent.height then
local x = menu.x
local y = menu.y + menu.height
_, _, bgline = getLine(y)
dev.setCursorPos(x, y)
dev.blit("\151", cblit, bgline:sub(x, x))
end
local x = menu.x - 1
local y = menu.y + menu.height
if y <= th and x >= 1 and x <= tw then
_, _, bgline = getLine(y)
dev.setCursorPos(x, y)
dev.blit("\130", cblit, bgline:sub(x, x))
end
end
color(ofg, obg)
end

function mbar.button(label, callback, submenu)
local button = {
label = label,
callback = callback,
submenu = submenu
}
if submenu then
submenu.parent = button
end

function button.click()
if button.callback then
button.callback(button)
end
state = {}
if button.submenu then
state[button.depth] = button.entry
local searched = button
for i = button.depth - 1, 1, -1 do
searched = searched.parent.parent
state[i] = searched.entry
end
end
end

return button
end

function mbar.toggleButton(label, callback)
local button = mbar.button(label, callback)

function button.setValue(value)
button.value = value
button.label = ("[%1s] %s"):format(value and "*" or " ", label)
if button.parent then
button.parent.updateSize()
end
end

button.setValue(false)

function button.click()
button.setValue(not button.value)
if button.callback then
button.callback(button)
end
state[button.depth] = nil
end

return button
end

function mbar.divider()
local divider = mbar.button("")
divider.divider = true

function divider.click()
end

return divider
end

function mbar.absMenu()
local menu = {
x = 1,
y = 2,
width = 1,
height = 1,
depth = 1
}

function menu.render(depth)
error("Render of abstract menu called!")
end

function menu.updatePos(x, y)
local w, h = dev.getSize()
x, y = x or menu.x, y or menu.y
y = math.max(2, math.min(y, h - menu.height))
local maxx = w - menu.width
x = math.min(maxx, x)
menu.x = x
menu.y = y
end

function menu.click(x, y)
error("Click of abstract menu called!")
end

function menu.updateDepth(i)
menu.depth = i
end

return menu
end

function mbar.charMenu(callback)
local menu = mbar.absMenu()
menu.callback = callback
menu.color = colors.black
menu.width, menu.height = 16, 16

function menu.render(depth)
local ofg, obg = color()
for y = 1, menu.height do
local str = ""
for x = 1, menu.width do
str = str .. string.char((y - 1) * menu.width + x - 1)
end
dev.setCursorPos(menu.x, menu.y + y - 1)
dev.blit(str, colors.toBlit(menu.color):rep(#str), ("0"):rep(#str))
end
color(bg, obg)
intelligentCorner(menu)
color(ofg, obg)
end

function menu.click(x, y)
local i = (y - 1) * menu.width + x - 1
local ch = string.char(i)
if menu.callback then
menu.callback(menu, ch)
end
return i
end

return menu
end


local colorMenuLUTs = {}
colorMenuLUTs.byIndex = {}
colorMenuLUTs.byColor = {}
colorMenuLUTs.byChar = {}

for i = 0, 15 do
local entry = {}
entry.index = i
entry.color = 2 ^ i
entry.char = ("%x"):format(i)
colorMenuLUTs.byIndex[entry.index] = entry
colorMenuLUTs.byColor[entry.color] = entry
colorMenuLUTs.byChar[entry.char] = entry
end

function mbar.colorMenu(callback)
local menu = mbar.absMenu()
menu.selected = 15
menu.selectedCol = colors.black
menu.selectedChar = "f"
menu.width, menu.height = 4, 4
menu.callback = callback

function menu.setSelected(i)
local info = colorMenuLUTs.byIndex[i] or
colorMenuLUTs.byChar[i] or
colorMenuLUTs.byColor[i]
assert(info, ("Invalid color selector %s"):format(tostring(i)))
menu.selected = info.index
menu.selectedCol = info.color
menu.selectedChar = info.char
end

function menu.render(depth)
local ofg, obg = color()
for x = 1, 4 do
for y = 1, 4 do
dev.setCursorPos(x + menu.x - 1, y + menu.y - 1)
local i = x + ((y - 1) * 4) - 1
dev.blit("\7", ("%x"):format(i), menu.selected == i and menu.selectedChar or "0")
end
end
color(menu.selectedCol, obg)
intelligentCorner(menu)
color(ofg, obg)
end

function menu.click(x, y)
menu.setSelected(x + ((y - 1) * 4) - 1)
if menu.callback then
menu.callback(menu)
end
return menu.selected
end

return menu
end

function mbar.radialMenu(options, callback)
local menu = mbar.absMenu()
menu.options = options
menu.selected = 1
menu.callback = callback

local function updateSize()
local width = 1
menu.height = #menu.options
for _, v in ipairs(menu.options) do
width = math.max(width, #v + 3)
end
menu.width = width
if menu.parent then
menu.parent.parent:updateSize()
end
end
updateSize()

function menu.render(depth)
local ofg, obg = color()
local s = (" %%1s%%-%ds"):format(menu.width - 2)
for i, v in ipairs(menu.options) do
if menu.selected == i then
color(hfg, hbg)
else
color(mfg, mbg)
end
dev.setCursorPos(menu.x, menu.y + i - 1)
dev.write(s:format(i == menu.selected and "\7" or "\186", v))
end
color(bg, obg)
intelligentCorner(menu)
color(ofg, obg)
end

function menu.click(x, y)
menu.selected = y
if menu.callback then
menu.callback(menu)
end
return y
end

function menu.updateOptions(options)
menu.options = options
menu.selected = math.min(menu.selected, #options)
updateSize()
end

return menu
end

function mbar.buttonMenu(buttons)
local menu = mbar.absMenu()
menu.buttons = buttons

for i, v in ipairs(menu.buttons) do
v.entry = i
v.parent = menu
end

function menu.updateSize()
local width = 1
menu.height = #menu.buttons
for _, v in ipairs(menu.buttons) do
width = math.max(width, #v.label + 3)
end
menu.width = width
for i, v in ipairs(menu.buttons) do
if v.submenu then
v.submenu.updatePos(menu.x + menu.width, menu.y + i - 1)
end
end
end

menu.updateSize()

function menu.render(depth)
local ofg, obg = color()
local s = (" %%-%ds%%1s"):format(menu.width - 2)
for i, v in ipairs(menu.buttons) do
if state[depth] == i then
color(hfg, hbg)
else
color(mfg, mbg)
end
dev.setCursorPos(menu.x, menu.y + i - 1)
if not v.divider then
dev.write(s:format(v.label, v.submenu and ">" or " "))
else
dev.write(("-"):rep(menu.width))
end
end
local selected = menu.buttons[state[depth]]
color(bg, obg)
intelligentCorner(menu)
color(ofg, obg)
if selected and selected.submenu then
selected.submenu.render(depth + 1)
end
end

local oldupdate = menu.updatePos
function menu.updatePos(x, y)
oldupdate(x, y)
for i, v in ipairs(menu.buttons) do
if v.submenu then
v.submenu.updatePos(menu.x + menu.width, menu.y + i - 1)
end
end
end

function menu.click(x, y)
local button = menu.buttons[y]
button.click()
return y
end

function menu.updateDepth(i)
for _, v in ipairs(menu.buttons) do
v.depth = i
if v.submenu then
v.submenu.updateDepth(i + 1)
end
end
end

return menu
end

function mbar.bar(buttons)
local bar = {
buttons = buttons,
buttonEnds = {},
bar = true
}
function bar.autosize()
local x = 1
for i, v in ipairs(bar.buttons) do
v.depth = 1
v.entry = i
v.parent = bar
if v.submenu then
v.submenu.updatePos(x)
v.submenu.updateDepth(2)
end
x = x + #v.label + 2
bar.buttonEnds[i] = x
end
end

bar.autosize()

function bar.render()
local tw, th = dev.getSize()
dev.setCursorPos(1, 1)
local ofg, obg = color(fg, bg)
dev.clearLine()
for i, v in ipairs(bar.buttons) do
if state[1] == i then
color(mfg, mbg)
else
color(fg, bg)
end
dev.write(" " .. v.label .. " ")
end
local selected = bar.buttons[state[1]]
color(ofg, obg)
if selected and selected.submenu then
selected.submenu.render(2)
end
end

function bar.click(x, y)
if y == 1 then
local entry
for i, v in ipairs(bar.buttonEnds) do
if x < v then
entry = i
break
end
end
if entry then
local button = bar.buttons[entry]
button.click()
else
state = {}
end
return true
end
local menu = bar
local menus = {}
for depth = 1, #state do
local v = state[depth]
if not (menu and menu.buttons) then break end
menu = menu.buttons[v].submenu
menus[#menus + 1] = menu
end
for depth = #menus, 1, -1 do
local menu = menus[depth]
if x >= menu.x and x < menu.x + menu.width and y >= menu.y and y < menu.y + menu.height then
local clicked = menu.click(x - menu.x + 1, y - menu.y + 1)
if clicked then
return true
end
end
end
if #state > 0 then
state = {}
return true
end
return false
end

local shortcuts = {}
local heldKeys = {}

function bar.shortcut(button, key, control, shift, alt)
local shortcut = {}
local label = {}
if alt then
shortcut[#shortcut + 1] = keys.leftAlt
label[#label + 1] = "alt+"
end
if control then
shortcut[#shortcut + 1] = keys.leftCtrl
label[#label + 1] = "^"
end
if shift then
shortcut[#shortcut + 1] = keys.leftShift
label[#label + 1] = keys.getName(key):upper()
else
label[#label + 1] = keys.getName(key)
end
shortcut[#shortcut + 1] = key
shortcut.button = button
button.label = ("%s (%s)"):format(button.label, table.concat(label))
button.parent.updateSize()
assert(shortcuts[key] == nil, ("Attempt to register repeated shortcut (%s)"):format(table.concat(label)))
shortcuts[key] = shortcut
return shortcut
end

function bar.resetKeys()
heldKeys = {}
end

function bar.onEvent(e)
local menuOpen = #state > 0
if e[1] == "mouse_click" then
return bar.click(e[3], e[4])
elseif e[1] == "key" then
heldKeys[e[2]] = true
local shortcut = shortcuts[e[2]]
if shortcut then
for _, v in ipairs(shortcut) do
if not heldKeys[v] then
return
end
end
shortcut.button.click()
return true
end
elseif e[1] == "key_up" then
heldKeys[e[2]] = nil
elseif menuOpen and (e[1] == "mouse_drag" or e[1] == "mouse_up") then
return true
end
end

return bar
end

function mbar.setWindow(win)
dev = win
end

function mbar.fill(x, y, w, h)
local s = (" "):rep(w)
for i = 0, h - 1 do
dev.setCursorPos(x, y + i)
dev.write(s)
end
end

function mbar.popup(title, text, options, w)
dev.setCursorBlink(false)
local tw, th = dev.getSize()
local ofg, obg = color(mfg, mbg)

local optionWidth = 0
for _, v in ipairs(options) do
optionWidth = optionWidth + #v + 3
end
w = math.max(optionWidth, w or 0)

local optionX = math.floor((tw - optionWidth) / 2)
local optionPos = {}

local s = require("cc.strings").wrap(text, w - 2)
local h = #s + 5
local x, y = math.floor((tw - w) / 2), math.max(3, math.floor((th - h) / 2))
local optionY = y + h - 2
mbar.fill(x, y, w, h)
for i, v in ipairs(s) do
dev.setCursorPos(x + 1, y + i + 1)
dev.write(v)
end
color(fg, bg)
mbar.fill(x, y, w, 1)
local tx = math.floor((tw - #title) / 2)
dev.setCursorPos(tx, y)
dev.write(title)
for i, v in ipairs(options) do
color(hfg, hbg)
dev.setCursorPos(optionX, optionY)
dev.write(" " .. v .. " ")
color(bg, fg)
mbar.corner(optionX, optionY, #v + 2, 1, true)
optionPos[i] = optionX
optionX = optionX + #v + 3
end
color(bg, obg)
mbar.corner(x, y, w, h, true)
color(ofg, obg)
while true do
local _, _, x, y = os.pullEvent("mouse_click")
if y == optionY and x < optionX then
for i = #options, 1, -1 do
if x >= optionPos[i] then
return i
end
end
end
end
end

function mbar.popupRead(title, w, text, completion, default)
dev.setCursorBlink(false)
local tw, th = dev.getSize()
local ofg, obg = color(mfg, mbg)
local h = 6
local x, y
if text then
local s = require("cc.strings").wrap(text, w - 2)
h = #s + 7
x, y = math.floor((tw - w) / 2), math.floor((th - h) / 2)
mbar.fill(x, y, w, h)
for i, v in ipairs(s) do
dev.setCursorPos(x + 1, y + i + 1)
dev.write(v)
end
else
x, y = math.floor((tw - w) / 2), math.floor((th - h) / 2)
mbar.fill(x, y, w, h)
end

color(fg, bg)
mbar.fill(x, y, w, 1)
local tx = math.floor((tw - #title) / 2)
dev.setCursorPos(tx, y)
dev.write(title)
color(bg, obg)
mbar.corner(x, y, w, h, true)
local readY = y + h - 4
local readWindow = window.create(dev, x + 1, readY, w - 2, 1)
readWindow.setTextColor(hfg)
readWindow.setBackgroundColor(hbg)
readWindow.clear()
readWindow.setCursorPos(1, 1)

local cancelX = x + 1
local cancelY = y + h - 2
local cancelW = 8
color(hfg, hbg)
dev.setCursorPos(cancelX, cancelY)
dev.write(" Cancel ")
color(bg, fg)
mbar.corner(cancelX, cancelY, cancelW, 1, true)

local oldWin = term.redirect(readWindow)

local value
parallel.waitForAny(function()
value = read(nil, nil, completion, default)
end, function()
while true do
local _, _, x, y = os.pullEvent("mouse_click")
if x >= cancelX and x < cancelX + cancelW and y == cancelY then
return
end
end
end)

term.redirect(oldWin)
color(ofg, obg)
return value
end



function supdate.checkUpdate(url, fn)
local data = {}
local response, reason = http.get(url)
if not response then
return nil, reason
end

local content = assert(response.readAll(), "No content?")
response.close()

local versionMatchStr = "local version = \"([%d%a%.%-]+)\""
local version = content:match(versionMatchStr)
local buildMatchStr = "local buildVersion = '([%d%a/%-]+)'"
local build = content:match(buildMatchStr)
if not (version and build) then
return nil, "No version/build information found!"
end
data.version = version
data.build = build

function data.save()
local f = assert(fs.open(fn, "w"))
f.write(content)
f.close()
end

return data, ""
end

function supdate.checkUpdatePopup(url, version, buildVersion)
local update, reason = supdate.checkUpdate(url, shell.getRunningProgram())
if not update then
mbar.popup("Failed", reason, { "Ok" }, 15)
return
end
if version ~= update.version or buildVersion ~= update.build then
local fstr = "%1s %-8s|%-8s"
local s = fstr:format("", "Version", "Build") .. "\n"
s = s .. fstr:format("O", version, buildVersion) .. "\n"
s = s .. fstr:format("N", update.version, update.build)
local choice = mbar.popup("Update?", s, { "Cancel", "Update" }, 22)
if choice == 2 then
update.save()
mbar.popup("Updated!", "Restart the program to use the new version.", { "Ok" }, 20)
end
end
end



spclib.PROTOCOL = "SHREKPRINT"

function spclib.aboutDocument(host, document, copies, book)
rednet.send(host, {
type = "DOCINFO",
document = document,
copies = copies,
asBook = book
}, spclib.PROTOCOL)
local id, msg = rednet.receive(spclib.PROTOCOL, 1)
if not (id and msg) then
return false, "Connection timed out.", {}, 0, 0, 0
end
return msg.result, msg.reason, msg.ink, msg.paper, msg.string, msg.leather
end

function spclib.printDocument(host, document, copies, book)
rednet.send(host, {
type = "PRINT",
document = document,
copies = copies,
asBook = book
}, spclib.PROTOCOL)
local id, msg = rednet.receive(spclib.PROTOCOL, 1)
if not (id and msg) then
return false, "Connection timed out."
end
return msg.result, msg.reason
end

function spclib.printerInfo(host)
rednet.send(host, {
type = "INFO"
}, spclib.PROTOCOL)
local id, msg = rednet.receive(spclib.PROTOCOL, 1)
if not (id and msg) then
return nil, {}, 0, 0, 0
end
return msg.name, msg.inkLevels, msg.paper, msg.string, msg.leather
end




local updateUrl = "https://github.com/ShrekshelleraiserCC/shrekword/releases/latest/download/sword.lua"

settings.define("sword.checkForUpdates", { type = "boolean", description = "Check for updates on startup" })
if settings.get("sword.checkForUpdates") == nil then
print("Check for updates on startup?")
settings.set("sword.checkForUpdates", read():sub(1, 1):lower() == "y")
settings.save()
end

local version = "1.1.2"
local buildVersion = '08/28/24'

local running = true

local args = { ... }

local a, b
local cursor = 1
local documentFilename
local documentString
local document
local documentUpdateRender = false
local documentUpdatedSinceSnapshot = false
local documentUpdatedSinceSave = false
local bar
local clipboard = ""
local copy, paste

local WIDTH, HEIGHT
local PHEIGHT
local pageX

local tw, th = term.getSize()
local win = window.create(term.current(), 1, 1, tw, th)
mbar.setWindow(win)

local function updateDocumentSize(w, h)
WIDTH, HEIGHT = w, h
PHEIGHT = HEIGHT + 2
pageX = math.max(2, math.floor((tw - WIDTH) / 2))
end
updateDocumentSize(25, 21)

local function updateTermSize()
tw, th = term.getSize()
win.reposition(1, 1, tw, th)
updateDocumentSize(WIDTH, HEIGHT)
end


local function documentRenderUpdate()
documentUpdateRender = true
end
local function documentContentUpdate()
documentUpdateRender = true
documentUpdatedSinceSave = true
documentUpdatedSinceSnapshot = true
end

local function openDocument(fn)
if not fs.exists(fn) then
mbar.popup("Error", ("File '%s' does not exist."):format(fn), { "Ok" }, 15)
bar.resetKeys()
return false
end
if fs.isDir(fn) then
mbar.popup("Error", "Directories are not documents!", { "Ok" }, 15)
bar.resetKeys()
return false
end
local f = assert(fs.open(fn, "r"))
local s = f.readAll()
f.close()
local ok, err = pcall(sdoc.decode, s)
if ok then
documentString = s
document = err
documentFilename = fn
updateDocumentSize(document.pageWidth, document.pageHeight)
documentRenderUpdate()
cursor = 1
a, b = nil, nil
return true
end
mbar.popup("Error", err , { "Ok :)", "Ok :(" }, 20)
bar.resetKeys()
return false
end
local function unsavedDocumentPopup()
if documentUpdatedSinceSave then
local option = mbar.popup("Warning", "You have unsaved changes. Discard these?", { "Yes", "No" },
20)
bar.resetKeys()
return option == 1
end
return true
end
local function newDocument()
if not unsavedDocumentPopup() then
return
end
documentString = "shrekdoc-v01w25h21mR:"
document = sdoc.decode(documentString)
updateDocumentSize(document.pageWidth, document.pageHeight)
documentRenderUpdate()
cursor = 1
documentFilename = nil
end

newDocument()
local scrollOffset = 1
local blit = sdoc.render(document, a, b)
local undoStates = { { state = documentString, cursor = cursor } }

local writeToDocument
local openButton = mbar.button("Open", function(entry)
if not unsavedDocumentPopup() then
return
end
local fn = mbar.popupRead("Open", 15, nil, function(str)
local list = require("cc.shell.completion").file(shell, str)
for i = #list, 1, -1 do
if not (list[i]:match("/$") or list[i]:match("%.sdoc$")) then
table.remove(list, i)
end
end
return list
end)
bar.resetKeys()
if fn then
openDocument(fn)
end
end)
local function saveAsRaw(fn)
local f = assert(fs.open(fn, "w"))
f.write(documentString)
f.close()
end
local function saveAs(fn)
saveAsRaw(fn)
documentUpdatedSinceSave = false
end
local saveAsButton = mbar.button("Save As", function(entry)
local fn = mbar.popupRead("Save As", 15)
bar.resetKeys()
if fn then
if fn:sub(-5) ~= ".sdoc" then
fn = fn .. ".sdoc"
end
saveAs(fn)
documentFilename = fn
end
end)
local saveButton = mbar.button("Save", function(entry)
if not documentFilename then
saveAsButton.click()
else
saveAs(documentFilename)
end
end)
local newButton = mbar.button("New", newDocument)

local modems = {}
peripheral.find("modem", function(name, wrapped)
modems[#modems + 1] = name
return true
end)
local selectedModem
local selectedHost
local completion = require "cc.completion"
local setModem, setHost
local function selectModem()
if #modems == 0 then
mbar.popup("No Modems!", "To print you need a modem connected.", { "Close" }, 20)
return false
end
if #modems > 1 and not selectedModem then
local selection = mbar.popupRead("Modem?", 20, "Enter the modem to use for printer lookup", function(str)
return completion.choice(str, modems, false)
end)
if not selection then
return false
end
if not peripheral.wrap(selection) then
return false
end
setModem(selection)
elseif not selectedModem then
setModem(modems[1])
end
return true
end
local hosts = {}
local hostnames = {}
local function lookupPrinters()
hosts = { rednet.lookup(spclib.PROTOCOL) }
for i, v in ipairs(hosts) do
local name = spclib.printerInfo(v)
hostnames[i] = name
end
end
local function selectHost()
if not selectedHost then
lookupPrinters()
if #hosts == 0 then
mbar.popup("No Printers!", "Found no printers!", { "Close" }, 15)
return false
elseif #hosts > 1 then
mbar.popup("Select a Host", "Select a host from Print > Host.", { "Ok" }, 20)
return false
else
setHost(hosts[1])
end
end
return true
end
local printButton = mbar.button("Print!", function(entry)
if not selectModem() then
return
end
rednet.open(selectedModem)
if not selectHost() then
return
end
local copies = tonumber(mbar.popupRead("Copies?", 15, nil, nil, "1"))
if not copies then
return
end
local book = #document.pages > 1 and mbar.popup("Books?", "Bundle each copy into a book", { "No", "Yes" }, 20) == 2
local ok, status, ink, paper, string, leather = spclib.aboutDocument(selectedHost, documentString, copies, book)
if not ok then
mbar.popup("Cannot Print", status, { "Close" }, 20)
return
end
local doPrint = mbar.popupPrint(ink, paper, string, leather)
if not doPrint then
return
end
ok, status = spclib.printDocument(selectedHost, documentString, copies, book)
if not ok then
mbar.popup("Failed to print", status, { "Close" }, 20)
return
end
mbar.popup("Printing!", "The document is now printing!", { "Ok" }, 15)
end)

local hostSelectMenu = mbar.radialMenu(hostnames, function(self)
setHost(hosts[self.selected])
end)
hostSelectMenu.selected = 0
local hostSelectButton = mbar.button("Host", nil, hostSelectMenu)
local modemSelectMenu
function setModem(modem)
if selectedModem then
rednet.close(selectedModem)
end
selectedModem = modem
rednet.open(selectedModem)
lookupPrinters()
hostSelectMenu.updateOptions(hostnames)
hostSelectMenu.selected = 0
for i, v in ipairs(modems) do
if v == modem then
modemSelectMenu.selected = i
break
end
end
selectedHost = nil
end

function setHost(host)
selectedHost = host
for i, v in ipairs(hosts) do
if v == host then
hostSelectMenu.selected = i
end
end
end

modemSelectMenu = mbar.radialMenu(modems, function(self)
setModem(modems[self.selected])
end)
modemSelectMenu.selected = 0
local modemSelectButton = mbar.button("Modem", nil, modemSelectMenu)

local printMenu = mbar.buttonMenu { modemSelectButton, hostSelectButton, printButton }
local printMenuButton = mbar.button("Print", nil, printMenu)

local quitButton = mbar.button("Quit", function()
if not unsavedDocumentPopup() then
return
end
if selectedModem then
rednet.close(selectedModem)
end
running = false
return true
end)

local updateButton = mbar.button("Update", function(entry)
supdate.checkUpdatePopup(updateUrl, version, buildVersion)
end)

local filesm = mbar.buttonMenu {
newButton,
mbar.divider(),
openButton,
mbar.divider(),
saveButton,
saveAsButton,
mbar.divider(),
printMenuButton,
updateButton,
quitButton
}

local fileButton = mbar.button("File", nil, filesm)
local charMenu = mbar.charMenu(function(self, ch)
writeToDocument(ch)
end)


local colorMenu = mbar.colorMenu(function(self)
charMenu.color = self.selectedCol
if a and b then
documentString = document:setColor(self.selectedChar, a, b)
document = sdoc.decode(documentString)
documentContentUpdate()
end
end)
local alignments = { "l", "c", "r" }
local alignmentMenu = mbar.radialMenu({ "Left", "Center", "Right" }, function(self)
local value = alignments[self.selected]
if a and b then
cursor = math.min(a, b)
end
documentString = document:setAlignment(cursor, value, b)
document = sdoc.decode(documentString)
documentContentUpdate()
end)
local colorButton = mbar.button("Color", nil, colorMenu)
local insertMenu = mbar.buttonMenu {
mbar.button("Character", nil, charMenu),
mbar.button("New Page", function(entry)
documentString = document:insertPage(cursor)
document = sdoc.decode(documentString)
documentContentUpdate()
end),
}
local undoButton = mbar.button("Undo", function(entry)
local str = table.remove(undoStates, 2)
if str then
documentString = str.state
document = sdoc.decode(documentString)
updateDocumentSize(document.pageWidth, document.pageHeight)
documentContentUpdate()
cursor = str.cursor
end
end)
local selectAllButton = mbar.button("Select All", function(entry)
a = 1
b = #document.editable.content[1]
documentRenderUpdate()
end)
local copyButton = mbar.button("Copy", function(entry)
copy()
end)
local pasteButton = mbar.button("Paste", function(entry)
paste()
end)

local titleButton = mbar.button("Title", function(entry)
local newTitle = mbar.popupRead("Title", 20, nil, nil, document.editable.title)
if newTitle then
if newTitle == "" then
newTitle = nil
end
document.editable.title = newTitle
documentString = sdoc.encode(document)
documentContentUpdate()
end
end)
local editDocumentMenu = mbar.buttonMenu { titleButton }
local editDocumentButton = mbar.button("Document", nil, editDocumentMenu)
local editMenu = mbar.buttonMenu {
mbar.button("Alignment", nil, alignmentMenu),
colorButton,
editDocumentButton,
mbar.divider(),
mbar.button("Insert", nil, insertMenu),
undoButton,
mbar.divider(),
selectAllButton,
copyButton,
pasteButton
}
local editButton = mbar.button("Edit", nil, editMenu)


local drawRuler = true
local drawRulerButton = mbar.toggleButton("Ruler", function(entry)
drawRuler = entry.value
end)
local drawStatusBar = true
local drawStatusBarButton = mbar.toggleButton("Status Bar", function(entry)
drawStatusBar = entry.value
end)
local drawDocumentBorder = true
local drawDocumentBorderButton = mbar.toggleButton("Doc. Border", function(entry)
drawDocumentBorder = entry.value
end)
drawStatusBarButton.setValue(true)
drawRulerButton.setValue(true)
drawDocumentBorderButton.setValue(true)
local drawCharInfo = false
local drawCharInfoButton = mbar.toggleButton("Character Info", function(entry)
drawCharInfo = entry.value
end)
local renderNewlines = false
local renderNewlineButton = mbar.toggleButton("New Lines", function(entry)
renderNewlines = entry.value
documentRenderUpdate()
end)
local renderNewpages = false
local renderNewpageButton = mbar.toggleButton("New Pages", function(entry)
renderNewpages = entry.value
documentRenderUpdate()
end)
local debugViewMenu = mbar.buttonMenu {
renderNewpageButton,
drawCharInfoButton
}
local debugViewButton = mbar.button("Debug", nil, debugViewMenu)
local viewMenu = mbar.buttonMenu({
drawRulerButton,
drawStatusBarButton,
drawDocumentBorderButton,
mbar.divider(),
renderNewlineButton,
debugViewButton
})
local viewButton = mbar.button("View", nil, viewMenu)
local helpButton = mbar.button("About", function()
win.setVisible(true)
local s = ("ShrekWord v%s\nMbar v%s\nSdoc v%s"):format(version, mbar._VERSION, sdoc._VERSION)

if buildVersion ~= "##VERSION" then
s = s .. ("\nBuild %s"):format(buildVersion)
end
mbar.popup("About", s, { "Close" }, 20)
bar.resetKeys()
win.setVisible(false)
end)

bar = mbar.bar({ fileButton, editButton, viewButton, helpButton })
bar.shortcut(saveButton, keys.s, true)
bar.shortcut(quitButton, keys.q, true)
bar.shortcut(undoButton, keys.z, true)
bar.shortcut(newButton, keys.n, true)
bar.shortcut(openButton, keys.o, true)
bar.shortcut(selectAllButton, keys.a, true)

local function documentIndexToScreen(idx)
local info = document.indicies[idx]
assert(info, ("%d %d %d"):format(idx, #document.indicies, #document.editable.content[1]))
local y = (info.page - 1) * PHEIGHT + info.line + 4 - scrollOffset
local lineX = 1
if document.pages[info.page][info.line] then
lineX = document.pages[info.page][info.line].lineX
end
assert(lineX, ("%d, %d, %d"):format(idx, info.page, info.line))
local x = info.col + pageX + lineX - 2
return x, y
end

local function moveScreenToFitCursor()
local x, y = documentIndexToScreen(cursor)
if y < 3 then
scrollOffset = scrollOffset - (3 - y)
elseif y > th - 1 then
scrollOffset = scrollOffset + y - th + 1
end
end

function writeToDocument(s)
if a and b then
a, b = math.min(a, b), math.max(a, b)
documentString = document:remove(a, b)
document = sdoc.decode(documentString)
cursor = a
a, b = nil, nil
end
documentString = document:insertAt(cursor, s, colorMenu.selectedChar)
document = sdoc.decode(documentString)
cursor = math.min(cursor + #s, #document.indicies)
moveScreenToFitCursor()
documentContentUpdate()
end

local function render()
win.setVisible(false)
win.setTextColor(colors.white)
win.setBackgroundColor(colors.black)
if documentUpdateRender then
blit = sdoc.render(document, a, b, renderNewlines, renderNewpages)
documentUpdateRender = false
end
win.clear()
scrollOffset = math.max(1, scrollOffset)
local maxScroll = #document.pages * PHEIGHT - th + 4
if #document.pages * PHEIGHT > th - 2 then
scrollOffset = math.min(maxScroll, scrollOffset)
else
scrollOffset = 1
end
local startPage = math.max(1, math.floor((scrollOffset - 2) / PHEIGHT) + 1)
local endPage = math.min(startPage + math.ceil(th / PHEIGHT), #document.pages)
for i = startPage, endPage do
local y = ((i - 1) * PHEIGHT) + 5 - scrollOffset
sdoc.blitOn(blit, i, pageX, y, win, drawDocumentBorder)
if drawRuler then
local rulerX = math.max(1, pageX - 2)
for dy = 1, HEIGHT do
win.setCursorPos(rulerX, y + dy - 1)
local ch = "\183"
if dy % 5 == 0 then
ch = "\7"
end
if dy % 10 == 0 then
ch = ("%d"):format(dy / 10)
end
win.write(ch)
end
end
end
if drawRuler then
win.setTextColor(colors.white)
win.setBackgroundColor(colors.black)
win.setCursorPos(pageX, 2)
for i = 1, WIDTH do
local ch = "\183"
if i % 5 == 0 then
ch = "\7"
end
if i % 10 == 0 then
ch = ("%d"):format(i / 10)
end
win.write(ch)
end
end
if drawStatusBar then
win.setTextColor(colors.white)
win.setBackgroundColor(colors.gray)
win.setCursorPos(1, th)
win.clearLine()
local info = document.indicies[cursor]
win.write(("[%1s]"):format(documentUpdatedSinceSave and "*" or ""))
win.write(("Page %d/%d | "):format(info.page, #document.pages))
win.write(("Cursor %d/%d"):format(cursor, #document.indicies))
end
if drawCharInfo then
win.setTextColor(colors.white)
win.setBackgroundColor(colors.black)
win.setCursorPos(1, 3)
local fgstr = document.editable.content[1]
win.write(("CH:%02X[%1s]"):format(fgstr:byte(cursor, cursor) or 0, fgstr:sub(cursor, cursor)))
win.setCursorPos(1, 4)
win.write(("PAGE:%1d"):format(document.editable.pages[cursor] or 0))
end
bar.render()
win.setCursorBlink(true)
win.setTextColor(colors.black)
win.setCursorPos(documentIndexToScreen(cursor))
win.setVisible(true)
end

local function screenToDocumentIndex(x, y)
local page = math.floor((y + scrollOffset - 4) / PHEIGHT) + 1
if page < 1 then
return
end
local line = y + scrollOffset - 4 - (page - 1) * PHEIGHT
if line < 1 or line > HEIGHT then
return
end
local chn
if x < pageX or x >= pageX + WIDTH then
return
end
local lineX = 1
if document.pages[page][line] then
lineX = document.pages[page][line].lineX
end
chn = x - pageX + 2 - lineX
return document.indexlut[page][line][chn]
end

local alignmentReverseLUT = {
l = 1,
c = 2,
r = 3
}
local function moveCursor(idx)
cursor = math.max(1, math.min(#document.editable.content[1] + 1, idx))
local info = document.indicies[cursor]
if info and document.pages[info.page][info.line] then
local alignment = document.pages[info.page][info.line].alignment
alignmentMenu.selected = alignmentReverseLUT[alignment]
local colch = document.editable.content[2]:sub(cursor, cursor)
if colch ~= "" then
colorMenu.setSelected(colch)
end
end
moveScreenToFitCursor()
end

local function deleteSelection()
if a and b then
a, b = math.min(a, b), math.max(a, b)
documentString = document:remove(a, b)
document = sdoc.decode(documentString)
moveCursor(a)
a, b = nil, nil
documentContentUpdate()
end
end

function copy()
if not (a and b) then
return
end
clipboard = document.editable.content[1]:sub(a, b)
end

function paste()
writeToDocument(clipboard)
end

local function wrapCursor(npage, nline)
if nline < 1 then
npage = npage - 1
if npage < 1 then
npage = 1
nline = 1
else
nline = #document.pages[npage]
end
elseif nline > #document.pages[npage] then
npage = npage + 1
if npage > #document.pages then
npage = #document.pages
nline = #document.pages[npage]
else
nline = 1
end
end
return npage, nline
end

local function scrollCursor(dlines, dpages)
dpages = dpages or 0
dlines = dlines or 0
local info = document.indicies[cursor]
local npage = info.page + dpages
local nline = info.line + dlines
npage, nline = wrapCursor(npage, nline)
if not document.pages[npage][nline] then
error(("%d %d"):format(npage, nline))
end
if document.pages[npage][nline][1] == "" then
nline = nline + dlines
npage, nline = wrapCursor(npage, nline)
end
cursor = document.indexlut[npage][nline][info.col]
moveScreenToFitCursor()
end

local function selectWord(idx)
local content = document.editable.content[1]
for i = idx, 1, -1 do
if content:sub(i, i):match("%s") then
break
end
a = i
end
if a then
cursor = a
for i = idx, #content do
if content:sub(i, i):match("%s") then
break
end
b = i
end
end
end

local lastClick = 0
local selectingWords = true
local function onEvent(e)
if e[1] == "mouse_scroll" then
scrollOffset = scrollOffset + e[2]
elseif e[1] == "mouse_click" then
local idx = screenToDocumentIndex(e[3], e[4])
a, b = nil, nil
local thisClick = os.epoch("utc")
local oldcursor = cursor
moveCursor(idx or cursor)
selectingWords = false
if thisClick - lastClick < 200 and idx == oldcursor then
selectWord(idx)
selectingWords = true
end
lastClick = thisClick
documentRenderUpdate()
elseif e[1] == "mouse_drag" then
local idx = screenToDocumentIndex(e[3], e[4])
if selectingWords and a and b then
local olda = math.min(a, b)
local oldb = math.max(a, b)
selectWord(idx or math.max(a, b))
a = math.min(a or cursor, olda)
b = math.max(b or cursor, oldb)
else
a = cursor
b = idx or b or cursor
end
documentRenderUpdate()
elseif e[1] == "key" then
if e[2] == keys.backspace then
if not (a or b) then
cursor = cursor - 1
if cursor < 1 then
cursor = 1
else
a = cursor
b = cursor
end
end
deleteSelection()
elseif e[2] == keys.delete then
if not (a or b) then
a = cursor
b = cursor
end
deleteSelection()
elseif e[2] == keys.left then
moveCursor(cursor - 1)
elseif e[2] == keys.right then
moveCursor(cursor + 1)
elseif e[2] == keys.enter then
deleteSelection()
writeToDocument("\n")
elseif e[2] == keys.up then
scrollCursor(-1)
elseif e[2] == keys.down then
scrollCursor(1)
elseif e[2] == keys.pageUp then
scrollCursor(-document.pageHeight)
elseif e[2] == keys.pageDown then
scrollCursor(document.pageHeight)
end
elseif e[1] == "char" then
deleteSelection()
writeToDocument(e[2])
elseif e[1] == "term_resize" then
updateTermSize()
bar.autosize()
elseif e[1] == "paste" then
writeToDocument(e[2])
end
end

local function mainLoop()
render()
if settings.get("sword.checkForUpdates") then
supdate.checkUpdatePopup(updateUrl, version, buildVersion)
end
if args[1] then
openDocument(args[1])
end
while running do
render()
local e = { os.pullEvent() }
if not bar.onEvent(e) then
onEvent(e)
end
end
end

local function undoTimer()
local tid = os.startTimer(1)
while true do
local _, id = os.pullEvent("timer")
if id == tid then
if documentUpdatedSinceSnapshot then
documentUpdatedSinceSnapshot = false
table.insert(undoStates, 1, { state = documentString, cursor = cursor })
saveAsRaw(".autosave.sdoc")
undoStates[10] = nil
end
tid = os.startTimer(1)
end
end
end

local function run()
parallel.waitForAny(
mainLoop,
undoTimer
)
end

local ok, err = xpcall(run, debug.traceback)
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
print(("Thank you for using ShrekWord v%s"):format(version))

if not ok then
term.setTextColor(colors.red)
print("Exited with error:")
print(err)
end

