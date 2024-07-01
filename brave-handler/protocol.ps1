# Function to check if the script is running with elevated permissions
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Re-launch the script as an administrator if it's not running with elevated permissions
if (-not (Test-Admin)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Get the full path of the current script
$scriptDirectory = (Get-Item -Path $PSCommandPath).Directory.FullName
$invokeScriptPath = "$scriptDirectory\StartBrave.exe"

# Define the protocol handler name
$handlerName = "snazzyneedsbrave"

# Define the registry key path for the custom protocol
$registryKeyPath = "Registry::HKEY_CLASSES_ROOT\$handlerName"

# Prepare the registry values
$protocolValue = "URL:SnazzyNeedsBrave Protocol"
$urlProtocolValue = ""
$commandValue = "`"$invokeScriptPath`" `"%1`""

try {
    # Ensure the registry key exists
    if (-not (Test-Path $registryKeyPath)) {
        # Create the registry key
        New-Item -Path $registryKeyPath -Force
        New-Item -Path "$registryKeyPath\shell" -Force
        New-Item -Path "$registryKeyPath\shell\open" -Force
        New-Item -Path "$registryKeyPath\shell\open\command" -Force
    }

    # Set the default value for the protocol
    Set-ItemProperty -Path $registryKeyPath -Name "(default)" -Value $protocolValue
    Set-ItemProperty -Path $registryKeyPath -Name "URL Protocol" -Value $urlProtocolValue
    Set-ItemProperty -Path "$registryKeyPath\shell\open\command" -Name "(default)" -Value $commandValue

    Write-Host "Registry keys for $handlerName have been set up."
} catch {
    Write-Error "Failed to set registry keys: $_"
}

# Keep the PowerShell window open
Read-Host -Prompt "Press Enter to exit"
