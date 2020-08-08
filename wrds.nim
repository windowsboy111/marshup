import colors


var
    ESC_HINT*: string = "␛ " & colors.italic & "ESC key detected. Press once more to exit, or any other key except '" & colors.bold & "[" & colors.reset & colors.italic & "' to return to the prompt." & colors.reset