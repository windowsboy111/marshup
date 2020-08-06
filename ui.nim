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
