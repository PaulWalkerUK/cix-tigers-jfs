Import-Module ps2exe

Remove-Item "bin" -Recurse
New-Item "bin" -ItemType Directory

$HashArguments = @{
    inputFile = "Update-CixTigersJfsVariables.ps1"
    outputFile = "bin\Update-CixTigersJfsVariables.exe"
    noConsole = $true
    noOutput = $true
    title = "https://github.com/PaulWalkerUK/cix-tigers-jfs"
    product = "CIX-Tigers-JFS"
    version = "2.0.0.0"
}

Invoke-PS2EXE @HashArguments

Copy-Item -Path "Plane-CixTigerMoth.txt" -Destination "bin\"
Copy-Item -Path "README.md" -Destination "bin\"
Copy-Item -Path "README.md" -Destination "bin\README.txt"