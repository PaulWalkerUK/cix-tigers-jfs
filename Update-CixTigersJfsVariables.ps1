<#
.SYNOPSIS
Update JoinFS configuration for 2-4-CIX Tigers

.DESCRIPTION
Sets the JoinFS variables file for all Tiger Moth models, controlled by a simple
GUI.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param()

Function UpdateFiles {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)][string]$modelsFile,
        [parameter(Mandatory=$true)][string]$variablesFile,
        [parameter(Mandatory=$true)][string]$tigerMothvariablesFile
    )

    If(-not (Test-Path $modelsFile -PathType Leaf)) {
        return "[$modelsFile] not found - skipping"
    }

    If(-not (Test-Path $variablesFile -PathType Leaf)) {
        return "[$modelsFile] not found - skipping"
    }

    If(-not (Test-Path (Split-Path -Path $tigerMothvariablesFile) -PathType Container)) {
        return "[$(Split-Path -Path $tigerMothvariablesFile)] not found - skipping"
    }

    $scriptPath = (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Path
    $scriptDir = Split-Path $scriptPath
    Copy-Item -Path (Join-Path -Path $scriptDir -ChildPath "Plane-CixTigerMoth.txt") -Destination $tigerMothvariablesFile

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
    return "$variablesFile"
}

$msfsModelsFile = Join-Path -Path ([environment]::getfolderpath("LocalApplicationData")) -ChildPath "JoinFS-FS2020" | Join-Path -ChildPath "models - Microsoft Flight Simulator 2020.txt"
$msfsVariablesFile = Join-Path -Path ([environment]::getfolderpath("LocalApplicationData")) -ChildPath "JoinFS-FS2020" | Join-Path -ChildPath "variables.txt"
$msfsTigerMothvariablesFile = Join-Path -Path ([environment]::getfolderpath("MyDocuments")) -ChildPath "JoinFS-FS2020" | Join-Path -ChildPath "Variables" | Join-Path -ChildPath "Plane-CixTigerMoth.txt"


$fsxModelsFile = Join-Path -Path ([environment]::getfolderpath("LocalApplicationData")) -ChildPath "JoinFS-FSX" | Join-Path -ChildPath "models - Microsoft Flight Simulator X.txt"
$fsxVariablesFile = Join-Path -Path ([environment]::getfolderpath("LocalApplicationData")) -ChildPath "JoinFS-FSX" | Join-Path -ChildPath "variables.txt"
$fsxTigerMothvariablesFile = Join-Path -Path ([environment]::getfolderpath("MyDocuments")) -ChildPath "JoinFS-FSX" | Join-Path -ChildPath "Variables" | Join-Path -ChildPath "Plane-CixTigerMoth.txt"


#################

Add-Type -AssemblyName System.Windows.Forms

$mainForm = New-Object System.Windows.Forms.Form
$mainForm.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
$mainForm.Width = 350
$mainForm.Height = 200
$mainForm.AutoSize = $true
$mainForm.Text = "CIX Tigers JoinFS Configurator"

#region description
$description = New-Object System.Windows.Forms.Label
$description.Text = @"
This program updates settings in JoinFS so the CIX Tigers
smoke can be sent and received.

Select the appropriate version(s) of JoinFS to update and
press the Update button when ready
"@
$description.Location = New-Object System.Drawing.Point(10, 10)
$description.AutoSize=$true
$mainForm.Controls.Add($description)
#endregion description

#region msfscheckbox
$msfsCheckbox = New-Object System.Windows.Forms.CheckBox
#$msfsCheckbox.Size = New-Object System.Drawing.Size(250,200)
$msfsCheckbox.AutoSize = $true
$msfsCheckbox.Location = New-Object System.Drawing.Point(10, 90)
if(Test-Path $msfsModelsFile) {
    $msfsCheckbox.Text = "Microsoft Flight Simulator (MSFS 2020)"
    $msfsCheckbox.Enabled = $true
} else {
    $msfsCheckbox.Text = "Microsoft Flight Simulator (MSFS 2020)`nThis version of JoinFS not detected"
    $msfsCheckbox.Enabled = $false
}
$mainForm.Controls.Add($msfsCheckbox)
#endregion msfscheckbox

#region fsxcheckbox
$fsxCheckbox = New-Object System.Windows.Forms.CheckBox
#$fsxCheckbox.Size = New-Object System.Drawing.Size(250,50)
$fsxCheckbox.AutoSize = $true
$fsxCheckbox.Location = New-Object System.Drawing.Point(10, 125)


if(Test-Path $fsxModelsFile) {
    $fsxCheckbox.Text = "Flight Simulator X (FSX)"
    $fsxCheckbox.Enabled = $true
} else {
    $fsxCheckbox.Text = "Flight Simulator X (FSX)`nThis version of JoinFS not detected"
    $fsxCheckbox.Enabled = $false
}
$mainForm.Controls.Add($fsxCheckbox)
#endregion fsxcheckbox

#region updatebutton
$updateButton = New-Object System.Windows.Forms.Button
$updateButton.Text = "Update"
$updateButton.Location = New-Object System.Drawing.Point(10, 165)
$updateButton.Add_Click({
    $doneSomat = $false
    $msfsResult = "N/A"
    $fsxResult = "N/A"

    if($msfsCheckbox.Checked) {
        $msfsResult = UpdateFiles -modelsFile $msfsModelsFile -variablesFile $msfsVariablesFile -tigerMothvariablesFile $msfsTigerMothvariablesFile
        $doneSomat = $true
    }

    if($fsxCheckbox.Checked) {
        $fsxResult = UpdateFiles -modelsFile $fsxModelsFile -variablesFile $fsxVariablesFile -tigerMothvariablesFile $fsxTigerMothvariablesFile
        $doneSomat = $true
    }

    if($doneSomat) {
        [System.Windows.Forms.MessageBox]::Show($mainForm, "Complete. The following files have been updated:`n`n[MSFS]: $msfsResult`n`n[FSX]: $fsxResult", "Update", "OK", "Information")
    } else {
        [System.Windows.Forms.MessageBox]::Show($mainForm, "Nothing to do", "Update", "OK", "Warning")
    }
})
$mainForm.Controls.Add($updateButton)
#endregion updatebutton

#region closebutton
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Location = New-Object System.Drawing.Point(100, 165)
$closeButton.Add_Click({$mainForm.Close()})
$mainForm.Controls.Add($closeButton)
#endregion closebutton

$mainForm.ShowDialog()