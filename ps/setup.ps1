param (
    [string]$DebugMode = "On"  # Default to debug mode being on
)

# Generate a unique handler name
$guid = [guid]::NewGuid().ToString()
$fullHandlerName = "mustbebrave-$guid"

# Function to find Brave Browser
function Find-BravePath {
    $paths = @(
        "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
        "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\brave.exe",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $null
}

$bravePath = Find-BravePath

if (-not $bravePath) {
    Write-Error "Brave browser not found. Please install Brave or provide the path manually."
    exit
}

# Get the base directory
$baseDir = (Get-Location).Path

# Define paths based on the provided structure
$logDir = "$baseDir\registry\logs"
$psDir = "$baseDir\ps"
$ps1Path = "$psDir\MustBeBrave.ps1"
$regPath = "$baseDir\registry\mustbebrave-protocol.reg"
$configPath = "$baseDir\registry\config.json"

# Ensure the log directory exists
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir
}

# Ensure the ps directory exists
if (-not (Test-Path -Path $psDir)) {
    New-Item -ItemType Directory -Path $psDir
}

# Create the PowerShell script
$ps1Content = @"
param (
    [string]`$url
)

`$encodedUrl = `$url -replace '^${fullHandlerName}:', ''
`$decodedUrl = [System.Uri]::UnescapeDataString(`$encodedUrl)

`$logDir = '${logDir}'
if (-not (Test-Path -Path `$logDir)) {
    New-Item -ItemType Directory -Path `$logDir
}

`$logFile = "$logDir\must-be-brave.log"
Add-Content `$logFile ("Encoded URL: " + `$encodedUrl)
Add-Content `$logFile ("Decoded URL: " + `$decodedUrl)
Add-Content `$logFile ("Starting Brave with URL: " + `$decodedUrl)

try {
    Start-Process '${bravePath}' `$decodedUrl
} catch {
    Add-Content `$logFile ("Error: " + `$_.Exception.Message)
    Write-Error `$_.Exception.Message
}
"@

Set-Content -Path $ps1Path -Value $ps1Content

# Create the registry file
$regContent = @"
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\${fullHandlerName}]
@="URL:${fullHandlerName} Protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\${fullHandlerName}\shell]

[HKEY_CLASSES_ROOT\${fullHandlerName}\shell\open]

[HKEY_CLASSES_ROOT\${fullHandlerName}\shell\open\command]
@="powershell -ExecutionPolicy Bypass -File `"$ps1Path`" `%1"
"@

Set-Content -Path $regPath -Value $regContent

# Create the config file for the add-on
$configContent = @{
    customHandlerName = $fullHandlerName
    logDirLocation = $logDir
    regFileLocation = $regPath
    ps1Location = $ps1Path
}

$configContent | ConvertTo-Json -Depth 3 | Set-Content -Path $configPath

Write-Host "Setup complete. Files created in $baseDir\registry"

if ($DebugMode -eq "Off") {
    Write-Host "Writing to registry..."
    # Apply the registry file to register the custom protocol
    Start-Process regedit.exe -ArgumentList "/s $regPath" -Verb RunAs
} else {
    Write-Host "Debug mode is on. Skipping registry write."
}
