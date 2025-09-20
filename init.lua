local tokenize = require("isolate.lexer")
local parse = require("isolate.parser")
local intepretator = require("isolate.intepretator")

local run = function (code, filename)
    local tokens = tokenize(code, "test.isolate")
    local ast = parse(tokens)
    return intepretator(ast)
end

return run