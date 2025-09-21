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

--[[
Identifier - идентификаторы
Binary - бинарные операции
Unary - унарные операции
If - условный оператор
Block - блок кода
VarDecl - объявление переменной
Assignment - присваивание
Call - вызов функции
--]]

local parse = function(tokens)
    local parseExpression, parseStatement, parseArguments

    local current = 1

    local function peek()
        return tokens[current]
    end

    local function error(msg)
        local token = peek() or { line = "EOF", column = "EOF", source = "<unknown>" }
        _G.error(msg .. " at " .. token.source .. ":" .. token.line .. ":" .. token.column, 0)
    end

    local function advance()
        local token = tokens[current]
        if token then
            current = current + 1
        end
        return token
    end

    local function expect(value, typ)
        local token = advance()
        if not token then
            error("Expected " .. (value and "'" .. value .. "'" or typ and "a " .. typ or "token"))
        end
        if value and token.value ~= value then
            error("Expected '" .. value .. "' but got '" .. token.value .. "'")
        end
        if typ and token.type ~= typ then
            error("Expected type " .. typ .. " but got " .. token.type)
        end
        return token
    end

    local function getPrecedence(operator)
        local prec = {
            ["not"] = 7,
            ["*"] = 6,
            ["/"] = 6,
            ["%"] = 6,
            ["+"] = 5,
            ["-"] = 5,
            ["<"] = 3,
            [">"] = 3,
            ["<="] = 3,
            [">="] = 3,
            ["=="] = 3,
            ["!="] = 3,
            ["and"] = 2,
            ["or"] = 1
        }
        return prec[operator] or 0
    end

    local function parseBlock()
        expect("{", "operator")
        local body = {}
        while peek() and peek().value ~= "}" do
            local stmt = parseStatement()
            if stmt then
                table.insert(body, stmt)
            end
        end
        expect("}", "operator")
        return body
    end

    local function parsePrimaryExpression()
        local token = peek()
        if not token then return nil end

        if token.type == "number" then
            advance()
            return {
                type = "Number",
                value = token.value,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        elseif token.type == "string" then
            advance()
            return {
                type = "String",
                value = token.value,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        elseif token.type == "keyword" and (token.value == "true" or token.value == "false") then
            advance()
            return {
                type = "Boolean",
                value = token.value,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        elseif token.type == "keyword" and token.value == "nil" then
            advance()
            return {
                type = "Nil",
                value = token.value,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        elseif token.type == "identifier" then
            advance()
            return {
                type = "Identifier",
                name = token.value,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        elseif token.value == "(" and token.type == "operator" then
            advance()
            local expr = parseExpression()
            expect(")", "operator")
            expr.line = token.line
            expr.column = token.column
            expr.file = token.file or "<unknown>"
            return expr
        elseif token.value == "[" and token.type == "operator" then
            advance()
            local elements = {}
            if peek() and peek().value ~= "]" then
                repeat
                    table.insert(elements, parseExpression())
                    if peek() and peek().value == "," then
                        advance()
                    else
                        break
                    end
                until false
            end
            expect("]", "operator")
            return {
                type = "Array",
                elements = elements,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        elseif token.value == "{" and token.type == "operator" then
            advance()
            local fields = {}
            if peek() and peek().value ~= "}" then
                repeat
                    local key
                    if peek() and peek().value == "[" and peek().type == "operator" then
                        advance()
                        key = parseExpression()
                        expect("]", "operator")
                    else
                        local keyToken = expect(nil, "identifier")
                        key = {
                            type = "String",
                            value = keyToken.value,
                            line = keyToken.line,
                            column = keyToken.column,
                            file = keyToken.source or "<unknown>"
                        }
                    end

                    expect("=", "operator")
                    local val = parseExpression()
                    table.insert(fields, { key = key, value = val })

                    if peek() and peek().value == "," then
                        advance()
                        if peek() and peek().value == "}" then
                            break
                        end
                    elseif peek() and peek().value ~= "}" then
                        error("Expected ',' or '}' in table")
                    else
                        break
                    end
                until false
            end
            expect("}", "operator")
            return {
                type = "Table",
                fields = fields,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        elseif token.type == "keyword" and token.value == "function" then
            advance()
            local params = {}
            expect("(", "operator")
            if peek() and peek().value ~= ")" then
                repeat
                    local param = expect(nil, "identifier")
                    table.insert(params, {
                        name = param.value,
                        line = param.line,
                        column = param.column,
                        file = param.source or "<unknown>"
                    })
                    if peek() and peek().value == "," then
                        advance()
                    else
                        break
                    end
                until false
            end
            expect(")", "operator")
            local body = parseBlock()
            return {
                type = "FunctionExpression",
                params = params,
                body = body,
                source = token.source or "Not found",
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        else
            error("Unexpected token in primary expression: " .. token.value)
        end
    end

    local function parsePostfixExpression()
        local expr = parsePrimaryExpression()
        while peek() do
            local token = peek()
            if token.value == "." and token.type == "operator" then
                advance()
                local property = expect(nil, "identifier")
                expr = {
                    type = "Member",
                    object = expr,
                    property = {
                        type = "Identifier",
                        name = property.value,
                        line = property.line,
                        column = property.column,
                        file = property.source or "<unknown>"
                    },
                    computed = false,
                    line = token.line,
                    column = token.column,
                    file = token.file or "<unknown>"
                }
            elseif token.value == "[" and token.type == "operator" then
                advance()
                local property = parseExpression()
                expect("]", "operator")
                expr = {
                    type = "Member",
                    object = expr,
                    property = property,
                    computed = true,
                    line = token.line,
                    column = token.column,
                    file = token.file or "<unknown>"
                }
            elseif token.value == "(" and token.type == "operator" then
                advance()
                local args = parseArguments()
                expect(")", "operator")
                expr = {
                    type = "Call",
                    callee = expr,
                    arguments = args,
                    line = token.line,
                    column = token.column,
                    file = token.file or "<unknown>"
                }
            else
                break
            end
        end
        return expr
    end

    local function parseUnary()
        local token = peek()
        local op
        if token.type == "operator" and token.value == "-" then
            advance()
            op = "-"
        elseif token.type == "keyword" and token.value == "not" then
            advance()
            op = "not"
        end
        if op then
            local argument = parseUnary()
            return {
                type = "Unary",
                operator = op,
                argument = argument,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        end
        return parsePostfixExpression()
    end

    function parseExpression(minPrec)
        if minPrec == nil then minPrec = 0 end
        local left = parseUnary()
        while true do
            local token = peek()
            if not token then break end
            local op
            if token.type == "operator" and ({ ["+"] = true, ["-"] = true, ["*"] = true, ["/"] = true, ["%"] = true, ["<"] = true, [">"] = true, ["<="] = true, [">="] = true, ["=="] = true, ["!="] = true })[token.value] then
                op = token.value
            elseif token.type == "keyword" and (token.value == "and" or token.value == "or") then
                op = token.value
            else
                break
            end
            local prec = getPrecedence(op)
            if prec < minPrec then break end
            advance()
            local right = parseExpression(prec + 1)
            left = {
                type = "Binary",
                left = left,
                operator = op,
                right = right,
                line = token.line,
                column = token.column,
                file = token.file or "<unknown>"
            }
        end
        return left
    end

    function parseArguments()
        local args = {}
        if peek() and peek().value ~= ")" then
            repeat
                table.insert(args, parseExpression())
                if peek() and peek().value == "," then
                    advance()
                else
                    break
                end
            until false
        end
        return args
    end

    local function parseIf()
        local token = advance()
        expect("(", "operator")
        local condition = parseExpression()
        expect(")", "operator")
        local consequent = parseBlock()
        local alternate
        if peek() and peek().value == "else" then
            advance()
            alternate = parseBlock()
        end
        return {
            type = "If",
            condition = condition,
            consequent = consequent,
            alternate = alternate,
            line = token.line,
            column = token.column,
            file = token.file or "<unknown>"
        }
    end

    local function parseWhile()
        local token = advance()
        expect("(", "operator")
        local test = parseExpression()
        expect(")", "operator")
        local body = parseBlock()
        return {
            type = "While",
            test = test,
            body = body,
            line = token.line,
            column = token.column,
            file = token.file or "<unknown>"
        }
    end

    local function parseFor()
        local token = advance()
        expect("(", "operator")
        local init
        if peek() and peek().value ~= "," then
            init = parseStatement()
        end
        expect(",", "operator")
        local test
        if peek() and peek().value ~= "," then
            test = parseExpression()
        end
        expect(",", "operator")
        local update
        if peek() and peek().value ~= ")" then
            local left = parseExpression()
            local token = peek()
            if left.type == "Identifier" and token and token.value == "=" then
                advance()
                local value = parseExpression()
                update = {
                    type = "Assignment",
                    left = left,
                    value = value,
                    line = token.line,
                    column = token.column,
                    file = token.file or "<unknown>"
                }
            else
                update = left
            end
        end
        expect(")", "operator")
        local body = parseBlock()
        return {
            type = "For",
            init = init,
            test = test,
            update = update,
            body = body,
            line = token.line,
            column = token.column,
            file = token.file or "<unknown>"
        }
    end

    local function parseFunction(sourceToken)
        advance()
        local name = expect(nil, "identifier")
        expect("(", "operator")
        local params = {}
        if peek() and peek().value ~= ")" then
            repeat
                local param = expect(nil, "identifier")
                table.insert(params, {
                    name = param.value,
                    line = param.line,
                    column = param.column,
                    file = param.file or "<unknown>"
                })
                if peek() and peek().value == "," then
                    advance()
                else
                    break
                end
            until false
        end
        expect(")", "operator")
        local body = parseBlock()
        return {
            type = "Function",
            name = name.value,
            params = params,
            body = body,
            source = sourceToken.source or "Not found",
            line = sourceToken.line,
            column = sourceToken.column,
            file = sourceToken.source or "<unknown>"
        }
    end

    local function parseReturn()
        local token = advance()
        local argument = parseExpression()
        return {
            type = "Return",
            argument = argument,
            line = token.line,
            column = token.column,
            file = token.file or "<unknown>"
        }
    end

    local function parseImport()
        local token = advance()
        local module = parseExpression()
        local name
        if peek() and peek().value == "from" then
            advance()
            name = parseExpression()
        end
        return {
            type = "Import",
            module = module,
            name = name,
            line = token.line,
            column = token.column,
            file = token.file or "<unknown>"
        }
    end

    local function parseFrom()
        local token = advance()
        local module = parseExpression()
        expect("import", "keyword")
        local names = {}
        repeat
            local name = expect(nil, "identifier")
            table.insert(names, {
                name = name.value,
                line = name.line,
                column = name.column,
                file = name.source or "<unknown>"
            })
            if peek() and peek().value == "," then
                advance()
            else
                break
            end
        until false
        return {
            type = "FromImport",
            module = module,
            names = names,
            line = token.line,
            column = token.column,
            file = token.file or "<unknown>"
        }
    end

    local function parseBreak()
        local token = advance()
        return {
            type = "Break",
            line = token.line,
            column = token.column,
            file = token.file or "<unknown>"
        }
    end

    local function parseContinue()
        local token = advance()
        return {
            type = "Continue",
            line = token.line,
            column = token.column,
            file = token.file or "<unknown>"
        }
    end

    function parseStatement()
        local token = peek()
        if not token then return nil end

        if token.type == "keyword" then
            if token.value == "if" then
                return parseIf()
            elseif token.value == "while" then
                return parseWhile()
            elseif token.value == "for" then
                return parseFor()
            elseif token.value == "function" then
                return parseFunction(token)
            elseif token.value == "return" then
                return parseReturn()
            elseif token.value == "import" then
                return parseImport()
            elseif token.value == "from" then
                return parseFrom()
            elseif token.value == "break" then
                return parseBreak()
            elseif token.value == "continue" then
                return parseContinue()
            else
                error("Unexpected keyword: " .. token.value)
            end
        else
            local left = parseExpression()
            token = peek()
            if token and token.value == "=" then
                advance()
                local value = parseExpression()
                if left.type == "Identifier" and value and value.type == "FunctionExpression" then
                    return {
                        type = "Function",
                        name = left.name,
                        params = value.params,
                        body = value.body,
                        source = value.source,
                        line = left.line,
                        column = left.column,
                        file = left.file or "<unknown>"
                    }
                elseif left.type == "Identifier" then
                    return {
                        type = "VarDecl",
                        name = left.name,
                        init = value,
                        line = left.line,
                        column = left.column,
                        file = left.file or "<unknown>"
                    }
                else
                    return {
                        type = "Assignment",
                        left = left,
                        value = value,
                        line = token.line,
                        column = token.column,
                        file = token.file or "<unknown>"
                    }
                end
            else
                return {
                    type = "ExpressionStmt",
                    expression = left,
                    line = left.line,
                    column = left.column,
                    file = left.file or "<unknown>"
                }
            end
        end
    end

    local firstToken = tokens[1] or { line = 1, column = 1, source = "<unknown>" }
    local ast = {
        type = "Program",
        body = {},
        line = firstToken.line,
        column = firstToken.column,
        file = firstToken.source or "<unknown>"
    }
    while current <= #tokens do
        local stmt = parseStatement()
        if stmt then
            table.insert(ast.body, stmt)
        else
            break
        end
    end
    return ast
end

return parse
