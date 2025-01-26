--[[
The MIT License (MIT)

Copyright (c) 2024 kinggreen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local alphabet = {
    a={ "\x96\x83\x94",
        "\x97\x83\x95",
        "\x85\x20\x85"},
    b={ "\x97\x83\x94",
        "\x97\x83\x94",
        "\x8d\x8c\x81"},
    c={ "\x96\x83\x84",
        "\x95\x20\x20",
        "\x89\x8c\x81"},
    d={ "\x97\x83\x94",
        "\x95\x20\x95",
        "\x8d\x8c\x81"},
    e={ "\x97\x83\x81",
        "\x97\x83\x20",
        "\x8d\x8c\x84"},
    f={ "\x97\x83\x81",
        "\x97\x83\x20",
        "\x85\x20\x20"},
    g={ "\x96\x83\x81",
        "\x95\x82\x95",
        "\x89\x8c\x81"},
    h={ "\x95\x20\x95",
        "\x97\x83\x95",
        "\x85\x20\x85"},
    i={ "\x82\x97\x20",
        "\x20\x95\x20",
        "\x88\x8d\x20"},
    j={ "\x20\x20\x95",
        "\x20\x20\x95",
        "\x89\x8c\x81"},
    k={ "\x95\x98\x20",
        "\x9f\x90\x20",
        "\x85\x8a\x20"},
    l={ "\x95\x20\x20",
        "\x95\x20\x20",
        "\x8d\x8c\x84"},
    m={ "\x9d\x98\x95",
        "\x95\x20\x95",
        "\x85\x20\x85"},
    n={ "\x9d\x90\x95",
        "\x95\x82\x95",
        "\x85\x20\x85"},
    o={ "\x96\x83\x94",
        "\x95\x20\x95",
        "\x89\x8c\x81"},
    p={ "\x97\x83\x94",
        "\x97\x83\x20",
        "\x85\x20\x20"},
    q={ "\x96\x83\x94",
        "\x95\x20\x95",
        "\x89\x86\x84"},
    r={ "\x97\x83\x94",
        "\x97\x83\x94",
        "\x85\x20\x85"},
    s={ "\x96\x83\x84",
        "\x82\x83\x94",
        "\x89\x8c\x81"},
    t={ "\x83\x97\x81",
        "\x20\x95\x20",
        "\x20\x85\x20"},
    u={ "\x95\x20\x95",
        "\x95\x20\x95",
        "\x89\x8c\x81"},
    v={ "\x95\x20\x95",
        "\x95\x20\x95",
        "\x82\x86\x20"},
    w={ "\x95\x20\x95",
        "\x95\x90\x95",
        "\x87\x82\x85"},
    x={ "\x95\x20\x95",
        "\x9a\x8f\x90",
        "\x85\x20\x85"},
    y={ "\x95\x20\x95",
        "\x8a\x9a\x20",
        "\x20\x85\x20"},
    z={ "\x83\x83\x95",
        "\x98\x86\x20",
        "\x8d\x8c\x84"},
    ["!"]={ "\x20\x95\x20",
            "\x20\x95\x20",
            "\x20\x84\x20"},
    ["?"]={ "\x86\x83\x94",
            "\x20\x96\x20",
            "\x20\x84\x20"},
    ["$"]={ "\x98\x8d\x84",
            "\x82\x83\x94",
            "\x83\x87\x20"},
    [","]={ "\x20\x20\x20",
            "\x20\x20\x20",
            "\x20\x85\x20"},
    ["*"]={ "\x90\x20\x90",
            "\x86\x83\x84",
            "\x20\x20\x20"},
    ["+"]={ "\x20\x90\x20",
            "\x8c\x9d\x84",
            "\x20\x81\x20"},
    ["-"]={ "\x20\x20\x20",
            "\x8c\x8c\x84",
            "\x20\x20\x20"},
    ["="]={ "\x20\x20\x20",
            "\x83\x83\x81",
            "\x83\x83\x81"},
    ["."]={ "\x20\x20\x20",
            "\x20\x20\x20",
            "\x20\x84\x20"},
    ["@"]={ "\x96\x93\x94",
            "\x95\x83\x91",
            "\x82\x83\x20"},
    ["%"]={ "\x85\x98\x81",
            "\x98\x81\x94",
            "\x20\x20\x20"},--[[
    ["&"]={ "   ",
            "   ",
            "   "},--]]
    ["("]={ "\x20\x98\x81",
            "\x20\x95\x20",
            "\x20\x82\x84"},
    [")"]={ "\x89\x90\x20",
            "\x20\x95\x20",
            "\x86\x20\x20"},
    ["["]={ "\x20\x97\x81",
            "\x20\x95\x20",
            "\x20\x8d\x84"},
    ["]"]={ "\x83\x95\x20",
            "\x20\x95\x20",
            "\x8c\x85\x20"},
    ["{"]={ "\x20\x96\x81",
            "\x8a\x90\x20",
            "\x20\x89\x84"},
    ["}"]={ "\x83\x94\x20",
            "\x20\x9a\x20",
            "\x8c\x81\x20"},--[[
    ["<"]={ "   ",
            "   ",
            "   "},
    [">"]={ "   ",
            "   ",
            "   "},--]]
    ['"']={ "\x9a\x9a\x20",
            "\x20\x20\x20",
            "\x20\x20\x20"},
    ["\xdf"]={"\x97\x83\x94", -- double s B thing
              "\x95\x83\x94",
              "\x85\x83\x20"},
    ["\x7f"]={"\x86\x98\x81",
              "\x86\x98\x81",
              "\x86\x88\x81"},
    ["\xb1"]={"\x20\x94\x20",
              "\x83\x97\x81",
              "\x8c\x8c\x84"},
    ["\x13"]={"\x95\x20\x95",
              "\x95\x20\x95",
              "\x84\x20\x84"},
    ["\xc6"]={"\x96\x97\x81", -- AE
              "\x97\x97\x20",
              "\x85\x8d\x84"},
}
alphabet[" "] = {"\x20\x20\x20","\x20\x20\x20","\x20\x20\x20"} -- add space
return function (input)
    local out = {"","",""}
    for i=1, #input do -- generate table with 3 lines
        local v = input:sub(i, i):lower()
        if alphabet[v] then
            out[1] = out[1] .. alphabet[v][1]
            out[2] = out[2] .. alphabet[v][2]
            out[3] = out[3] .. alphabet[v][3]
        else
            term.setTextColor(colors.orange)
            print("'"..v.."' does not exist, skipping")
            term.setTextColor(colors.white)
        end
    end
    local result = out[1]
    for i=2,#out do -- combine the 3 lines into 1 string
        result = result.."\n"..out[i]
    end
    return result
end