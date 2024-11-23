local libPaths = {"libs"}
for i=1,#libPaths do
    package.path = package.path..";/"..libPaths[i].."/?"..";/"..libPaths[i].."/?.lua"..";/"..libPaths[i].."/?/init.lua"
end