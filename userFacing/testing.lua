-- targetTable = {
--     firigr = {
--         ergrgr = {
--             [1] = {
--                 ["355"] = {
--                     fdeda = {
--                         [4] = "you win"
--                     }
--                 }
--             }
--         }
--     }
-- }
-- target = ".firigr.ergrgr,1.355.fdeda,4"
-- query = ""
-- for typeChar, match in target:gmatch("([.,])([^.,]*)") do
--     if typeChar == "." then
--         match = '["'..match..'"]'
--     elseif typeChar == "," then
--         match = '['..match..']'
--     end
--     query = query .. match
-- end
-- retrieved = load("return searchingTable"..query, "=generatedIndexing", "t", { searchingTable = targetTable } )()
-- print(retrieved)
entry = {
    user = "Janko1902",
    source = "M.re-print",
    deadline = 1730895132,
    time = 1730578013.739,
    templateFile = "warnIllegalItem.sdoc",
    formatData = {
        date = "30/10/2024",
        user = "4Rust_CZ",
        item = "a",
        deadline = "06/11/2024",
    },
    template = {
        "WARN",
        "illegal item",
    },
}

queryInput = "template"
queryFn, err = load(
    "input=...; input.type=input.template[1]; input.template=input.template[2]; input.reason=input.template[2];_ENV = setmetatable({setmetatable = setmetatable}, {__index = input}) return " ..
    queryInput,
    "=query",
    "t", { setmetatable = setmetatable })
if not queryFn then error(err) end
print(queryFn(entry))
