# FlowLane Renamer v1.0
# Compatible PowerShell 5.1+

$Script:LogDir = Join-Path $PSScriptRoot "logs"
$Script:WorkingFolder = $null
$Script:PreviewEnabled = $true
if (!(Test-Path $Script:LogDir)) { New-Item -ItemType Directory -Path $Script:LogDir | Out-Null }

function Set-WorkingFolder {

    do {
        $folder = Read-Host "Folder path"

        if (-not (Test-Path $folder)) {
            Write-Host "Folder does not exist." -ForegroundColor Red
            $valid = $false
        }
        else {
            $valid = $true
        }

    } until ($valid)

    $Script:WorkingFolder = (Resolve-Path $folder).Path
	$fileCount = (Get-ChildItem $Script:WorkingFolder -File -ErrorAction SilentlyContinue).Count

    Write-Host ""
    Write-Host "Working folder set to:" -ForegroundColor Green
    Write-Host $Script:WorkingFolder
	Write-Host "Files found    : $fileCount"
	Write-Host ""
}

function Get-TargetFiles {
    param([string]$Folder)
    if (!(Test-Path $Folder)) { throw "Folder not found." }
    $files = Get-ChildItem -Path $Folder -File
    if ($files.Count -eq 0) { throw "No files found." }
    return $files
}

