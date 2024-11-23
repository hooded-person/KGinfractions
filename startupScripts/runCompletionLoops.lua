local completions = fs.list("/completion")
for i,v in ipairs(completions) do
    local filepath = "/completion/"..v.."/loop.lua" 
    if fs.exists(filepath) then
        shell.openTab(filepath)
    end
end