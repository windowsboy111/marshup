iterator countTo*(n: int): int =
    var i = 0
    while i <= n:
        yield i
        inc i


proc `+=`*(str1: var string, str2: string): void =
    str1 = str1 & str2
proc `+=`*(str: var string, chr: char): void =
    str = str & chr


proc `*`*(str: string, count: int): string =
    for i in countTo(count):
        result += str


proc `++`*(num: var int): int {.discardable.} =
    inc num
    return num
proc `++`*(num: var any): any {.discardable.} =
    inc num
    return num


proc startswith*(str: string, keyword: string): bool =
    keyword == str.substr(0, keyword.len - 1)

proc startswith*(str: string, keywords: varargs[string]): bool =
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