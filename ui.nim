import os
import colors
import terminal
import common


proc show_file*(file: string, kind: string = "f"): void =
    var name: string = file.splitPath()[1]
    if kind == "f":
        stdout.write colors.blue2
    elif kind == "d":
        stdout.write colors.blue
    elif kind == "lf":
        stdout.write colors.yellow2
    elif kind == "ld":
        stdout.write colors.yellow
    if os.isHidden(file) or name in [".", ".."]:
        stdout.write colors.grey
    stdout.write kind & " " * (3 - kind.len) & name
    if kind.endswith("d"):
        stdout.write("/")
    echo colors.reset


proc show*(dir: string): void =
    colors.cls()
    echo(colors.black & colors.orangebg & dir & " "*(terminalWidth() - dir.len - 1) & colors.reset)
    show_file(dir & "/.", kind="d")
    show_file(dir & "/..", kind="d")
    var loop: int = 2
    var count: int = 0
    for kind, file in os.walkDir(dir):
        if loop == terminalHeight() - 6:
            count += 1
            continue
        if kind == PathComponent.pcFile:
            show_file(file, kind="f")
        if kind == PathComponent.pcDir:
            show_file(file, kind="d")
        if kind == PathComponent.pcLinkToFile:
            show_file(file, kind="lf")
        if kind == PathComponent.pcLinkToDir:
            show_file(file, kind="ld")
        inc loop
    if count != 0:
        echo("... " & $count & " more")


proc sel_file*(file: string, kind: string = "f"): void =
    var name: string = file.splitPath()[1]
    if kind == "f":
        stdout.write colors.bluebg2
    elif kind == "d":
        stdout.write colors.bluebg
    elif kind == "lf":
        stdout.write colors.yellowbg2
    elif kind == "ld":
        stdout.write colors.yellowbg
    if os.isHidden(file) or name in [".", ".."]:
        stdout.write colors.greybg
    stdout.write kind & " " * (3 - kind.len) & name
    if common.endswith(kind, "d"):
        stdout.write("/")
    stdout.write colors.reset


proc choose*(mode: string = "all"): string =
    var 
        loop: int = 3
        res: string = ""
        ftype: string = "f"
        ok: bool = false
    colors.savepos()
    terminal.hideCursor()
    for kind, file in os.walkDir(os.getCurrentDir()):
        ok = false
        while not ok:
            case kind
                of PathComponent.pcFile:
                    if mode == "dir":
                        ok = true
                        inc loop
                        break
                    ftype = "f"
                of PathComponent.pcDir:
                    if mode == "file":
                        ok = true
                        inc loop
                        break
                    ftype = "d"
                of PathComponent.pcLinkToFile:
                    if mode == "dir":
                        ok = true
                        inc loop
                        break
                    ftype = "lf"
                of PathComponent.pcLinkToDir:
                    if mode == "file":
                        ok = true
                        inc loop
                        break
                    ftype = "ld"
            terminal.setCursorPos(0, loop)
            terminal.eraseLine()
            sel_file(file, ftype)
            var c: char = terminal.getch()
            terminal.setCursorPos(0, loop)
            terminal.eraseLine()
            ui.show_file(file, ftype)
            case c
                of '\t':
                    inc loop
                    ok = true
                    continue
                of '\n', '\r':
                    res = file
                    ok = true
                    break
                of '\b', '\f', '\127', '\46':
                    terminal.showCursor()
                    colors.restorepos()
                    return ""
                else:
                    stdout.write '\a'
                    continue
        if res != "":
            break
    terminal.showCursor()
    colors.restorepos()
    return res
