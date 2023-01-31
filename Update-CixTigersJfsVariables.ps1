<#
.SYNOPSIS
Update JoinFS configuration for 2-4-CIX Tigers

.DESCRIPTION
Sets the JoinFS variables file for all Tiger Moth models. The file "Plane-CixTigerMoth.txt" needs manually putting
into relevant "Documents\JoinFS-xxx\variables" directory first. This script will then map all Tiger Moth models to 
use it.

.PARAMETER FSX
Update the FSX version of JoinFS. Note if neither `FSX` or `MSFS` are specified, it will update both if they exist

.PARAMETER MSFS
Update the MSFS version of JoinFS. Note if neither `FSX` or `MSFS` are specified, it will update both if they exist

.EXAMPLE
Update-CixTigersJfsVariables.ps1

Update the variables file for both FSX and MSFS (depending what exists)

.EXAMPLE
Update-CixTigersJfsVariables.ps1 -FSX

Update the variables file for only FSX

.EXAMPLE
Update-CixTigersJfsVariables.ps1 -MSFS

Update the variables file for only MSFS

.EXAMPLE
Update-CixTigersJfsVariables.ps1 -FSX -MSFS

Update the variables file for both FSX and MSFS
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [switch]$FSX,
    [switch]$MSFS
)

Function UpdateFiles {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][string]$modelsFile,
        [parameter(Mandatory=$true)][string]$variablesFile
    )

    If(-not (Test-Path $modelsFile)) {
        Write-Warning "[$modelsFile] not found - skipping"
        return
    }

    $models = Get-Content $modelsFile | Where-Object{$_ -match "^Tiger Moth*"} | ForEach-Object{$_.split("\|")[0]}
    Write-Verbose "Tiger Moth models found: $($models.length)"
    
    $now = (get-date).toString("yyyyMMdd-HHmmss")
    $data = @()

    If(Test-Path $variablesFile) {
        $backupFile = "$variablesFile.$now.backup"
        Write-Verbose "Backing up [$variablesFile] to [$backupFile]"
        Copy-Item $variablesFile $backupFile
        Write-Verbose "Original line count: $((get-content $variablesFile).length)"
        
        $data += Get-Content $variablesFile | Where-Object { $_ -notmatch "^Tiger Moth" }
        Write-Verbose "Interim line count : $($data.length)"
    } else {
        Write-Verbose "[$variablesFile] does not yet exist - no backup required"
    }

    foreach ($model in $models) {
        $data += "$model[+]SingleProp.txt[+]Plane-CixTigerMoth.txt"
    }

    $data | Set-Content $variablesFile
    Write-Verbose "Final line count   : $((get-content $variablesFile).length)"
    Write-Host "Written: $variablesFile" -ForegroundColor Green
}

If (-not($FSX -or $MSFS)) {
    If(Test-Path $("$env:LOCALAPPDATA\JoinFS-FSX\models - Microsoft Flight Simulator X.txt")) {
        $FSX = $true
    }

    If(Test-Path $("$env:LOCALAPPDATA\JoinFS-FS2020\models - Microsoft Flight Simulator 2020.txt")) {
        $MSFS = $true
    }
}

If($FSX) {
    Write-Verbose "+-----+"
    Write-Verbose "| FSX |"
    Write-Verbose "+-----+"
    UpdateFiles -modelsFile "$env:LOCALAPPDATA\JoinFS-FSX\models - Microsoft Flight Simulator X.txt" -variablesFile "$env:LOCALAPPDATA\JoinFS-FSX\variables.txt"
}

If($MSFS) {
    Write-Verbose "+------+"
    Write-Verbose "| MSFS |"
    Write-Verbose "+------+"
    UpdateFiles -modelsFile "$env:LOCALAPPDATA\JoinFS-FS2020\models - Microsoft Flight Simulator 2020.txt" -variablesFile "$env:LOCALAPPDATA\JoinFS-FS2020\variables.txt"
}