function Preview-Rename {
    param(
        [array]$Mappings
    )
	
	if (-not $Script:PreviewEnabled) {
        return $true
    }

    Write-Host ""
	Write-Host ""
    #Write-Host "==========================" -ForegroundColor Cyan
    Write-Host "===== RENAME PREVIEW  ====" -ForegroundColor Cyan
    #Write-Host "==========================" -ForegroundColor Cyan

    $Mappings |
        Select-Object `
            @{Name="Current Name";Expression={$_.OldName}},
            @{Name="New Name";Expression={$_.NewName}} |
        Format-Table -Wrap -AutoSize |
        Out-Host

    Write-Host ""
    Write-Host ("Files affected : {0}" -f $Mappings.Count)
    Write-Host ""

    do {
        $answer = Read-Host "Apply changes? (Y/N)"
    }
    until ($answer -match '^[YyNn]$')

    return ($answer -match '^[Yy]$')
}

function Test-NameCollisions {
    param($Mappings, [string]$Folder)
    $names = @()
    foreach ($m in $Mappings) {
        if ($names -contains $m.NewName) { return $false }
        $names += $m.NewName
        $target = Join-Path $Folder $m.NewName
        if ((Test-Path $target) -and ($m.OldName -ne $m.NewName)) { return $false }
    }
    return $true
}

function Save-RenameLog {
    param($Mappings, [string]$Folder)
    $log = @{
        Date = Get-Date
        Folder = $Folder
        Changes = $Mappings
    }
    $file = Join-Path $Script:LogDir ("rename_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".json")
    $log | ConvertTo-Json -Depth 5 | Set-Content $file
}

function Invoke-RenameOperation {
    param($Mappings, [string]$Folder)
    foreach ($m in $Mappings) {
        Rename-Item (Join-Path $Folder $m.OldName) -NewName $m.NewName
    }
}

function Undo-LastRename {

    $lastLog = Get-ChildItem $Script:LogDir -Filter *.json |
               Sort-Object LastWriteTime -Descending |
               Select-Object -First 1

    if (-not $lastLog) {
        Write-Host "Nothing to undo."
        return
    }

    $log = Get-Content $lastLog.FullName -Raw | ConvertFrom-Json

    foreach ($change in ($log.Changes | Sort-Object NewName -Descending)) {

        $currentFile = Join-Path $log.Folder $change.NewName

        if (Test-Path $currentFile) {

            Rename-Item `
                -Path $currentFile `
                -NewName $change.OldName
        }
    }

    Remove-Item $lastLog.FullName

    Write-Host "Last operation reverted."
}

function Build-Mapping {
    param($Files, [scriptblock]$Rule)
    $map = @()
    foreach ($f in $Files) {
        $new = & $Rule $f
        $map += [pscustomobject]@{ OldName=$f.Name; NewName=$new }
    }
    return $map
}

Clear-Host
    Write-Host ""
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "    FlowLane Renamer Starter    "
	Write-Host "By KyroTools                    " -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
Set-WorkingFolder
while ($true) {
	$previewStatus = if ($Script:PreviewEnabled) { "ON" } else { "OFF" }
    Write-Host ""
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "    FlowLane Renamer Starter    "
	Write-Host "By KyroTools                    " -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
	Write-Host "Working folder:"
	Write-Host $Script:WorkingFolder -ForegroundColor Yellow
	Write-Host "Preview mode   : $previewStatus" -ForegroundColor Cyan
	Write-Host ""
    Write-Host "1 Add Prefix"
    Write-Host "2 Add Suffix"
    Write-Host "3 Replace Text"
    Write-Host "4 Remove Text"
    Write-Host "5 Auto Number"
    Write-Host "6 Change Case"
    Write-Host "7 Undo Last Rename"
	Write-Host "8 Change Working Folder"
	Write-host "9 Toggle Preview"
	Write-Host "0 Quit"
    $choice = Read-Host "Choice"

    if ($choice -eq "7") { Undo-LastRename; continue }
	if ($choice -eq "8") { Set-WorkingFolder; continue }
	if ($choice -eq "9") {

		$Script:PreviewEnabled = -not $Script:PreviewEnabled

		$status = if ($Script:PreviewEnabled) { "ON" } else { "OFF" }

		Write-Host ""
		Write-Host "Preview mode is now $status" -ForegroundColor Green

		Start-Sleep -Seconds 1

		continue
	}
	
    if ($choice -eq "0") { break }

    #$folder = Read-Host "Folder path"
	$folder = $Script:WorkingFolder
    try { $files = Get-TargetFiles $folder } catch { Write-Host $_; continue }

    switch ($choice) {
        "1" {
            $prefix = Read-Host "Prefix"
            $map = Build-Mapping $files { param($f) $prefix + $f.Name }
        }
        "2" {
            $suffix = Read-Host "Suffix"
            $map = Build-Mapping $files {
                param($f)
                $base=[IO.Path]::GetFileNameWithoutExtension($f.Name)
                $ext=$f.Extension
                "$base$suffix$ext"
            }
        }
        "3" {
            $old=Read-Host "Text to replace"
            $remplacement=Read-Host "Replacement"
            $map = Build-Mapping $files { param($f) ($f.Name -ireplace [regex]::Escape($old),$remplacement) }
        }
        "4" {
            $txt=Read-Host "Text to remove"
            $map = Build-Mapping $files { param($f) ($f.Name -ireplace [regex]::Escape($txt),"") }
        }
        "5" {
            $start=[int](Read-Host "Start number")
            $digits=[int](Read-Host "Digits")
            $i=$start-1
            $map=@()
            foreach($f in $files){
                $i++
                $base=[IO.Path]::GetFileNameWithoutExtension($f.Name)
                $ext=$f.Extension
                $num=$i.ToString().PadLeft($digits,'0')
                $map += [pscustomobject]@{OldName=$f.Name;NewName="${base}_$num$ext"}
            }
        }
        "6" {
            Write-Host "1 UPPER 2 lower 3 Title"
            $c=Read-Host "Mode"
            $map = Build-Mapping $files {
                param($f)
                $base=[IO.Path]::GetFileNameWithoutExtension($f.Name)
                $ext=$f.Extension
                switch($c){
                    "1" {$base=$base.ToUpper()}
                    "2" {$base=$base.ToLower()}
                    "3" {$base=(Get-Culture).TextInfo.ToTitleCase($base.ToLower())}
                }
                "$base$ext"
            }
        }
        default { continue }
    }

    if (!(Test-NameCollisions $map $folder)) {
        Write-Host "Name collision detected."
        continue
    }

    if (Preview-Rename $map) {
        Save-RenameLog $map $folder
        Invoke-RenameOperation $map $folder
        Write-Host "Completed."
    }
}
