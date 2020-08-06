import common
import os
import colors
import terminal
import ui
import osproc


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
                of '\b', '\f', '\127':
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


proc process_command*(cmd: string): string {.discardable.} =
    if cmd.startswith("quit", "exit", "bye"):
        colors.cls()
        colors.noAltScreen()
        return "exit"
    if cmd.startswith("cd", "go"):
        var args = cmd.substr(3)
        ui.show(os.getCurrentDir())
        if cmd in ["cd", "cd ", "go", "go "]:
            var ret = choose(mode="dir")
            if ret == "":
                return "\b"
            os.setCurrentDir(ret)
            ui.show(os.getCurrentDir())
            return ""
        try:
            os.setCurrentDir(args)
            ui.show(os.getCurrentDir())
            return ""
        except OSError:
            return colors.red2 & "Cannot set current directory to " & colors.yellow2 & args & colors.red2 & ": \n" & getCurrentExceptionMsg()
        except IndexError:
            var ret = choose(mode="dir")
            if ret == "":
                return "\b"
            os.setCurrentDir(ret)
            ui.show(os.getCurrentDir())
            return ""
    if cmd.startswith("ls"):
        colors.cls()
        var row: int = 1
        for kind, file in os.walkDir(os.getCurrentDir(), relative=true):
            if (file.len + 1 + row) > terminalWidth():
                if file.len < terminalWidth():
                    row = 1
                    result += "\n"
            row += file.len + 1
            if kind == os.PathComponent.pcFile:
                result += colors.blue2
            if kind == os.PathComponent.pcDir:
                result += colors.blue
            if kind == os.PathComponent.pcLinkToFile:
                result += colors.yellow2
            if kind == os.PathComponent.pcLinkToDir:
                result += colors.yellow
            if os.isHidden(file):
                result += colors.grey
            result += file & " "
        result += colors.reset & "\n"
        return "\n" & result
    if cmd.startswith("run"):
        try:
            discard osproc.execProcess(cmd.substr(4), os.getCurrentDir())
        except OSError:
            return colors.red2 & "Cannot run " & colors.yellow2 & cmd.substr(4) & colors.red2 & ": \n" & getCurrentExceptionMsg()
        except IndexError:
            var ret = choose(mode="file")
            if ret == "":
                return "\b"
            discard osproc.execProcess(cmd.substr(4), os.getCurrentDir())
        return ""
    if cmd.startswith("show"):
        ui.show(os.getCurrentDir())
        return ""
    if cmd.startswith("help"):
        return "run show ls cd exit"

    return colors.get_fg_color(255, 0, 0) & "cmd not found: " & cmd & colors.reset


proc get_cmd*(): string =
    var 
        c: char
        res: string = ""
        pos: int = 0
    echo ""
    colors.savepos()
    stdout.write("> ")
    while true:
        c = terminal.getch()
        case c
        of '\t', '\f':
            if res.substr(res.len - pos - 1, res.len - pos) != " " and res.len != 0:
                res += " "
            res += choose()
            if pos > 0 and res.substr(res.len - pos, res.len - pos + 1) != " ":
                res += " "
            colors.restorepos()
            terminal.eraseLine()
            stdout.write("> " & res)
            continue
        of '\n', '\r':
            echo ""
            return res
        of '\127':  # backspace
            if res.len != pos:
                res = res.substr(1, res.len - 1)
                stdout.write("\b \b")
            else:
                res = res.substr(0, res.len - 1 - pos) & res.substr(res.len - pos)
            continue
        of '\8':  # delete
            if res != "" and pos > 0:
                res = res.substr(0, res.len - pos) & res.substr(res.len - pos + 1)
                dec pos
                terminal.eraseLine()
                stdout.write("> " & res)
                continue
        of '\x1b':
            c = terminal.getch()
            if c == '[':
                c = terminal.getch()
                case c
                    of 'D':  # left
                        if res.len != pos:
                            colors.left(1)
                            pos += 1
                        continue
                    of 'C':  # right
                        if pos > 0:
                            colors.right(1)
                            pos -= 1
                        continue
                    else: stdout.write c
                continue
            else:
                stdout.write c
        else:  # write the char to stdout
            colors.restorepos()
            if pos == 0:
                terminal.eraseLine()
                terminal.setCursorXPos(0)
                res += c
                stdout.write("> " & res)
            elif pos > 0:
                var index: int = res.len - pos
                var 
                    start: string = res.substr(0, index)
                    finish: string = res.substr(index)
                res = start & c & finish
                terminal.eraseLine()
                terminal.setCursorXPos(0)
                stdout.write("> " & res)
