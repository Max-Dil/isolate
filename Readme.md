# Isolate Documentation

Isolate — легковесный интерпретируемый язык, созданный для безопасной изоляции компонентов программ и игр на основе LuaJIT. Благодаря песочнице, ограничивающей доступ к опасным функциям LuaJIT, он обеспечивает безопасность и производительность.

## 1. Переменные
Переменные создаются просто:  
`name = value`

**Пример**:  
```isolate
count = 100 -- Создает переменную, хранящую число 100
```

- Переменные, объявленные в скрипте, доступны во всем скрипте.  
- Переменные, объявленные в функции, локальны и доступны только в теле функции.  

**Типы данных**:  
- `number` — числа  
- `string` — строки  
- `array` — массивы  
- `table` — таблицы  
- `boolean` — булевы значения  
- `function` — функции  
- `nil` — ничего  

**Зарезервированные ключевые слова** (нельзя использовать для имен переменных):  
`if`, `else`, `while`, `for`, `function`, `return`, `import`, `from`, `break`, `continue`, `and`, `or`, `not`, `nil`, `true`, `false`

## 2. Комментарии
**Однострочные**:  
```isolate
-- Это комментарий
```

**Многострочные**:  
```isolate
/*
Это комментарий
из нескольких строк
*/
```

## 3. Вывод в консоль
Функция `print` выводит данные в консоль. Она доступна во всех скриптах.  

- Поддерживает вывод таблиц, массивов и функций (для функций показывает мини-документацию вместо исходного кода).  

**Пример**:  
```isolate
print("Hello") -- Hello
```

## 4. Операторы
### 4.1 Математические
- `-` — минус  
- `+` — плюс  
- `/` — деление  
- `*` — умножение  
- `%` — деление с остатком  

### 4.2 Условные
- `<=` — меньше или равно  
- `>=` — больше или равно  
- `<` — меньше  
- `>` — больше  
- `==` — равно  

**Пример**:  
```isolate
a = 10 * 2 -- 20
b = a == 20
print(b) -- true
```

## 5. Строки
Тип `string`. Строки создаются в одинарных (`'`) или двойных (`"`) кавычках.  

**Пример**:  
```isolate
a = "Hello, world!"
```

**Спецсимволы**:  
- `\n` — перенос строки  
- `\0` — пустой символ  
- `\t` — табуляция  
- `\r` — возврат каретки  
- `\'` — одинарная кавычка  
- `\"` — двойная кавычка  

**Операции**:  
- `+` — объединение строк  
- `*` — повторение строки N раз  

**Пример**:  
```isolate
a = "Hello, " + "world!" -- Hello, world!
b = "Hello" * 2 -- HelloHello
```

## 6. Массивы
Массивы создаются с помощью квадратных скобок:  
```isolate
array = [100, 200, 300, 400, 500]
```

- Доступ к элементам: `array[1]` — возвращает `100`.  
- Размер массива: `array.length` — возвращает длину массива.  

**Пример**:  
```isolate
print(array.length) -- 5
```

- Поддержка оператора `+` для объединения массивов (создается новый массив и значения из второго массива добавляются к первому).Можно использовать для клонирования массивов. (var = array + [] -- новая копия)

**Методы массивов**:  
1. `join(separator)` — объединяет элементы в строку с указанным разделителем.  
   ```isolate
   text = array.join(",") -- "100,200,300,400,500"
   ```
2. `map(callback)` — применяет callback к каждому элементу, возвращает новый массив.  
   Callback: `element, index, array`.  
   ```isolate
   array.map(function(element, index) {
       print(element, index) -- 100, 1
   })
   ```
3. `push(...)` — добавляет элементы в конец массива.  
   ```isolate
   array.push(600) -- [100, 200, 300, 400, 500, 600]
   ```
4. `pop()` — возвращает и удаляет последний элемент.  
   ```isolate
   element = array.pop() -- 500
   ```
5. `shift()` — возвращает и удаляет первый элемент.  
   ```isolate
   element = array.shift() -- 100
   ```
6. `unshift(...)` — добавляет элементы в начало массива.  
   ```isolate
   array.unshift(0, -100) -- [-100, 0, 100, 200, 300, 400]
   ```
7. `slice(start, finish)` — создает новый массив из указанного диапазона.  
   ```isolate
   new_array = array.slice(1, 3) -- [100, 200, 300]
   ```
8. `remove(index)` — удаляет элемент по индексу, сдвигая остальные.  
   ```isolate
   array.remove(1) -- [100, 300, 400, 500]
   ```
9. `insert(index, value)` — вставляет элемент по индексу.  
   ```isolate
   array.insert(1, 0) -- [100, 0, 200, 300, 400, 500]
   ```
10. `sort(comp)` — возвращает новый отсортированный массив.  
    ```isolate
    new_array = array.sort() -- [100, 200, 300, 400, 500]
    ```

## 7. Таблицы
Хеш-таблицы создаются с помощью фигурных скобок:  
```isolate
table = {
    element1 = 100,
    ["e" + "lement2"] = 200
}
```

