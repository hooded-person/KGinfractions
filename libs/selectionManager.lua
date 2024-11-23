-- manage selection
local Selection = {}
function Selection:new(o)
    o = o or { selected = {}, selecting = false, drag = nil } -- create object except if user has provided one
    setmetatable(o, self)
    self.__index = self
    return o
end

---@param item any The item too add the the array
---@param index the index at which to add the item
function Selection:add(item, index)
    if index then
        table.insert(self.selected, index, item)
    else
        table.insert(self.selected, item)
    end
end

---@param index the index at which to remove the item
function Selection:remove(index)
    if index then
        table.remove(self.selected, index)
    else
        table.insert(self.selected)
    end
end

---@param i number The index at which too retrieve the value
---@return any The value at that index
function Selection:get(i)
    return self.selected
end

---@return number The size of the selection
function Selection:size()
    return table.getn(self.selected)
end

function Selection:clear()
    self.selected = {}
end

---@param match any The value too match against
---@param pm boolean Use pattern matching
---@return boolean Wether the match was successfull
function Selection:contains(match, pm)
    if returnI == nil then returnq = false end
    if pm == nil then pm = false end
    if pm then assert(type(match) == string, "pattern matching requires a string as match") end
    for i, v in ipairs( self.selected ) do
        if pm and type(v) == "string" then
            if v:find(match) ~= nil then
                return true, i
            end
        else
            if v == match then
                return true, i
            end
        end
    end
    return false, nil
end

function Selection:toggle(item)
    local exists, itemI = self:contains(item)
    if exists then
        print("removing")
        self:remove(itemI)
    else
        print("adding")
        self:add(item)
    end
end

function Selection:isSelecting(value)
    if value ~= nil then 
        assert(type(value) == "boolean")
        self.selecting = value
    else 
        return self.selecting
    end
end

---@param x number starting X pos of selection
---@param y number starting Y pos of selection
function Selection:startDrag(x, y)
    self.drag = {{x, y}}
end

function Selection:hasDrag()
    local hasDrag = self.drag ~= nil
    return hasDrag
end
function Selection:moveDrag(x, y)
    local hasDrag = self.drag ~= nil
    local oldDrag = self.drag[#self.drag]
    if hasDrag and oldDrag[2] ~= y then
        table.insert(self.drag, {x, y})
    end
    return oldDrag
end

function Selection:getDragX(amount)
    if not amount then amount = 1 end
    local dragXs = {}
    for i = #self.drag, #self.drag-amount, -1 do 
        table.insert(dragXs, self.drag[i][1])
    end
    return table.unpack(dragYs)
end
function Selection:getDragY(amount)
    if not amount then amount = 1 end
    local dragYs = {}
    for i = #self.drag, #self.drag-amount, -1 do 
        local dragY = self.drag[i] and self.drag[i][2]
        table.insert(dragYs, dragY)
    end
    return table.unpack(dragYs)
end
function Selection:getDrag()
    return self.drag 
end

---@return number starting X pos of selection
---@return number starting Y pos of selection
function Selection:endDrag()
    local drag = self.drag
    if not drag then return nil, nil end
    self.drag = nil
    return table.unpack( drag[#drag] )
end

return Selection
