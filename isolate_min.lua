local isolate
isolate = {

    functions = {
        base64 = function()
            local enc = {
                [0] =
                "A",
                "B",
                "C",
                "D",
                "E",
                "F",
                "G",
                "H",
                "I",
                "J",
                "K",
                "L",
                "M",
                "N",
                "O",
                "P",
                "Q",
                "R",
                "S",
                "T",
                "U",
                "V",
                "W",
                "X",
                "Y",
                "Z",
                "a",
                "b",
                "c",
                "d",
                "e",
                "f",
                "g",
                "h",
                "i",
                "j",
                "k",
                "l",
                "m",
                "n",
                "o",
                "p",
                "q",
                "r",
                "s",
                "t",
                "u",
                "v",
                "w",
                "x",
                "y",
                "z",
                "0",
                "1",
                "2",
                "3",
                "4",
                "5",
                "6",
                "7",
                "8",
                "9",
                "+",
                "/"
            };

            local dec = {
                ["A"] = 0,
                ["B"] = 1,
                ["C"] = 2,
                ["D"] = 3,
                ["E"] = 4,
                ["F"] = 5,
                ["G"] = 6,
                ["H"] = 7,
                ["I"] = 8,
                ["J"] = 9,
                ["K"] = 10,
                ["L"] = 11,
                ["M"] = 12,
                ["N"] = 13,
                ["O"] = 14,
                ["P"] = 15,
                ["Q"] = 16,
                ["R"] = 17,
                ["S"] = 18,
                ["T"] = 19,
                ["U"] = 20,
                ["V"] = 21,
                ["W"] = 22,
                ["X"] = 23,
                ["Y"] = 24,
                ["Z"] = 25,
                ["a"] = 26,
                ["b"] = 27,
                ["c"] = 28,
                ["d"] = 29,
                ["e"] = 30,
                ["f"] = 31,
                ["g"] = 32,
                ["h"] = 33,
                ["i"] = 34,
                ["j"] = 35,
                ["k"] = 36,
                ["l"] = 37,
                ["m"] = 38,
                ["n"] = 39,
                ["o"] = 40,
                ["p"] = 41,
                ["q"] = 42,
                ["r"] = 43,
                ["s"] = 44,
                ["t"] = 45,
                ["u"] = 46,
                ["v"] = 47,
                ["w"] = 48,
                ["x"] = 49,
                ["y"] = 50,
                ["z"] = 51,
                ["0"] = 52,
                ["1"] = 53,
                ["2"] = 54,
                ["3"] = 55,
                ["4"] = 56,
                ["5"] = 57,
                ["6"] = 58,
                ["7"] = 59,
                ["8"] = 60,
                ["9"] = 61,
                ["+"] = 62,
                ["/"] = 63
            }

            local encode = function(s)
                local r = s:len() % 3;
                s = r == 0 and s or s .. ("\0"):rep(3 - r);
                local b64 = {};
                local count = 0;
                local len = s:len();
                local floor = math.floor;
                for i = 1, len, 3 do
                    local b1, b2, b3 = s:byte(i, i + 2);
                    count = count + 1;
                    b64[count] = enc[floor(b1 / 0x04)];
                    count = count + 1;
                    b64[count] = enc[floor(b2 / 0x10) + (b1 % 0x04) * 0x10];
                    count = count + 1;
                    b64[count] = enc[floor(b3 / 0x40) + (b2 % 0x10) * 0x04];
                    count = count + 1;
                    b64[count] = enc[b3 % 0x40];
                end
                count = count + 1;
                b64[count] = (r == 0 and "" or ("="):rep(3 - r));
                return table.concat(b64);
            end

            local decode = function(b64)
                local b, p = b64:gsub("=", "");
                local s = {};
                local count = 0;
                local len = b:len();
                local char, floor = string.char, math.floor;
                for i = 1, len, 4 do
                    local b1 = dec[b:sub(i, i)];
                    local b2 = dec[b:sub(i + 1, i + 1)];
                    local b3 = dec[b:sub(i + 2, i + 2)];
                    local b4 = dec[b:sub(i + 3, i + 3)];
                    count = count + 1;
                    s[count] = char(
                        b1 * 0x04 + floor(b2 / 0x10),
                        (b2 % 0x10) * 0x10 + floor(b3 / 0x04),
                        (b3 % 0x04) * 0x40 + b4
                    );
                end
                local result = table.concat(s);
                result = result:sub(1, -(p + 1));
                return result;
            end

            local base64encode, base64decode

            base64encode = setmetatable(
                {
                    type = "__function__",
                    source = "base64encode(s)\nReturns a string in the base64 format"
                },
                {
                    __call = function(self, s)
                        return encode(s)
                    end
                }
            )

            base64decode = setmetatable(
                {
                    type = "__function__",
                    source = "base64decode(b64)\nDecodes and increments a string from the base64 format"
                },
                {
                    __call = function(self, b64)
                        return decode(b64)
                    end
                }
            )

            return {
                base64decode = base64decode,
                base64encode = base64encode
            }
        end,
        default = function()
            local print, pcall, time, clock, type, tostring, tonumber, next, error, foreach

            do
                local serializeTable
                function serializeTable(tbl, indent, visited)
                    local function serializeValue(value, indent, visited)
                        if _G.type(value) == "table" then
                            return serializeTable(value, indent, visited)
                        elseif _G.type(value) == "string" then
                            return string.format("%q", value)
                        elseif _G.type(value) == "nil" then
                            return "nil"
                        elseif _G.type(value) == "boolean" then
                            return tostring(value)
                        else
                            return tostring(value)
                        end
                    end

                    indent = indent or 0
                    visited = visited or {}
                    local indentStr = string.rep("  ", indent)
                    local result = "{\n"

                    if visited[tbl] then
                        return indentStr .. "[cyclic table]"
                    end
                    visited[tbl] = true

                    local first = true
                    for key, value in pairs(tbl) do
                        if not first then
                            result = result .. ",\n"
                        end
                        first = false

                        local keyStr
                        if _G.type(key) == "string" and key:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
                            keyStr = key
                        else
                            keyStr = "[" .. serializeValue(key, indent + 1, visited) .. "]"
                        end

                        local valueStr = serializeValue(value, indent + 1, visited)
                        result = result .. indentStr .. "  " .. keyStr .. " = " .. valueStr
                    end

                    result = result .. "\n" .. indentStr .. "}"
                    visited[tbl] = nil
                    return result
                end

                local origPrint = _G.print
                print = setmetatable(
                    { type = "__function__", source = "print(arg1, ...arg)\nOutputs a message to the console." },
                    {
                        __call = function(self, ...)
                            local t = { ... }
                            for index, value in ipairs(t) do
                                if _G.type(value) == "table" then
                                    if value.type and value.type == "__function__" then
                                        t[index] = "(Function)\nlink: " ..
                                            tostring(value) ..
                                            "\nsource:\n" .. (value.source or "Not found") .. "\n(end Function)"
                                    else
                                        t[index] = tostring(value) .. "\nbody: " .. serializeTable(value) .. "\n(end)"
                                    end
                                else
                                    t[index] = tostring(value)
                                end
                            end
                            origPrint(table.concat(t, " "))
                        end
                    }
                )
            end

            pcall = setmetatable(
                {
                    type = "__function__",
                    source =
                    "pcall(func, ...arg)\nCalls function with arguments in protected mode, returns {success, result_or_error}"
                },
                {
                    __call = function(self, func, ...)
                        if _G.type(func) ~= "table" or func.type ~= "__function__" then
                            _G.error("pcall: First argument must be a function", 2)
                        end
                        local args = { ... }
                        local success, result = _G.pcall(function()
                            return func(unpack(args))
                        end)
                        return __ISOLATE__.createArray({ success, result })
                    end
                }
            )

            time = setmetatable({ type = "__function__", source = "time([date])\nReturns the current time in seconds" },
                {
                    __call = function(self, date)
                        return os.time(date)
                    end
                }
            )

            clock = setmetatable({ type = "__function__", source = "clock()\nReturns the current time in milliseconds" },
                {
                    __call = function(self)
                        return os.clock()
                    end
                }
            )

            type = setmetatable({ type = "__function__", source = "type(object)\nReturns the type of the variable" },
                {
                    __call = function(self, object)
                        local _type = _G.type(object)

                        if _type == "table" then
                            if object.type and object.type == "__function__" then
                                _type = "function"
                            elseif __ISOLATE__.analizy_array(object) then
                                _type = "array"
                            end
                        end

                        return _type
                    end
                }
            )

            tostring = setmetatable(
                { type = "__function__", source = "tostring(value)\nConverts the value to a string" },
                {
                    __call = function(self, value)
                        return _G.tostring(value)
                    end
                }
            )

            tonumber = setmetatable(
                { type = "__function__", source = "tonumber(value)\nConverts the value to a number" },
                {
                    __call = function(self, value)
                        return _G.tonumber(value)
                    end
                }
            )

            next = setmetatable(
                {
                    type = "__function__",
                    source =
                    "next(table, [index])\nReturns the following key-value pair in the table."
                },
                {
                    __call = function(self, table, index)
                        return __ISOLATE__.createArray({ _G.next(table, index) })
                    end
                }
            )

            error = setmetatable(
                { type = "__function__", source = "error(message, [level])\nCauses an error with the specified message.." },
                {
                    __call = function(self, message, level)
                        _G.error(message, level)
                    end
                }
            )

            foreach = setmetatable(
                {
                    type = "__function__",
                    source =
                    "foreach(table or array, callback)\nIt goes through a table or array and calls a callback(key or index, value) for each element."
                },
                {
                    __call = function(self, table, callback)
                        if _G.type(table) ~= "table" then
                            _G.error("foreach accepts only arrays or tables", 2)
                        end

                        if type(table) == "table" then
                            for key, value in pairs(table) do
                                callback(key, value)
                            end
                        else
                            for index, value in ipairs(table) do
                                callback(index, value)
                            end
                        end
                    end
                }
            )

            return {
                print = print,
                pcall = pcall,
                time = time,
                clock = clock,
                type = type,
                tostring = tostring,
                tonumber = tonumber,
                next = next,
                error = error,
                foreach = foreach,
            }
        end,

        json = function()
            --
            -- json.lua
            --
            -- Copyright (c) 2020 rxi
            --
            -- Permission is hereby granted, free of charge, to any person obtaining a copy of
            -- this software and associated documentation files (the "Software"), to deal in
            -- the Software without restriction, including without limitation the rights to
            -- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
            -- of the Software, and to permit persons to whom the Software is furnished to do
            -- so, subject to the following conditions:
            --
            -- The above copyright notice and this permission notice shall be included in all
            -- copies or substantial portions of the Software.
            --
            -- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            -- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            -- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            -- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            -- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            -- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            -- SOFTWARE.
            --

            local json = { _version = "0.1.2" }

            -------------------------------------------------------------------------------
            -- Encode
            -------------------------------------------------------------------------------

            local encode

            local escape_char_map = {
                ["\\"] = "\\",
                ["\""] = "\"",
                ["\b"] = "b",
                ["\f"] = "f",
                ["\n"] = "n",
                ["\r"] = "r",
                ["\t"] = "t",
            }

            local escape_char_map_inv = { ["/"] = "/" }
            for k, v in pairs(escape_char_map) do
                escape_char_map_inv[v] = k
            end


            local function escape_char(c)
                return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
            end


            local function encode_nil(val)
                return "null"
            end


            local function encode_table(val, stack)
                local res = {}
                stack = stack or {}

                -- Circular reference?
                if stack[val] then error("circular reference") end

                stack[val] = true

                if rawget(val, 1) ~= nil or next(val) == nil then
                    -- Treat as array -- check keys are valid and it is not sparse
                    local n = 0
                    for k in pairs(val) do
                        if type(k) ~= "number" then
                            error("invalid table: mixed or invalid key types")
                        end
                        n = n + 1
                    end
                    if n ~= #val then
                        error("invalid table: sparse array")
                    end
                    -- Encode
                    for i, v in ipairs(val) do
                        table.insert(res, encode(v, stack))
                    end
                    stack[val] = nil
                    return "[" .. table.concat(res, ",") .. "]"
                else
                    -- Treat as an object
                    for k, v in pairs(val) do
                        if type(k) ~= "string" then
                            error("invalid table: mixed or invalid key types")
                        end
                        table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
                    end
                    stack[val] = nil
                    return "{" .. table.concat(res, ",") .. "}"
                end
            end


            local function encode_string(val)
                return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
            end


            local function encode_number(val)
                -- Check for NaN, -inf and inf
                if val ~= val or val <= -math.huge or val >= math.huge then
                    error("unexpected number value '" .. tostring(val) .. "'")
                end
                return string.format("%.14g", val)
            end


            local type_func_map = {
                ["nil"] = encode_nil,
                ["table"] = encode_table,
                ["string"] = encode_string,
                ["number"] = encode_number,
                ["boolean"] = tostring,
                ["function"] = function() return '"no support functions"' end
            }


            encode = function(val, stack)
                local t = type(val)
                local f = type_func_map[t]
                if f then
                    return f(val, stack)
                end
                error("unexpected type '" .. t .. "'")
            end


            function json.encode(val)
                return (encode(val))
            end

            -------------------------------------------------------------------------------
            -- Decode
            -------------------------------------------------------------------------------

            local parse

            local function create_set(...)
                local res = {}
                for i = 1, select("#", ...) do
                    res[select(i, ...)] = true
                end
                return res
            end

            local space_chars  = create_set(" ", "\t", "\r", "\n")
            local delim_chars  = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
            local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
            local literals     = create_set("true", "false", "null")

            local literal_map  = {
                ["true"] = true,
                ["false"] = false,
                ["null"] = nil,
            }


            local function next_char(str, idx, set, negate)
                for i = idx, #str do
                    if set[str:sub(i, i)] ~= negate then
                        return i
                    end
                end
                return #str + 1
            end


            local function decode_error(str, idx, msg)
                local line_count = 1
                local col_count = 1
                for i = 1, idx - 1 do
                    col_count = col_count + 1
                    if str:sub(i, i) == "\n" then
                        line_count = line_count + 1
                        col_count = 1
                    end
                end
                error(string.format("%s at line %d col %d", msg, line_count, col_count))
            end


            local function codepoint_to_utf8(n)
                -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
                local f = math.floor
                if n <= 0x7f then
                    return string.char(n)
                elseif n <= 0x7ff then
                    return string.char(f(n / 64) + 192, n % 64 + 128)
                elseif n <= 0xffff then
                    return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
                elseif n <= 0x10ffff then
                    return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                        f(n % 4096 / 64) + 128, n % 64 + 128)
                end
                error(string.format("invalid unicode codepoint '%x'", n))
            end


            local function parse_unicode_escape(s)
                local n1 = tonumber(s:sub(1, 4), 16)
                local n2 = tonumber(s:sub(7, 10), 16)
                -- Surrogate pair?
                if n2 then
                    return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
                else
                    return codepoint_to_utf8(n1)
                end
            end


            local function parse_string(str, i)
                local res = ""
                local j = i + 1
                local k = j

                while j <= #str do
                    local x = str:byte(j)

                    if x < 32 then
                        decode_error(str, j, "control character in string")
                    elseif x == 92 then -- `\`: Escape
                        res = res .. str:sub(k, j - 1)
                        j = j + 1
                        local c = str:sub(j, j)
                        if c == "u" then
                            local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                                or str:match("^%x%x%x%x", j + 1)
                                or decode_error(str, j - 1, "invalid unicode escape in string")
                            res = res .. parse_unicode_escape(hex)
                            j = j + #hex
                        else
                            if not escape_chars[c] then
                                decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
                            end
                            res = res .. escape_char_map_inv[c]
                        end
                        k = j + 1
                    elseif x == 34 then -- `"`: End of string
                        res = res .. str:sub(k, j - 1)
                        return res, j + 1
                    end

                    j = j + 1
                end

                decode_error(str, i, "expected closing quote for string")
            end


            local function parse_number(str, i)
                local x = next_char(str, i, delim_chars)
                local s = str:sub(i, x - 1)
                local n = tonumber(s)
                if not n then
                    decode_error(str, i, "invalid number '" .. s .. "'")
                end
                return n, x
            end


            local function parse_literal(str, i)
                local x = next_char(str, i, delim_chars)
                local word = str:sub(i, x - 1)
                if not literals[word] then
                    decode_error(str, i, "invalid literal '" .. word .. "'")
                end
                return literal_map[word], x
            end


            local function parse_array(str, i)
                local res = {}
                local n = 1
                i = i + 1
                while 1 do
                    local x
                    i = next_char(str, i, space_chars, true)
                    -- Empty / end of array?
                    if str:sub(i, i) == "]" then
                        i = i + 1
                        break
                    end
                    -- Read token
                    x, i = parse(str, i)
                    res[n] = x
                    n = n + 1
                    -- Next token
                    i = next_char(str, i, space_chars, true)
                    local chr = str:sub(i, i)
                    i = i + 1
                    if chr == "]" then break end
                    if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
                end
                return res, i
            end


            local function parse_object(str, i)
                local res = {}
                i = i + 1
                while 1 do
                    local key, val
                    i = next_char(str, i, space_chars, true)
                    -- Empty / end of object?
                    if str:sub(i, i) == "}" then
                        i = i + 1
                        break
                    end
                    -- Read key
                    if str:sub(i, i) ~= '"' then
                        decode_error(str, i, "expected string for key")
                    end
                    key, i = parse(str, i)
                    -- Read ':' delimiter
                    i = next_char(str, i, space_chars, true)
                    if str:sub(i, i) ~= ":" then
                        decode_error(str, i, "expected ':' after key")
                    end
                    i = next_char(str, i + 1, space_chars, true)
                    -- Read value
                    val, i = parse(str, i)
                    -- Set
                    res[key] = val
                    -- Next token
                    i = next_char(str, i, space_chars, true)
                    local chr = str:sub(i, i)
                    i = i + 1
                    if chr == "}" then break end
                    if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
                end
                return res, i
            end


            local char_func_map = {
                ['"'] = parse_string,
                ["0"] = parse_number,
                ["1"] = parse_number,
                ["2"] = parse_number,
                ["3"] = parse_number,
                ["4"] = parse_number,
                ["5"] = parse_number,
                ["6"] = parse_number,
                ["7"] = parse_number,
                ["8"] = parse_number,
                ["9"] = parse_number,
                ["-"] = parse_number,
                ["t"] = parse_literal,
                ["f"] = parse_literal,
                ["n"] = parse_literal,
                ["["] = parse_array,
                ["{"] = parse_object,
            }


            parse = function(str, idx)
                local chr = str:sub(idx, idx)
                local f = char_func_map[chr]
                if f then
                    return f(str, idx)
                end
                decode_error(str, idx, "unexpected character '" .. chr .. "'")
            end


            function json.decode(str)
                if type(str) ~= "string" then
                    error("expected argument of type string, got " .. type(str))
                end
                local res, idx = parse(str, next_char(str, 1, space_chars, true))
                idx = next_char(str, idx, space_chars, true)
                if idx <= #str then
                    decode_error(str, idx, "trailing garbage")
                end
                return res
            end

            local jsonencode, jsondecode
            jsonencode = setmetatable(
                {
                    type = "__function__",
                    source =
                    "jsonencode(table)\nEncodes a table or array to a JSON string"
                },
                {
                    __call = function(self, t)
                        if type(t) ~= "table" then
                            return { false, "expected argument of type or array table, got " .. type(t) }
                        end
                        return json.encode(t)
                    end
                }
            )

            jsondecode = setmetatable(
                {
                    type = "__function__",
                    source =
                    "jsondecode(string)\nDecodes a JSON string to a table or array"
                },
                {
                    __call = function(self, s)
                        if type(s) ~= "string" then
                            return { false, "expected argument of type string, got " .. type(s) }
                        end
                        local result = json.decode(s)
                        result = __ISOLATE__.createArray(result)
                        return result
                    end
                }
            )

            return {
                jsondecode = jsondecode,
                jsonencode = jsonencode
            }
        end,

        math = function()
            local round, floor, ceil, abs, min, max, sqrt, pow, sin, rad, deg, log, random, randomseed, cos, tan

            round = setmetatable(
                {
                    type = "__function__",
                    source =
                    "round(number, [decimals])\nRounds number to the nearest integer or specified decimal places"
                },
                {
                    __call = function(self, num, decimals)
                        if type(num) ~= "number" then
                            error("round: First argument must be a number", 2)
                        end
                        decimals = decimals or 0
                        if type(decimals) ~= "number" then
                            error("round: Second argument must be a number", 2)
                        end
                        local mult = 10 ^ decimals
                        return math.floor(num * mult + 0.5) / mult
                    end
                }
            )

            floor = setmetatable(
                {
                    type = "__function__",
                    source = "floor(number)\nReturns the largest integer less than or equal to number"
                },
                {
                    __call = function(self, num)
                        if type(num) ~= "number" then
                            error("floor: Argument must be a number", 2)
                        end
                        return math.floor(num)
                    end
                }
            )

            ceil = setmetatable(
                {
                    type = "__function__",
                    source = "ceil(number)\nReturns the smallest integer greater than or equal to number"
                },
                {
                    __call = function(self, num)
                        if type(num) ~= "number" then
                            error("ceil: Argument must be a number", 2)
                        end
                        return math.ceil(num)
                    end
                }
            )

            abs = setmetatable(
                {
                    type = "__function__",
                    source = "abs(number)\nReturns the absolute value of number"
                },
                {
                    __call = function(self, num)
                        if type(num) ~= "number" then
                            error("abs: Argument must be a number", 2)
                        end
                        return math.abs(num)
                    end
                }
            )

            min = setmetatable(
                {
                    type = "__function__",
                    source = "min(...)\nReturns the minimum value from a list of numbers"
                },
                {
                    __call = function(self, ...)
                        local args = { ... }
                        if #args == 0 then
                            error("min: At least one number must be provided", 2)
                        end
                        for i, v in ipairs(args) do
                            if type(v) ~= "number" then
                                error("min: All arguments must be numbers", 2)
                            end
                        end
                        return math.min(...)
                    end
                }
            )

            max = setmetatable(
                {
                    type = "__function__",
                    source = "max(...)\nReturns the maximum value from a list of numbers"
                },
                {
                    __call = function(self, ...)
                        local args = { ... }
                        if #args == 0 then
                            error("max: At least one number must be provided", 2)
                        end
                        for i, v in ipairs(args) do
                            if type(v) ~= "number" then
                                error("max: All arguments must be numbers", 2)
                            end
                        end
                        return math.max(...)
                    end
                }
            )

            sqrt = setmetatable(
                {
                    type = "__function__",
                    source = "sqrt(number)\nReturns the square root of a number"
                },
                {
                    __call = function(self, num)
                        if type(num) ~= "number" then
                            error("sqrt: Argument must be a number", 2)
                        end
                        return math.sqrt(num)
                    end
                }
            )

            pow = setmetatable(
                {
                    type = "__function__",
                    source = "pow(base, exp)\nRaises the base number to the power of exp"
                },
                {
                    __call = function(self, base, exp)
                        if type(base) ~= "number" then
                            error("pow: Argument must be a number", 2)
                        end
                        return base ^ exp
                    end
                }
            )

            sin = setmetatable(
                {
                    type = "function",
                    source = "sin(number)\nReturns the sine of a number in radians"
                },
                {
                    __call = function(self, num)
                        if type(num) ~= "number" then
                            error("sin: Argument must be a number", 2)
                        end
                        return math.sin(num)
                    end
                }
            )

            cos = setmetatable(
                {
                    type = "function",
                    source = "cos(number)\nReturns the cosine of a number in radians"
                },
                {
                    __call = function(self, num)
                        if type(num) ~= "number" then
                            error("cos: Argument must be a number", 2)
                        end
                        return math.cos(num)
                    end
                }
            )

            tan = setmetatable(
                {
                    type = "function",
                    source = "tan(number)\nReturns the tangent of a number in radians"
                },
                {
                    __call = function(self, num)
                        if type(num) ~= "number" then
                            error("tan: Argument must be a number", 2)
                        end
                        return math.tan(num)
                    end
                }
            )
            rad = setmetatable(
                {
                    type = "function",
                    source = "rad(degrees)\nConverts degrees to radians"
                },
                {
                    __call = function(self, degrees)
                        if type(degrees) ~= "number" then
                            error("rad: Argument must be a number", 2)
                        end
                        return math.rad(degrees)
                    end
                }
            )
            deg = setmetatable(
                {
                    type = "function",
                    source = "deg(radians)\nConverts radians to degrees"
                },
                {
                    __call = function(self, radians)
                        if type(radians) ~= "number" then
                            error("deg: Argument must be a number", 2)
                        end
                        return math.deg(radians)
                    end
                }
            )
            log = setmetatable(
                {
                    type = "function",
                    source =
                    "log(number, [base])\nReturns the logarithm of number to the given base (natural log if base is omitted)"
                },
                {
                    __call = function(self, num, base)
                        if type(num) ~= "number" then
                            error("log: First argument must be a number", 2)
                        end
                        if base ~= nil and type(base) ~= "number" then
                            error("log: Base must be a number", 2)
                        end
                        if base then
                            return math.log(num) / math.log(base)
                        else
                            return math.log(num)
                        end
                    end
                }
            )

            random = setmetatable(
                {
                    type = "function",
                    source =
                    "random([min, max])\nReturns a random number. If no arguments, between 0 and 1; if one argument, integer from 1 to min; if two, integer from min to max"
                },
                {
                    __call = function(self, min, max)
                        if min ~= nil and type(min) ~= "number" then
                            error("random: Arguments must be numbers", 2)
                        end
                        if max ~= nil and type(max) ~= "number" then
                            error("random: Arguments must be numbers", 2)
                        end
                        if min == nil and max == nil then
                            return math.random()
                        elseif max == nil then
                            return math.random(min)
                        else
                            return math.random(min, max)
                        end
                    end
                }
            )

            randomseed = setmetatable(
                {
                    type = "function",
                    source = "randomseed(seed)\nSets the seed for the random number generator"
                },
                {
                    __call = function(self, seed)
                        if type(seed) ~= "number" then
                            error("randomseed: Seed must be a number", 2)
                        end
                        math.randomseed(seed)
                    end
                }
            )

            return {
                round = round,
                floor = floor,
                ceil = ceil,
                abs = abs,
                min = min,
                max = max,
                sqrt = sqrt,
                pow = pow,
                sin = sin,
                cos = cos,
                tan = tan,
                rad = rad,
                deg = deg,
                log = log,
                random = random,
                randomseed = randomseed
            }
        end,

        string = function()
            local strlen, trim, ltrim, rtrim, strreplace, strpos, strtolower, strtoupper, strformat, strsplit

            strlen = setmetatable(
                {
                    type = "__function__",
                    source = "strlen(text)\nReturns the length of the text"
                },
                {
                    __call = function(self, text)
                        return string.len(text)
                    end
                }
            )

            trim = setmetatable(
                {
                    type = "__function__",
                    source = "trim(text)\nRemoves leading and trailing whitespace from text"
                },
                {
                    __call = function(self, text)
                        return (text:gsub("^%s*(.-)%s*$", "%1"))
                    end
                }
            )

            ltrim = setmetatable(
                {
                    type = "__function__",
                    source = "ltrim(text)\nRemoves leading whitespace from text"
                },
                {
                    __call = function(self, text)
                        return (text:gsub("^%s*", ""))
                    end
                }
            )

            rtrim = setmetatable(
                {
                    type = "__function__",
                    source = "rtrim(text)\nRemoves trailing whitespace from text"
                },
                {
                    __call = function(self, text)
                        return (text:gsub("%s*$", ""))
                    end
                }
            )

            strreplace = setmetatable(
                {
                    type = "__function__",
                    source = "strreplace(text, find, replace)\nReplaces all occurrences of find with replace in text"
                },
                {
                    __call = function(self, text, find, replace)
                        return (text:gsub(find:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1"), replace))
                    end
                }
            )

            strpos = setmetatable(
                {
                    type = "__function__",
                    source =
                    "strpos(text, find)\nReturns the position of the first occurrence of find in text, or nil if not found"
                },
                {
                    __call = function(self, text, find)
                        local start = text:find(find, 1, true)
                        return start
                    end
                }
            )

            strtolower = setmetatable(
                {
                    type = "__function__",
                    source = "strtolower(text)\nConverts text to lowercase"
                },
                {
                    __call = function(self, text)
                        return string.lower(text)
                    end
                }
            )

            strtoupper = setmetatable(
                {
                    type = "__function__",
                    source = "strtoupper(text)\nConverts text to uppercase"
                },
                {
                    __call = function(self, text)
                        return string.upper(text)
                    end
                }
            )

            strformat = setmetatable(
                {
                    type = "__function__",
                    source = "strformat(format, ...)\nFormats a string using the given format and arguments"
                },
                {
                    __call = function(self, format, ...)
                        return string.format(format, ...)
                    end
                }
            )

            strsplit = setmetatable(
                {
                    type = "__function__",
                    source = "strsplit(string, sep)\nSplits a string into an array using the sep separator."
                },
                {
                    __call = function(self, str, sep)
                        local result = {}
                        for part in str:gmatch("[^" .. sep .. "]+") do
                            table.insert(result, part)
                        end
                        return __ISOLATE__.createArray(result)
                    end
                }
            )

            return {
                strlen = strlen,
                trim = trim,
                ltrim = ltrim,
                rtrim = rtrim,
                strreplace = strreplace,
                strpos = strpos,
                strtolower = strtolower,
                strtoupper = strtoupper,
                strformat = strformat,
                strsplit = strsplit
            }
        end
    },

    lexer = function()
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
    end,

    parser = function()
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
    end,

    intepretator = function()
        local listFunctions = { "default", "math", "string", "json", "base64" }

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
                    values = function()
                        local value_array = __ISOLATE__.createArray({})
                        for _, value in pairs(tbl) do
                            value_array.push(value)
                        end
                        return value_array
                    end,
                    has = function(key)
                        return tbl[key] ~= nil
                    end,
                    set = function(key, value)
                        tbl[key] = value
                        return tbl
                    end,
                    remove = function(key)
                        tbl[key] = nil
                        return tbl
                    end,
                    merge = function(table2)
                        for key, value in pairs(table2) do
                            tbl[key] = value
                        end
                        return tbl
                    end,
                    filter = function(callback)
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
                    map = function(callback)
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
                    size = function()
                        local size = 0
                        for _ in pairs(tbl) do
                            size = size + 1
                        end
                        return size
                    end,
                    clear = function()
                        for key in pairs(tbl) do
                            tbl[key] = nil
                        end
                        return tbl
                    end,
                    clone = function()
                        return __ISOLATE__.createTable(cloneTable(tbl))
                    end,
                    foreach = function(callback)
                        if callback then
                            for key, value in pairs(tbl) do
                                callback(key, value)
                            end
                        end
                        return tbl
                    end,
                    toarray = function()
                        local array = __ISOLATE__.createArray({})
                        for key, value in pairs(tbl) do
                            local element = __ISOLATE__.createTable({ key = key, value = value })
                            array.push(element)
                        end
                        return array
                    end,
                    find = function(callback)
                        if callback then
                            for key, value in pairs(tbl) do
                                if callback(key, value) then
                                    return __ISOLATE__.createTable({ key = key, value = value })
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

        local env = {
            vars = {
                loadedpackages = loadedModules
            },
            parent = nil
        }

        _G.__ISOLATE__ = {
            createArray = createArray,
            createTable = createTable,
            analizy_array = analizy_array,
            __env = env.vars
        }

        for i = 1, #listFunctions, 1 do
            for key, value in pairs(isolate.functions[listFunctions[i]]()) do
                env.vars[key] = value
            end
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
            local current_scope = env

            local function pushScope()
                current_scope = { vars = {}, parent = current_scope }
            end

            local function popScope()
                if current_scope.parent == nil then
                    error("Attempt to pop global scope", 2)
                end
                current_scope = current_scope.parent
            end

            local function getVar(name)
                local scope = current_scope
                while scope do
                    if scope.vars[name] ~= nil then
                        return scope.vars[name]
                    end
                    scope = scope.parent
                end
                return nil
            end

            local function setVar(name, value)
                local scope = current_scope
                while scope do
                    if scope.vars[name] ~= nil then
                        scope.vars[name] = value
                        return
                    end
                    scope = scope.parent
                end
                current_scope.vars[name] = value
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
                    source = source or "Not found",
                    closure_env = current_scope
                }
                local mt = {
                    __call = function(self, ...)
                        local allArgs = { ... }
                        local old_scope = current_scope
                        pushScope()
                        current_scope.parent = self.closure_env
                        local success, result = pcall(function()
                            for i, param in ipairs(self.params) do
                                current_scope.vars[param.name] = allArgs[i]
                            end
                            return execute(self.body)
                        end)
                        popScope()
                        current_scope = old_scope
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
                        return getVar(expr.name)
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

            local function loadModule(modulePath)
                if loadedModules[modulePath] then
                    return loadedModules[modulePath].exports
                end

                local filePath = modulePath:gsub("/", "%.") .. ".iso"
                filePath = filePath:gsub("%.iso%.iso$", ".iso")

                local content
                if _G.love and love.filesystem then
                    content = love.filesystem.read(filePath)
                    if not content then error("Failed to read: " .. filePath) end
                else
                    local file
                    for path in (package.path .. ";."):gmatch("[^;]+") do
                        local fullPath = path:gsub("%?.lua", filePath)
                        file = io.open(fullPath, "r")
                        if file then
                            content = file:read("*a")
                            file:close()
                            break
                        end
                    end
                    if not content then error("Module not found: " .. filePath) end
                end

                local tokenize = isolate.lexer()
                local parse = isolate.parser()
                local tokens = tokenize(content, modulePath)
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
                                        error(
                                            string.format("Invalid assignment target in for loop update: %s at %s:%d:%d",
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
                            local exports = loadModule(modulePath)
                            setVar(varName, exports)
                        else
                            loadModule(modulePath)
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
                        local exports = loadModule(modulePath)
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

            pushScope()
            local result = execute(ast.body)
            local topVars = scopes[1].vars
            popScope()
            return result, topVars
        end

        return interpret
    end
}

local tokenize = isolate.lexer()
local parse = isolate.parser()
local intepretator = isolate.intepretator()

local run = function(code, filename)
    local tokens = tokenize(code, "test.isolate")
    local ast = parse(tokens)
    return intepretator(ast)
end

local createfunction = function(func, source)
    return setmetatable({ type = "__function__", source = source or "Not found" }, {
        __call = function(t, ...)
            return func(...)
        end
    })
end

local addfunction = function(name, func, source)
    __ISOLATE__.__env[name] = createfunction(func, source)
end

local createarray = function(array)
    return __ISOLATE__.createArray(array or {})
end

local createtable = function(table)
    return __ISOLATE__.createTable(table or {})
end

local addpackage = function(name, package, globals)
    __ISOLATE__.__env.loadedpackages[name] = { exports = package or {}, globals = globals or {} }
end

return {
    run = run,
    addfunction = addfunction,
    createarray = createarray,
    createtable = createtable,
    addpackage = addpackage,
    createfunction = createfunction
}