- Доступ к элементам: `table["element1"]` или `table.element1` — возвращает `100`.  
- Поддержка оператора `+` для объединения таблиц (создается новая таблица и значения из второй таблицы перезаписывают значения из первой при совпадении ключей). Можно использовать для клонирования таблиц (var = table + {} -- новая копия)

**Пример**:  
```isolate
print(table["element1"]) -- 100
print(table.element2) -- 200
table1 = { a = 1, b = 2 }
table2 = { b = 3, c = 4 }
table3 = table1 + table2
print(table3.a, table3.b, table3.c) -- 1, 3, 4
```

**Методы таблиц**:  
1. `keys()` — возвращает массив всех ключей таблицы.  
   ```isolate
   table = { a = 1, b = 2, c = 3 }
   key_array = table.keys() -- ["a", "b", "c"]
   print(key_array.join(",")) -- a,b,c
   ```
2. `values()` — возвращает массив всех значений таблицы.  
   ```isolate
   value_array = table.values() -- [1, 2, 3]
   print(value_array.join(",")) -- 1,2,3
   ```
3. `has(key)` — проверяет, существует ли ключ в таблице, возвращает `true` или `false`.  
   ```isolate
   print(table.has("a")) -- true
   print(table.has("d")) -- false
   ```
4. `set(key, value)` — устанавливает значение для ключа, возвращает таблицу.  
   ```isolate
   table.set("d", 4)
   print(table.d) -- 4
   ```
5. `remove(key)` — удаляет пару ключ-значение, возвращает таблицу.  
   ```isolate
   table.remove("a")
   print(table.has("a")) -- false
   ```
6. `merge(table2)` — объединяет текущую таблицу с другой, перезаписывая совпадающие ключи, возвращает таблицу.  
   ```isolate
   table.merge({ b = 20, e = 5 })
   print(table.b, table.e) -- 20, 5
   ```
7. `filter(callback)` — создает новую таблицу с парами ключ-значение, для которых callback возвращает `true`. Без callback возвращает копию таблицы.  
   ```isolate
   filtered = table.filter(function(key, value) {
       return value > 1
   })
   print(filtered.b, filtered.c) -- 2, 3
   ```
8. `map(callback)` — создает новую таблицу, применяя callback к каждой паре ключ-значение. Без callback возвращает копию таблицы.  
   ```isolate
   mapped = table.map(function(key, value) {
       return value * 2
   })
   print(mapped.a, mapped.b) -- 2, 4
   ```
9. `size()` — возвращает количество пар ключ-значение.  
   ```isolate
   print(table.size()) -- 3
   ```
10. `clear()` — удаляет все пары ключ-значение, возвращает таблицу.  
    ```isolate
    table.clear()
    print(table.size()) -- 0
    ```
11. `clone()` — возвращает копию таблицы.  
    ```isolate
    copy = table.clone()
    copy.set("a", 10)
    print(table.a, copy.a) -- 1, 10
    ```
12. `foreach(callback)` — выполняет callback для каждой пары ключ-значение, возвращает таблицу.  
    ```isolate
    table.foreach(function(key, value) {
        print(key, value) -- a, 1  b, 2  c, 3
    })
    ```
13. `toarray()` — преобразует таблицу в массив таблиц `{key = key, value = value}`.  
    ```isolate
    array = table.toarray() -- [{key = "a", value = 1}, {key = "b", value = 2}, {key = "c", value = 3}]
    print(array.join(",")) -- {key = "a", value = 1},{key = "b", value = 2},{key = "c", value = 3}
    ```
14. `find(callback)` — возвращает первую пару `{key = key, value = value}`, для которой callback возвращает `true`, или текущую таблицу, если ничего не найдено или callback отсутствует.  
    ```isolate
    result = table.find(function(key, value) {
        return value > 1
    })
    print(result.key, result.value) -- b, 2
    ```

## 8. Условия
```isolate
if (condition) {..body}
if (1 == 1) {
    print("Один равен одному")
}
```

```isolate
if (1 == 1) {
    print("Один равен одному")
} else {
    print("Один не равен одному")
}
```

## 9. Циклы
1. `for(start, test, update) {..body}`  
   ```isolate
   for (i = 1, i < 10, i = i + 1) {
       print(i) -- 1...9
   }
   ```

2. `while (condition) {..body}`  
   ```isolate
   i = 0
   while (i < 10) {
       i = i + 1
       print(i) -- 1...10
   }
   ```

3. `break` — завершает цикл.  
   ```isolate
   for (i = 1, i < 10, i = i + 1) {
       print(i) -- 1
       break
   }
   ```

4. `continue` — пропускает итерацию цикла.  
   ```isolate
   for (i = 1, i < 10, i = i + 1) {
       if (i == 2) {
           continue
       }
       print(i) -- 1, 3...9
   }
   ```

## 10. Функции
Параметры функций локальны и доступны только внутри функции.  

```isolate
function name(...params) {...body}
name = function(...params) {...body}
```

