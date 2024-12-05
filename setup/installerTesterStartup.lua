print("testing installer")
local input
repeat
    term.setTextColor(colors.red)
    print("THIS WILL WIPE THE PC AND IS A DEV TOOL, IF YOU ARE A USER ENTER N AND DELETE THIS FILE")
    term.setTextColor(colors.orange)
    print("Are you sure? y/n")
    term.setTextColor(colors.white)
    input = read()
until input == "y" or input == "n"
if input ~= "y" then error("installer testing aborted, computer will not be wiped") end

shell.run("rm *")
local fileHost = "https://raw.githubusercontent.com/";
local repoLoc = "hooded-person".."/".."KGinfractions";
local inbeteenShit = "/refs/heads/";
local branch = "main/";
local installerTestFileURL = fileHost..repoLoc..inbeteenShit..branch.."setup/installerTesterStartup.lua";
local installerFileUrl = fileHost..repoLoc..inbeteenShit..branch.."setup/installer.lua";
shell.run("wget "..installerTestFileURL.." startup.lua")
term.setTextColor(colors.white)
term.clear()
shell.run("wget run "..installerFileUrl)