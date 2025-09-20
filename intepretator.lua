--[[
MIT License

Copyright (c) 2025 Max-Dil

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local listFunctions = { "default", "math", "string", "json" }

local G__dir = ...
G__dir = G__dir:match("(.-)%.intepretator$")

local loadedModules = {}

local cloneTable
cloneTable = function(...)
    local tables = { ... }
    local new_table = {}
    local seen = {}

    local function deepCopy(t, target)
        if seen[t] then
            return seen[t]
        end
        seen[t] = target

        for key, value in pairs(t) do
            if type(value) == "table" then
                target[key] = deepCopy(value, {})
            else
                target[key] = value
            end
        end
        return target
    end

    for _, t in pairs(tables) do
        if type(t) == "table" then
            deepCopy(t, new_table)
        end
    end
    return new_table
end

local function createTable(tbl)
    return setmetatable(tbl, {
        __add = function(t1, t2)
            if type(t1) == "table" and type(t2) == "table" then
                return createTable(cloneTable(t1, t2))
            end
            error("Attempt to add non-table values in table addition operation", 2)
        end,
        __index = {
            keys = function()
                local key_array = __ISOLATE__.createArray({})
                for key in pairs(tbl) do
                    key_array.push(key)
                end
                return key_array
            end,
            values = function ()
                local value_array = __ISOLATE__.createArray({})
                for _, value in pairs(tbl) do
                    value_array.push(value)
                end
                return value_array
            end,
            has = function (key)
                return tbl[key] ~= nil
            end,
            set = function (key, value)
                tbl[key] = value
                return tbl
            end,
            remove = function (key)
                tbl[key] = nil
                return tbl
            end,
            merge = function (table2)
                for key, value in pairs(table2) do
                    tbl[key] = value
                end
                return tbl
            end,
            filter = function (callback)
                if callback then
                    local table_filter = __ISOLATE__.createTable({})
                    for key, value in pairs(tbl) do
                        if callback(key, value) then
                            table_filter[key] = value
                        end
                    end
                    return table_filter
                else
                    return __ISOLATE__.createTable(cloneTable(tbl))
                end
            end,
            map = function (callback)
                if callback then
                    local table_filter = __ISOLATE__.createTable({})
                    for key, value in pairs(tbl) do
                        table_filter[key] = callback(key, value)
                    end
                    return table_filter
                else
                    return __ISOLATE__.createTable(cloneTable(tbl))
                end
            end,
            size = function ()
                local size = 0
                for _ in pairs(tbl) do
                    size = size + 1
                end
                return size
            end,
            clear = function ()
                for key in pairs(tbl) do
                    tbl[key] = nil
                end
                return tbl
            end,
            clone = function ()
                return __ISOLATE__.createTable(cloneTable(tbl))
            end,
            foreach = function (callback)
                if callback then
                    for key, value in pairs(tbl) do
                        callback(key, value)
                    end
                end
                return tbl
            end,
            toarray = function ()
                local array = __ISOLATE__.createArray({})
                for key, value in pairs(tbl) do
                    local element = __ISOLATE__.createTable({key = key, value = value})
                    array.push(element)
                end
                return array
            end,
            find = function (callback)
                if callback then
                    for key, value in pairs(tbl) do
                        if callback(key, value) then
                            return __ISOLATE__.createTable({key = key, value = value})
                        end
                    end
                end
                return tbl
            end
        }
    })
end

local function createArray(arr)
    local methods = {
        join = function(separator)
            separator = separator or ","
            local result = {}
            for i = 1, #arr do
                result[i] = tostring(arr[i])
            end
            return table.concat(result, separator)
        end,
        map = function(callback)
            local result = {}
            for i = 1, #arr do
                result[i] = callback(arr[i], i, arr)
            end
            return createArray(result)
        end,
        push = function(...)
            local args = { ... }
            for _, value in ipairs(args) do
                arr[#arr + 1] = value
            end
            return #arr
        end,
        pop = function()
            if #arr == 0 then return nil end
            local value = arr[#arr]
            arr[#arr] = nil
            return value
        end,
        shift = function()
            if #arr == 0 then return nil end
            local value = arr[1]
            table.remove(arr, 1)
            return value
        end,
        unshift = function(...)
            local args = { ... }
            for i, value in ipairs(args) do
                table.insert(arr, 1, value)
            end
            return #arr
        end,
        slice = function(start, finish)
            start = start or 1
            finish = finish or #arr
            if start < 0 then start = #arr + start + 1 end
            if finish < 0 then finish = #arr + finish + 1 end
            local result = {}
            for i = start, finish do
                if i >= 1 and i <= #arr then
                    result[#result + 1] = arr[i]
                end
            end
            return createArray(result)
        end,
        remove = function(index)
            if type(index) ~= "number" then
                error("Index must be a number", 2)
            end
            if index < 1 or index > #arr then
                error("Index out of bounds", 2)
            end
            table.remove(arr, index)
            return createArray(arr)
        end,
        insert = function(index, value)
            if type(index) ~= "number" then
                error("Index must be a number", 2)
            end
            if index < 1 or index > #arr + 1 then
                error("Index out of bounds", 2)
            end
            table.insert(arr, index, value)
            return #arr
        end,
        sort = function(comp)
            local callback
            if comp then
                callback = function(a, b)
                    return comp(a, b)
                end
            end
            local r = {}
            for i = 1, #arr, 1 do
                r[i] = arr[i]
            end
            table.sort(r, callback)
            return createArray(r)
        end
    }

    return setmetatable(arr, {
        __add = function(t1, t2)
            if type(t1) == "table" and type(t2) == "table" then
                local result = {}
                for i = 1, #t1 do
                    if type(t1[i]) == "table" then
                        result[#result + 1] = cloneTable(t1[i])
                    else
                        result[#result + 1] = t1[i]
                    end
                end
                for i = 1, #t2 do
                    if type(t2[i]) == "table" then
                        result[#result + 1] = cloneTable(t2[i])
                    else
                        result[#result + 1] = t2[i]
                    end
                end
                return createArray(result)
            end
            error("Attempt to add non-array values in array addition operation", 2)
        end,
        __mul = function(t1, t2)
            if type(t1) == "table" and type(t2) == "number" then
                local result = {}
                for i = 1, t2 do
                    for j = 1, #t1 do
                        if type(t1[j]) == "table" then
                            result[#result + 1] = cloneTable(t1[j])
                        else
                            result[#result + 1] = t1[j]
                        end
                    end
                end
                return createArray(result)
            elseif type(t2) == "table" and type(t1) == "number" then
                local result = {}
                for i = 1, t1 do
                    for j = 1, #t2 do
                        if type(t2[j]) == "table" then
                            result[#result + 1] = cloneTable(t2[j])
                        else
                            result[#result + 1] = t2[j]
                        end
                    end
                end
                return createArray(result)
            end
            error("Array multiplication requires one array and one number", 2)
        end,
        __index = function(t, k)
            if k == "length" then
                return #t
            end
            return methods[k]
        end
    })
end

local analizy_array = function(t)
    if type(t) ~= "table" then
        return false, "Not a table"
    end

    if next(t) == nil then
        return false, "Empty table"
    end

    if #t == 0 then
        return false, "Empty table"
    end

    return true, t
end

_G.__ISOLATE__ = {
    createArray = createArray,
    createTable = createTable,
    analizy_array = analizy_array
}

local env = {
    loadedpackages = loadedModules
}
for i = 1, #listFunctions, 1 do
    local s, err = pcall(require, G__dir .. ".intepretator.functions." .. listFunctions[i])
    if s and type(err) == "table" then
        for key, value in pairs(err) do
            env[key] = value
        end
    else
        error("Error to load Functions: " .. listFunctions[i] .. " err: " .. tostring(err), 2)
    end
end

for key, value in pairs(env) do
    print(key, value.source)
    print()
end

local function interpret(ast)
    if type(ast) ~= "table" or not ast.type or ast.type ~= "Program" then
        local file = ast.file or "<unknown>"
        local line = ast.line or 1
        local column = ast.column or 1
        error(string.format("Invalid AST: Expected a Program node, got %s at %s:%d:%d",
            type(ast) == "table" and (ast.type or "unknown") or type(ast), file, line, column), 2)
    end

    local execute
    local scopes = { { vars = {} } }

    local function pushScope()
        table.insert(scopes, { vars = {} })
    end

    local function popScope()
        table.remove(scopes)
    end

    local function getVar(name, node)
        for i = #scopes, 1, -1 do
            if scopes[i].vars[name] then
                return scopes[i].vars[name]
            end
        end
        if env[name] then
            return env[name]
        end
        return nil
    end

    local function setVar(name, value)
        for i = #scopes, 1, -1 do
            if scopes[i].vars[name] then
                scopes[i].vars[name] = value
                return
            end
        end
        scopes[#scopes].vars[name] = value
    end

    local function getTableValue(tbl, key, node)
        if type(tbl) ~= "table" then
            local file = node.file or "<unknown>"
            local line = node.line or 1
            local column = node.column or 1
            error(string.format("Attempt to index a non-table value: %s at %s:%d:%d",
                tostring(tbl), file, line, column), 2)
        end
        return tbl[key]
    end

    local function setTableValue(tbl, key, value, node)
        if type(tbl) ~= "table" then
            local file = node.file or "<unknown>"
            local line = node.line or 1
            local column = node.column or 1
            error(string.format("Attempt to index a non-table value: %s at %s:%d:%d",
                tostring(tbl), file, line, column), 2)
        end
        tbl[key] = value
    end

    local function createFunction(params, body, source)
        local func = {
            type = "__function__",
            params = params,
            body = body,
            source = source or "Not found"
        }
        local mt = {
            __call = function(self, ...)
                local allArgs = { ... }
                pushScope()
                local success, result = pcall(function()
                    for i, param in ipairs(self.params) do
                        scopes[#scopes].vars[param.name] = allArgs[i]
                    end
                    return execute(self.body)
                end)
                popScope()
                if not success then
                    error(result, 2)
                end
                return result
            end
        }
        setmetatable(func, mt)
        return func
    end

    local function parseEscapeSequences(str)
        local result = str:gsub("\\([\\nt0r\"])", {
            ["n"] = "\n",
            ["t"] = "\t",
            ["0"] = "\0",
            ["r"] = "\r",
            ["\\"] = "\\",
            ["\""] = "\"",
            ["\'"] = "\'",
        })
        return result
    end

    local function evaluate(expr)
        if not expr then return nil end
        local s, err = pcall(function()
            if expr.type == "Number" then
                return tonumber(expr.value)
            elseif expr.type == "String" then
                return parseEscapeSequences(expr.value)
            elseif expr.type == "Boolean" then
                return expr.value == "true"
            elseif expr.type == "Nil" then
                return nil
            elseif expr.type == "Identifier" then
                return getVar(expr.name, expr)
            elseif expr.type == "FunctionExpression" then
                return createFunction(expr.params, expr.body, expr.source)
            elseif expr.type == "Binary" then
                local left = evaluate(expr.left)
                local right = evaluate(expr.right)
                if expr.operator == "+" then
                    if type(left) == "string" or type(right) == "string" then
                        return tostring(left) .. tostring(right)
                    else
                        return left + right
                    end
                elseif expr.operator == "*" then
                    if type(left) == "string" and type(right) == "number" then
                        return string.rep(left, right)
                    elseif type(right) == "string" and type(left) == "number" then
                        return string.rep(right, left)
                    else
                        return left * right
                    end
                elseif expr.operator == "-" then
                    return left - right
                elseif expr.operator == "/" then
                    return left / right
                elseif expr.operator == "%" then
                    return left % right
                elseif expr.operator == "<" then
                    return left < right
                elseif expr.operator == ">" then
                    return left > right
                elseif expr.operator == "<=" then
                    return left <= right
                elseif expr.operator == ">=" then
                    return left >= right
                elseif expr.operator == "==" then
                    return left == right
                elseif expr.operator == "!=" then
                    return left ~= right
                elseif expr.operator == "and" then
                    return left and right
                elseif expr.operator == "or" then
                    return left or right
                end
            elseif expr.type == "Unary" then
                local arg = evaluate(expr.argument)
                if expr.operator == "-" then
                    return -arg
                elseif expr.operator == "not" then
                    return not arg
                end
            elseif expr.type == "Array" then
                local arr = {}
                for i, elem in ipairs(expr.elements) do
                    arr[i] = evaluate(elem)
                end
                return createArray(arr)
            elseif expr.type == "Table" then
                local tbl = {}
                for _, field in ipairs(expr.fields) do
                    local key = evaluate(field.key)
                    if not key then
                        error("Invalid table key: Evaluated to nil", 2)
                    end
                    tbl[key] = evaluate(field.value)
                end
                return createTable(tbl)
            elseif expr.type == "Member" then
                local object = evaluate(expr.object)
                local key = expr.computed and evaluate(expr.property) or expr.property.name
                return getTableValue(object, key, expr)
            elseif expr.type == "Call" then
                local callee = evaluate(expr.callee)
                local args = {}
                for _, arg in ipairs(expr.arguments) do
                    table.insert(args, evaluate(arg))
                end
                if type(callee) == "function" or (type(callee) == "table" and callee.type == "__function__") then
                    return callee(unpack(args))
                else
                    error("Attempt to call a non-function value", 2)
                end
            end
            error("Unknown expression type", 2)
        end)
        if not s then
            local file = expr.file or "<unknown>"
            local line = expr.line or 1
            local column = expr.column or 1
            error(string.format(err .. " %s at %s:%d:%d", expr.type, file, line, column), 2)
        else
            return err
        end
    end

    local function loadModule(modulePath, node)
        if loadedModules[modulePath] then
            return loadedModules[modulePath].exports
        end

        local filePath = modulePath:gsub("/", ".") .. ".iso"
        filePath = filePath:gsub("%.iso%.iso$", ".iso")

        local code = love.filesystem.read(filePath)

        local tokenize = require(G__dir .. ".lexer")
        local parse = require(G__dir .. ".parser")
        local tokens = tokenize(code, modulePath)
        local ast = parse(tokens)

        local result, topVars = interpret(ast)
        local exports = type(result) == "table" and result or {}

        loadedModules[modulePath] = { exports = exports, globals = topVars }

        return exports
    end

    function execute(stmts)
        local result
        for _, stmt in ipairs(stmts) do
            if stmt.type == "VarDecl" then
                setVar(stmt.name, evaluate(stmt.init))
            elseif stmt.type == "Assignment" then
                if stmt.left.type == "Identifier" then
                    setVar(stmt.left.name, evaluate(stmt.value))
                elseif stmt.left.type == "Member" then
                    local object = evaluate(stmt.left.object)
                    local key = stmt.left.computed and evaluate(stmt.left.property) or stmt.left.property.name
                    setTableValue(object, key, evaluate(stmt.value), stmt.left)
                else
                    local file = stmt.left.file or "<unknown>"
                    local line = stmt.left.line or 1
                    local column = stmt.left.column or 1
                    error(string.format("Invalid assignment target: %s at %s:%d:%d",
                        stmt.left.type, file, line, column), 2)
                end
            elseif stmt.type == "ExpressionStmt" then
                evaluate(stmt.expression)
            elseif stmt.type == "Function" then
                setVar(stmt.name, createFunction(stmt.params, stmt.body, stmt.source))
            elseif stmt.type == "Call" then
                evaluate(stmt)
            elseif stmt.type == "If" then
                if evaluate(stmt.condition) then
                    local status = execute(stmt.consequent)
                    if status == "break" or status == "continue" then
                        return status
                    end
                elseif stmt.alternate then
                    local status = execute(stmt.alternate)
                    if status == "break" or status == "continue" then
                        return status
                    end
                end
            elseif stmt.type == "While" then
                while evaluate(stmt.test) do
                    local status = execute(stmt.body)
                    if status == "break" then
                        break
                    elseif status == "continue" then
                    end
                end
            elseif stmt.type == "For" then
                pushScope()
                if stmt.init then execute({ stmt.init }) end
                while stmt.test == nil or evaluate(stmt.test) do
                    local status = execute(stmt.body)
                    if status == "break" then
                        break
                    elseif status == "continue" then
                    end
                    if stmt.update then
                        if stmt.update.type == "Assignment" then
                            if stmt.update.left.type == "Identifier" then
                                setVar(stmt.update.left.name, evaluate(stmt.update.value))
                            elseif stmt.update.left.type == "Member" then
                                local object = evaluate(stmt.update.left.object)
                                local key = stmt.update.computed and evaluate(stmt.update.left.property) or
                                    stmt.update.left.property.name
                                setTableValue(object, key, evaluate(stmt.update.value), stmt.update.left)
                            else
                                local file = stmt.update.left.file or "<unknown>"
                                local line = stmt.update.left.line or 1
                                local column = stmt.update.left.column or 1
                                error(string.format("Invalid assignment target in for loop update: %s at %s:%d:%d",
                                    stmt.update.left.type, file, line, column), 2)
                            end
                        else
                            evaluate(stmt.update)
                        end
                    end
                end
                popScope()
            elseif stmt.type == "Return" then
                result = evaluate(stmt.argument)
                return result
            elseif stmt.type == "Break" then
                return "break"
            elseif stmt.type == "Continue" then
                return "continue"
            elseif stmt.type == "Import" then
                local modulePath = evaluate(stmt.module)
                if type(modulePath) ~= "string" then
                    local file = stmt.file or "<unknown>"
                    local line = stmt.line or 1
                    local column = stmt.column or 1
                    error(string.format("Module path must be a string, got %s at %s:%d:%d",
                        type(modulePath), file, line, column), 2)
                end
                if stmt.name then
                    local varName = stmt.name.name
                    if type(varName) ~= "string" then
                        local file = stmt.file or "<unknown>"
                        local line = stmt.line or 1
                        local column = stmt.column or 1
                        error(string.format("Variable name must be a string, got %s at %s:%d:%d",
                            type(varName), file, line, column), 2)
                    end
                    local exports = loadModule(modulePath, stmt)
                    setVar(varName, exports)
                else
                    loadModule(modulePath, stmt)
                end
            elseif stmt.type == "FromImport" then
                local modulePath = evaluate(stmt.module)
                if type(modulePath) ~= "string" then
                    local file = stmt.file or "<unknown>"
                    local line = stmt.line or 1
                    local column = stmt.column or 1
                    error(string.format("Module path must be a string, got %s at %s:%d:%d",
                        type(modulePath), file, line, column), 2)
                end
                local exports = loadModule(modulePath, stmt)
                for _, import in ipairs(stmt.names) do
                    local varName = import.name
                    if type(varName) ~= "string" then
                        local file = import.file or "<unknown>"
                        local line = import.line or 1
                        local column = import.column or 1
                        error(string.format("Variable name must be a string, got %s at %s:%d:%d",
                            type(varName), file, line, column), 2)
                    end
                    local value = exports[varName]
                    if value == nil then
                        value = loadedModules[modulePath].globals[varName]
                    end
                    if value == nil then
                        local file = import.file or "<unknown>"
                        local line = import.line or 1
                        local column = import.column or 1
                        error(string.format("Variable '%s' not found in module '%s' at %s:%d:%d",
                            varName, modulePath, file, line, column), 2)
                    end
                    setVar(varName, value)
                end
            end
        end
        return result
    end

    local result = execute(ast.body)
    local topVars = scopes[1].vars
    return result, topVars
end

return interpret
