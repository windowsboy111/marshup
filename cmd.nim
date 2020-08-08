import common
import os
import colors
import terminal
import ui
import osproc
import strutils
from wrds import nil


proc show_cmd_line(res: string = "", pos: int = 0): void =
    colors.restorepos()
    terminal.setCursorXPos(0)
    stdout.eraseLine()
    stdout.write(colors.red2 & "> " & res)
    colors.left(pos)

proc submit(res: string = ""): void =
    show_cmd_line(res)
    stdout.writeLine ""
    colors.nrmlMode()
    terminal.setCursorXPos(0)

proc exit(): void =
    submit()
    colors.cls()
    colors.noAltScreen()


proc process_command*(cmd: string): string {.discardable.} =
    if not (cmd.split(" ")[0] !@ ["quit", "exit", "bye"]):
        exit()
        return "exit"
    if not (cmd.split(" ")[0] !@ ["cd", "go"]):
        var args = cmd.split(" ")
        ui.show(os.getCurrentDir())
        if args.len < 2:
            var ret = choose(mode="dir")
            if ret == "":
                return "\b"
            os.setCurrentDir(ret)
            ui.show(os.getCurrentDir())
            return ""
        try:
            os.setCurrentDir(args[1])
            ui.show(os.getCurrentDir())
            return ""
        except OSError:
            return colors.red2 & "Cannot set current directory to " & colors.yellow2 & args[1] & colors.red2 & ": \n" & getCurrentExceptionMsg()
        except IndexError:
            var ret = choose(mode="dir")
            if ret == "":
                return "\b"
            os.setCurrentDir(ret)
            ui.show(os.getCurrentDir())
            return ""
    if not (cmd.split(" ")[0] !@ ["ls"]):
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
    if not (cmd.split(" ")[0] !@ ["run", "exec"]):
        try:
            discard osproc.execProcess(cmd.substr(4), os.getCurrentDir())
        except OSError:
            return colors.red2 & "Cannot run " & colors.yellow2 & cmd.substr(4) & colors.red2 & ": \n" & getCurrentExceptionMsg()
        except IndexError:
            var ret = choose(mode="file")
            if ret == "":
                return "\b"
            discard osproc.execProcess(ret, os.getCurrentDir())
        return ""
    if not (cmd.split(" ")[0] !@ ["show"]):
        ui.show(os.getCurrentDir())
        return ""
    if not (cmd.split(" ")[0] !@ ["help"]):
        return "run show ls cd exit"

    return colors.get_fg_color(255, 0, 0) & "cmd not found: " & cmd & colors.reset


proc get_cmd*(): string =
    colors.setchMode()
    var 
        c: char
        res: string = ""
        pos: int = 0
        shift: bool = false
    echo ""
    colors.savepos()
    show_cmd_line()
    while true:
        c = colors.getch()
        case c
        of '\15':  # SI / Shift In
            stdout.write("␏")
            shift = true
        of '\14':  # SO / Shift Out
            stdout.write("␎")
            shift = false
        of '\t', '\f':
            if res.substr(res.len - pos - 1, res.len - pos) != " " and res.len != 0:
                res += " "
            res += choose().splitPath()[1]
            if pos > 0 and res.substr(res.len - pos, res.len - pos + 1) != " ":
                res += " "
            show_cmd_line(res, pos)
            continue
        of '\n', '\r':
            submit(res)
            res = res.trim()
            return res
        of '\127', '\8':  # backspace
            if res.len != pos:
                if pos == 0:
                    res = res.substr(0, res.len() - 2)
                    stdout.write("\b \b")
                    continue
                res = res.substr(0, res.len() - pos - 2) & res.substr(res.len() - pos)
                show_cmd_line(res, pos)
            continue
        of '\46':  # delete
            if res != "" and pos > 0:
                res = res.substr(0, res.len() - pos - 1) & res.substr(res.len() + 1 - pos)
                dec pos
                show_cmd_line(res, pos)
                continue
        # cursor movement: \72 \80 \75 \77
        of '\x1b':  # esc
            stdout.eraseLine()
            stdout.write(wrds.ESC_HINT)
            terminal.hideCursor()
            c = colors.getch()
            terminal.showCursor()
            show_cmd_line(res, pos)
            if c == '[':
                c = colors.getch()
                case c
                of 'D':  # left
                    if res.len > pos:
                        colors.left(1)
                        pos += 1
                of 'C':  # right
                    if pos > 0:
                        colors.right(1)
                        pos -= 1
                of '3':  # delete
                    if colors.getch() == '~' and res != "" and pos > 0:
                        res = res.substr(0, res.len() - pos - 1) & res.substr(res.len() + 1 - pos)
                        dec pos
                        show_cmd_line(res, pos)
                of '7':
                    if colors.getch() == ';':
                        if colors.getch() !!@ ['3', '5']:  # alt end / ctrl end
                            res = ""
                            pos = 0
                            show_cmd_line(res, pos)
                else: discard
                continue
            elif c == '\x1b':
                exit()
                return "exit"
        else:  # write the char to stdout
            colors.restorepos()
            if pos == 0:
                res += c
            elif pos > 0:
                var index: int = res.len - pos
                var 
                    start: string = res.substr(0, index - 1)
                    finish: string = res.substr(index)
                res = start & c & finish
            show_cmd_line(res, pos)
