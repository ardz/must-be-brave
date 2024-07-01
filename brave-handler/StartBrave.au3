; AutoIt script to open a URL in Brave browser

; Function to read the Brave path from config.ini
Func ReadBravePathFromConfig()
    ; Get the directory of the current script
    Local $currentDir = @ScriptDir
    Local $configFile = $currentDir & "\bravepath.ini"

    ; Check if the config file exists
    If FileExists($configFile) Then
        ; Read the Brave path from the config file
        Local $bravePath = IniRead($configFile, "Paths", "BravePath", "")
        If $bravePath = "" Then
            MsgBox(0, "Error", "BravePath not found in config.ini")
            Exit
        EndIf
        Return $bravePath
    Else
        MsgBox(0, "Error", "config.ini file not found")
        Exit
    EndIf
EndFunc

; Function to open URL in Brave
Func OpenURLInBrave($url)
    ; Get Brave path from config
    Local $bravePath = ReadBravePathFromConfig()

    ; Check if Brave executable exists
    If FileExists($bravePath) Then
        ; Run Brave with the specified URL
        Run('"' & $bravePath & '" ' & $url, "", @SW_SHOWNORMAL)
    Else
        MsgBox(0, "Error", "Brave browser not found at: " & $bravePath)
    EndIf
EndFunc

; Check if a URL is passed as a command line argument
If $CmdLine[0] > 0 Then
    ; Get the URL from command line argument
    Local $url = $CmdLine[1]
    OpenURLInBrave($url)
Else
    MsgBox(0, "Error", "No URL provided. Please run the script with a URL as an argument.")
EndIf
