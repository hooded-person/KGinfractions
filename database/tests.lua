
local db = require "addProcessing"

local checks = {}
checks.table = function(a,b)
    return textutils.serialise(a) == textutils.serialise(b)
end
checks.string = function(a,b)
    return a == b
end
checks.number = function(a,b)
    return a == b
end

local tests = {}
---@param check any Item to check
---@param match? any Item to match against, if nil then it is the full db
---@param name? string Name for this test otherwise uses its index in the test table
local function test(check, match, name)
    if not match then match = db.get() end
    local result = checks[type(check)](check, match)
    table.insert(tests, result )

    write("test "..(name or table.getn(tests)).." ")
    if result then
        term.setTextColor(colors.green)
        print("passed")
    else
        term.setTextColor(colors.red)
        print("failed")
    end
    term.setTextColor(colors.white)
end
assert(table.concat({}) == table.concat(db.get()), "data did not start empty, invalid test")

db.insert("5")
test({"5"})

db.insert("cheese",1)
test({"cheese","5"})

test(
    db.remove(2), "5" )
test({"cheese"})

test(
    db.getn(), 1 )

db.insert("cheese",3)
test({"cheese",[ 3 ] = "cheese"})

test(
    db.maxn(), 3 )

db.set("wow",10)
test({"cheese",[ 3 ] = "cheese",wow = 10})

db.clear()
test({})