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
if
else
while
for
function
return
print
import
from
break
continue

if (1 == 100) {
    print(100)
}

-- комментарий
- минус
+ плюс
/ делить
* умножить
% делить с остатком
'' - строка с поддержкой многострочности
"" - строка с поддержкой многострочности
<=
>=
<
>
[] - массив
{} - таблица
= - установка значения
, - для разделения
== - сравнение

0-9 - числа
с поддержкой русских - строки

/*
Это комментарий
*/

and И
or ИЛИ
not НЕ
!= НЕ РАВНО

string
number
boolean
array
function
table
nil
any

a: string = "test"

true
false
nil
]]

local function tokenize(code, fileName)
    local tokens = {}
    local keywords = {
        ["if"] = true,
        ["else"] = true,
        ["while"] = true,
        ["for"] = true,
        ["function"] = true,
        ["return"] = true,
        ["import"] = true,
        ["from"] = true,
        ["break"] = true,
        ["continue"] = true,
        ["and"] = true,
        ["or"] = true,
        ["not"] = true,
        ["nil"] = true,
        ["true"] = true,
        ["false"] = true,
    }

    local charType = {}
    for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZа-яА-Я_"):gmatch(".") do
        charType[c] = "letter"
    end
    for c in ("0123456789"):gmatch(".") do
        charType[c] = "digit"
    end
    for c in ("+-*/=<>(){}[],:%."):gmatch(".") do
        charType[c] = "operator"
    end
    charType["'"] = "quote"
    charType['"'] = "quote"

    local i = 1
    local codeLength = #code
    local line = 1
    local column = 1

    local function extractFunctionSource(startPos)
        local depth = 0
        local pos = startPos
        local functionEnd = startPos

        while pos <= codeLength do
            local char = code:sub(pos, pos)
            if char == "{" then
                depth = depth + 1
                pos = pos + 1
                break
            end
            pos = pos + 1
        end

        if depth == 0 then
            return code:sub(startPos, startPos + 7)
        end

        while pos <= codeLength and depth > 0 do
            local char = code:sub(pos, pos)
            if char == "{" then
                depth = depth + 1
            elseif char == "}" then
                depth = depth - 1
            end
            pos = pos + 1
        end

        if depth == 0 then
            functionEnd = pos - 1
        else
            functionEnd = codeLength
        end

        return code:sub(startPos, functionEnd)
    end

    while i <= codeLength do
        local char = code:sub(i, i)

        if char:match("%s") or char == ";" then
            if char == "\n" then
                line = line + 1
                column = 1
            else
                column = column + 1
            end
            i = i + 1
            goto continue
        end

        if char == "/" and i + 1 <= codeLength and code:sub(i + 1, i + 1) == "*" then
            local endPos = code:find("*/", i + 2, true)
            if endPos then
                local lines = select(2, code:sub(i, endPos + 1):gsub("\n", "\n"))
                line = line + lines
                column = 1
                i = endPos + 2
            else
                i = codeLength + 1
                tokens[#tokens + 1] = {
                    type = "error",
                    value = "unterminated comment",
                    line = line,
                    column = column,
                    file = fileName
                }
            end
            goto continue
        end

        if char == "-" and i + 1 <= codeLength and code:sub(i + 1, i + 1) == "-" then
            local endPos = code:find("\n", i, true) or (codeLength + 1)
            local lines = select(2, code:sub(i, endPos - 1):gsub("\n", "\n"))
            line = line + lines
            column = 1
            i = endPos
            goto continue
        end

        if charType[char] == "letter" then
            local start = i
            while i <= codeLength and (charType[code:sub(i, i)] == "letter" or (i > start and charType[code:sub(i, i)] == "digit")) do
                i = i + 1
            end
            local value = code:sub(start, i - 1)
            tokens[#tokens + 1] = {
                type = keywords[value] and "keyword" or "identifier",
                value = value,
                line = line,
                column = column,
                file = fileName,
                source = value == "function" and extractFunctionSource(start) or nil
            }
            column = column + (i - start)
            goto continue
        end

        if charType[char] == "digit" then
            local start = i
            while i <= codeLength and (charType[code:sub(i, i)] == "digit" or code:sub(i, i):match("[.eE+-]")) do
                i = i + 1
            end
            local value = code:sub(start, i - 1)
            if value:match("^%d+%.?%d*[eE]?[+-]?%d*$") or value:match("^0[xX][0-9a-fA-F]+$") then
                tokens[#tokens + 1] = {
                    type = "number",
                    value = value,
                    line = line,
                    column = column,
                    file = fileName
                }
            else
                tokens[#tokens + 1] = {
                    type = "error",
                    value = "invalid number: " .. value,
                    line = line,
                    column = column,
                    file = fileName
                }
            end
            column = column + (i - start)
            goto continue
        end

        if charType[char] == "quote" then
            local quote = char
            local start = i
            i = i + 1
            while i <= codeLength and code:sub(i, i) ~= quote do
                if code:sub(i, i) == "\\" and i + 1 <= codeLength then
                    i = i + 2
                else
                    if code:sub(i, i) == "\n" then
                        line = line + 1
                        column = 1
                    else
                        column = column + 1
                    end
                    i = i + 1
                end
            end
            if i <= codeLength then
                i = i + 1
                tokens[#tokens + 1] = {
                    type = "string",
                    value = code:sub(start + 1, i - 2),
                    line = line,
                    column = column,
                    file = fileName
                }
                column = column + (i - start)
            else
                tokens[#tokens + 1] = {
                    type = "error",
                    value = "unterminated string",
                    line = line,
                    column = column,
                    file = fileName
                }
            end
            goto continue
        end

        if charType[char] == "operator" or char == "=" or char == "!" then
            local nextChar = i < codeLength and code:sub(i + 1, i + 1) or ""
            if (char == "<" and nextChar == "=") or
                (char == ">" and nextChar == "=") or
                (char == "=" and nextChar == "=") or
                (char == "!" and nextChar == "=") then
                i = i + 2
                tokens[#tokens + 1] = {
                    type = "operator",
                    value = char .. nextChar,
                    line = line,
                    column = column,
                    file = fileName
                }
                column = column + 2
            else
                i = i + 1
                tokens[#tokens + 1] = {
                    type = "operator",
                    value = char,
                    line = line,
                    column = column,
                    file = fileName
                }
                column = column + 1
            end
            goto continue
        end

        error("Unknown symbol line: " .. line .. " column: " .. column .. " symbol: " .. char, 2)
        tokens[#tokens + 1] = {
            type = "error",
            value = char,
            line = line,
            column = column,
            file = fileName
        }
        i = i + 1
        column = column + 1

        ::continue::
    end

    return tokens
end

return tokenize
