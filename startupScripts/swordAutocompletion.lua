local completion = require "cc.shell.completion"
shell.setCompletionFunction("sword.lua",completion.build(
    completion.file
))
