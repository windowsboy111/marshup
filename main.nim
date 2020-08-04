import os
import colors


proc main(): int =
    echo os.getCurrentDir()
    for kind, file in os.walkDir(os.getCurrentDir()):
        if kind == PathComponent.pcFile:
            stdout.write(colors.blue & "f  ")
        if kind == PathComponent.pcDir:
            stdout.write(colors.blue & "d  " & colors.italic)
        if kind == PathComponent.pcLinkToDir:
            stdout.write(colors.blue & "ld " & colors.bold)
        if kind == PathComponent.pcLinkToFile:
            stdout.write(colors.blue & "lf " & colors.bold)
        if os.isHidden(file):
            stdout.write(colors.grey)
        var path: tuple = file.splitPath()
        echo (path[1] & colors.reset)


if isMainModule:
    discard main()
