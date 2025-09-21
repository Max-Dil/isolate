local tokenize = require("isolate.lexer")
local parse = require("isolate.parser")
local intepretator = require("isolate.intepretator")

local run = function (code, filename)
    local tokens = tokenize(code, "test.isolate")
    local ast = parse(tokens)
    return intepretator(ast)
end

local createfunction = function (func, source)
    return setmetatable({type = "__function__", source = source or "Not found"}, {
        __call = function (t, ...)
            return func(...)
        end
    })
end

local addfunction = function (name, func, source)
    __ISOLATE__.__env[name] = createfunction(func, source)
end

local createarray = function (array)
    return __ISOLATE__.createArray(array or {})
end

local createtable = function (table)
    return __ISOLATE__.createTable(table or {})
end

local addpackage = function (name, package, globals)
    __ISOLATE__.__env.loadedpackages[name] = {exports = package or {}, globals = globals or {}}
end

return {
    run = run,
    addfunction = addfunction,
    createarray = createarray,
    createtable = createtable,
    addpackage = addpackage,
    createfunction = createfunction
}