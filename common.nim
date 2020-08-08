iterator iterCount*(n: int): int =
    ## same as range() in python
    var i = 0
    while i < n:
        yield i
        inc i

iterator iterCount*(start: int, finish: int, step: int = 1): int =
    ## same as range() in python
    var start = start
    while start < finish:
        yield start
        start += step


proc `+=`*(str1: var string, str2: string): void =
    str1 = str1 & str2
proc `+=`*(str: var string, chr: char): void =
    str = str & chr


proc `*`*(str: string, count: int): string =
    if count == 0:
        return
    for i in iterCount(count):
        result += str


proc `++`*(num: var int): int {.discardable.} =
    inc num
    return num
proc `++`*(num: var any): any {.discardable.} =
    inc num
    return num


proc `@`*[T](item: T, iter: openArray[T]): int =
    ## Returns the index of `item` in `iter`  
    ## If `item` is not in `iter`, returns -1.
    var i: int = 0
    for value in iter:
        if value == item:
            return i
        inc i
    return -1
proc `@`*[T](key: T, str: T): int =
    ## Returns the index of `key` in `str`  
    ## If `key` is not in `str`, returns -1
    for i in iterCount(str.len):
        if key == str.substr(i, i + key.len):
            return i
    return -1

template `!@`*[T](item: T, iter: openArray[T]): bool =
    ## Returns `true` if `item` is not in `iter` or else `false`  
    ## Equivalant of: `(item @ iter) == -1`
    `@`(item, iter) == -1
template `!@`*[T](key: T, str: T): bool =
    ## Returns `true` if `key` is not in `str` or else `false`  
    ## Equivalant of: `(key @ str) == -1`
    `@`(key, str) == -1

template `!!@`*[T](item: T, iter: openArray[T]): bool =
    ## Returns `true` if `item` is in `iter` or else `false`  
    ## Equivalant of: `(item @ iter) != -1`
    (item @ iter) != -1
template `!!@`*[T](key: T, str: T): bool =
    ## Returns `true` if `key` is in `str` or else `false`  
    ## Equivalant of: `(key @ str) != -1`
    (key @ str) != -1

proc startswith*(str: string, keyword: string): bool =
    keyword == str.substr(0, keyword.len - 1)

proc startswith*(str: string, keywords: varargs[string]): bool =
    for keyword in keywords:
        if keyword == str.substr(0, keyword.len - 1):
            return true
    return false
proc startswith*(str: string, keywords: openArray[string]): bool =
    for keyword in keywords:
        if keyword == str.substr(0, keyword.len - 1):
            return true
    return false


proc endswith*(str: string, keyword: string): bool =
    var index: int = str.len - keyword.len
    keyword == str.substr(index)

proc endswith*(str: string, keywords: varargs[string]): bool =
    for keyword in keywords:
        if keyword == str.substr(str.len - keyword.len):
            return true
    return false
proc endswith*(str: string, keywords: openArray[string]): bool =
    for keyword in keywords:
        if keyword == str.substr(str.len - keyword.len):
            return true
    return false


proc even*(n: int): bool

proc odd*(n: int): bool =
    assert(n >= 0) # makes sure we don't run into negative recursion
    if n == 0: false
    else:
        n == 1 or even(n-1)

proc even*(n: int): bool =
    assert(n >= 0) # makes sure we don't run into negative recursion
    if n == 1: false
    else:
        n == 0 or odd(n-1)


# strings
proc trim*(str: string): string =
    var str: string = str
    while str.startswith(" "):
        str = str.substr(1)
    while str.endswith(" "):
        str = str.substr(0, str.len - 1)
    return str

if "a" !@ "abc":
    discard