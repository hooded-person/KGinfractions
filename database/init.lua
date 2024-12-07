local db = {}
db._INTERNAL = {}
db.dirPath = "database"
db.dataPath = fs.combine(db.dirPath,"data.lon")

settings.define("kgDB.faultyDBtolerance", {
    description = "Wether too tolerate a faulty DB and continue with empty or too error",
    default = false,
    type = "boolean",
})

---@param coreFunc function the function that is wrapped
---@param saveData? boolean whether too save the data after running the function (save exec time when not modified)
---@return function the wrapped function
db._INTERNAL.base = function(coreFunc,saveData)
    if saveData == nil then saveData = true end
    return function(...) 
        local args = {...} 
        local h = fs.open(db.dataPath,"r")
        local data
        if h == nil then -- assume no database has existed yet and create empty table for one
            data = {}
        else
            data = h.readAll()
            h.close()
        end
        data = textutils.unserialise(data)

        if data == nil and settings.get("kgDB.faultyDBtolerance") then 
            data={} 
        elseif data == nil and not settings.get("kgDB.faultyDBtolerance") then
            error("faulty database, could not unserialise. Too use an empty database next time, set 'kgDB.faultyDBtolerance' too true")
        end

        local result = { coreFunc(data, table.unpack(args)) }
        if saveData then
            data = textutils.serialise(data)
            local h = fs.open(db.dataPath,"w")
            h.write(data)
            h.close()
        end

        return table.unpack(result)
    end
end

---@param newdata any the value to insert
---@param position number the position for where to insert
db.insert = db._INTERNAL.base(function (data, newdata, position)
    assert( type(data)=="table", "data is not a table, internal error or some")
    
    if position then
        table.insert(data,position,newdata)
    else
        table.insert(data,newdata)
    end
end)

---@param position number the position for the data too remove
---@return any the removed value
db.remove = db._INTERNAL.base(function (data, position)
    assert( type(data)=="table", "data is not a table, internal error or some")
    
    local result
    if position then
        result = table.remove(data,position)
    else
        result = table.remove(data)
    end
    return result
end)

---@return number length of the table
db.getn = db._INTERNAL.base(function (data)
    assert( type(data)=="table", "data is not a table, internal error or some")
    
    return table.getn(data)
end)

---@return number the highest numerical index of the table
db.maxn = db._INTERNAL.base(function (data)
    assert( type(data)=="table", "data is not a table, internal error or some")
    
    return table.maxn(data)
end)

---@param index any the index for the item too set
---@param newdata any the value to set
db.set = db._INTERNAL.base(function (data, index, newdata)
    assert( type(data)=="table", "data is not a table, internal error or some")
    assert( type(index)~="table", "tabled indexing is not supported for set, get the value and then modify it further")
    
    if type(index) ~= "table" then
        data[index] = newdata
    end
    
    --[[local indexRev = {}
    local item = data
    for i,v in ipairs(index) do
        item = item[v]
        table.insert(indexRev,v)
    end
    item = newdata --]]
end)

---@param index any the index for the item too get
---@return any the retrieved item
db.get = db._INTERNAL.base(function (data, index)
    assert( type(data)=="table", "data is not a table, internal error or some")

    if index == nil then return data end

    if type(index) ~= "table" then
        return data[index]
    end
    local item = data
    for i,v in ipairs(index) do
        item = item[v]
    end
    return item
end,false)

db.clear = db._INTERNAL.base(function (data)
    for k, _ in pairs(data) do data[k] = nil end

end)

return db