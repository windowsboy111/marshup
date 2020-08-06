import os
import colors
import cmd
import ui


proc main(): int =
    setStdIoUnbuffered()
    var target: string = os.getCurrentDir()
    if paramCount() >= 1:
        target = paramStr(1)
    try:
        os.setCurrentDir(target)
    except OSError:
        echo getCurrentExceptionMsg()
        return 2
    colors.toAltScreen()
    ui.show(target)
    while true:
        var ret: string = cmd.process_command(cmd.get_cmd())
        if ret == "exit":
            break
        echo ret


if isMainModule:
    var exitCode: cint = main().int32
    discard os.exitStatusLikeShell(exitCode)