**Пример**:  
```isolate
local sum = function(a, b) {
    return a + b
}
print(sum(2, 6)) -- 8
```

## 11. Модульность
Импорт модулей:  
```isolate
import "path" from var
from "path" import var
```

**Пример**:  
`test.iso`:  
```isolate
test_fun = function(x) {
    return x * 2
}
module = {
    some_value = 42
}
return module
```

`main.iso`:  
```isolate
import "test" from test
from "test" import test_fun
print(test.some_value) -- 42
print(test_fun(5)) -- 10
```

Все загруженные модули кешируются в `loadedpackages`.

## 12. Глобальные функции
- `tostring(value)` — преобразует значение в строку.  
- `error(message, [level])` — вызывает ошибку с указанным сообщением.  
- `pcall(func, ...arg)` — вызывает функцию в защищенном режиме, возвращает `{success, result_or_error}`.  
- `print(arg1, ...arg)` — выводит в консоль.  
- `clock()` — возвращает текущее время в миллисекундах.  
- `time([date])` — возвращает текущее время в секундах.  
- `strlen(text)` — возвращает длину строки.  
- `trim(text)` — удаляет пробелы в начале и конце строки.  
- `ltrim(text)` — удаляет пробелы в начале строки.  
- `rtrim(text)` — удаляет пробелы в конце строки.  
- `strreplace(text, find, replace)` — заменяет все вхождения `find` на `replace`.  
- `strpos(text, find)` — возвращает позицию первого вхождения `find` или `nil`.  
- `strtolower(text)` — преобразует строку в нижний регистр.  
- `min(...)` — возвращает минимальное значение из списка чисел.  
- `max(...)` — возвращает максимальное значение из списка чисел.  
- `next(table, [index])` — возвращает следующую пару ключ-значение в таблице.  
- `jsonencode(table)` — кодирует таблицу или массив в JSON-строку.  
- `jsondecode(string)` — декодирует JSON-строку в таблицу или массив.  
- `base64encode(s)` — возвращает строку в формате base64.  
- `base64decode(s)` — декодирует и возвращает строку из base64 формата.  
- `strformat(format, ...)` — форматирует строку с аргументами.  
- `strtoupper(text)` — преобразует строку в верхний регистр.  
- `strsplit(string, sep)` - разделяет string в массив, разделителем sep. 
- `round(number, [decimals])` — округляет число до целого или указанного количества знаков.  
- `abs(number)` — возвращает абсолютное значение числа.  
- `floor(number)` — возвращает наибольшее целое, меньшее или равное числу.  
- `sqrt(number)` — возвращает квадратный корень числа.  
- `pow(base, exp)` — возводит число base в степень exp.  
- `ceil(number)` — возвращает наименьшее целое, большее или равное числу.  
- `sin(number)` — возвращает синус числа (в радианах).  
- `cos(number)` — возвращает косинус числа (в радианах).  
- `tan(number)` — возвращает тангенс числа (в радианах).  
- `rad(degrees)` — конвертирует градусы в радианы.  
- `deg(radians)` — конвертирует радианы в градусы.  
- `log(number, [base])` — возвращает логарифм числа по основанию base (натуральный, если base не указан).  
- `random([min, max])` — возвращает случайное число. Без аргументов — от 0 до 1; с одним аргументом — целое от 1 до min; с двумя — целое от min до max.  
- `randomseed(seed)` — устанавливает seed для генератора случайных чисел.  
- `foreach(table or array, callback)` — выполняет callback для каждого элемента таблицы или массива.  
- `type(object)` — возвращает тип переменной.  
- `tonumber(value)` — преобразует значение в число.  
- `loadedpackages` — содержит кэшированные модули (значение `nil`).


## 13 Использование
local isolate = require("isolate") -- подключает библиотеку

Фукнции:
- `isolate.run(code, filename)` - Выполняет код языка isolate. filename для отладки.
```lua
isolate.run([[
print("Helo, world")
]])
```

- `isolate.addfunction(name, func, source)` - Добавляет вашу фукнцию в глобальные функции языка. source - описание функции.
```lua
isolate.addfunction("test", function (a, b)
    return a + b
end)
```

- `isolate.createarray(array)` - Создает массив с методами языка isolate.
```lua
isolate.addfunction("test", function (a, b)
    return isolate.createarray({a, b})
end)
```

- `isolate.createtable(table)` - Создает таблицу с методами языка isolate.

- `isolate.createfunction(func, source)` - Создает фукнцию isolate с описанием.

- `isolate.addpackage(name, package, globals)` - Добавляет в кеш модулей ваш модуль чтобы его могли загрузить через import
name - имя модуля
package - таблица с модулем для импорта через import-from
globals - таблица из которой смогут импортировать через from-import
```lua
isolate.addpackage("test2", {
    a = 100
}, {
    test_g = isolate.createfunction(function ()
        return 999
    end, "Возращает 999")
})

isolate.run([[
import "test2" from test2
print(test2) -- {a = 100}

from "test2" import test_g
print(test_g()) -- 999
]])
```

