proc position*(line: int, column: int): void = 
    ## Move cursor to specified position
    echo("\33[", $line, ";", $column, "f")


proc up*(lines: int): void = 
    ## Move cursor up specified number of lines
    echo("\33[", $lines, "A")


proc down*(lines: int): void = 
    ## Move cursor down specified number of lines
    echo("\33[", $lines, "B")


proc left*(columns: int): void = 
    ## Move cursor left specified number of columns
    echo("\33[", $columns, "C")


proc right*(columns: int): void =
    ## Move cursor right specified number of columns
    echo("\33[", $columns, "D")


proc cls*(): void = 
    ## Clears the screen, and move cursor to 0,0
    echo("\33[2J")


proc eraseline*(): void =
    ## Erase the whole line (till the end of line)
    echo("\33[2J")


proc savepos*(): void =
    ## Save current cursor position
    echo("\33[s")


proc restorepos*(): void =
    ## Restore the saved cursor position
    echo("\33[u")


proc get_fg_color*(r: int, g: int, b: int): string =
    result = "\33[38;2;" & $r & ";" & $g & ";" & $b & "m"

var
    reset*      = "\x1b[0m"
    bold*       = "\x1b[1m"
    italic*     = "\x1b[3m"
    url*        = "\x1b[4m"
    underline*  = "\x1b[4m"
    blink*      = "\x1b[5m"
    blink2*     = "\x1b[6m"
    selected*   = "\x1b[7m"

    black*      = "\x1b[30m"
    red*        = "\x1b[31m"
    green*      = "\x1b[32m"
    yellow*     = "\x1b[33m"
    blue*       = "\x1b[34m"
    violet*     = "\x1b[35m"
    magenta*    = "\x1b[35m"
    cyan*       = "\x1b[36m"
    white*      = "\x1b[37m"

    blackbg*    = "\x1b[40m"
    redbg*      = "\x1b[41m"
    greenbg*    = "\x1b[42m"
    yellowbg*   = "\x1b[43m"
    bluebg*     = "\x1b[44m"
    violetbg*   = "\x1b[45m"
    beigebg*    = "\x1b[46m"
    whitebg*    = "\x1b[47m"

    grey*       = "\x1b[90m"
    red2*       = "\x1b[91m"
    green2*     = "\x1b[92m"
    yellow2*    = "\x1b[93m"
    blue2*      = "\x1b[94m"
    violet2*    = "\x1b[95m"
    beige2*     = "\x1b[96m"
    white2*     = "\x1b[97m"

    greybg*     = "\x1b[100m"
    redbg2*     = "\x1b[101m"
    greenbg2*   = "\x1b[102m"
    yellowbg2*  = "\x1b[103m"
    bluebg2*    = "\x1b[104m"
    violetbg2*  = "\x1b[105m"
    beigebg2*   = "\x1b[106m"
    whitebg2*   = "\x1b[107m"

    orange*     = "\x1b[38;2;255;135;0m"
