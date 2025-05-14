$config = @{
    ScriptsPath = "C:\atari-monk\code\powershell-scripts"
    ContentPath = "C:\atari-monk\code\dev-blog\content\react\product_form"
    TTS_Params = @{
        Gender = "Female"
        Age    = "Adult"
        Rate   = 0
        Volume = 100
        Pitch  = 0
        NoSpeak = $true
    }
    FilesToProcess = @("product-table", "search-bar")
    OneDriveFolder = "C:\Users\ASUS\OneDrive\atari-monk\audio"
}

$paths = @{
    CleanMarkdown = "$($config.ScriptsPath)\Clean-Markdown.ps1"
    SpeakText = "$($config.ScriptsPath)\Speak-Text.ps1"
    TempFolder = "$($config.ContentPath)\temp"
}

function Initialize-Environment {
    if (-not (Test-Path $paths.TempFolder)) {
        New-Item -ItemType Directory -Path $paths.TempFolder -Force | Out-Null
    }
    if (-not (Test-Path $config.OneDriveFolder)) {
        New-Item -ItemType Directory -Path $config.OneDriveFolder -Force | Out-Null
    }
}

function Process-Markdown {
    param ([string]$InputFile, [string]$OutputFile)
    
    try {
        & $paths.CleanMarkdown -InputFile $InputFile -OutputFile $OutputFile
        Write-Host "  ✔ Cleaned: $([System.IO.Path]::GetFileName($InputFile))" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ✘ Failed to clean: $([System.IO.Path]::GetFileName($InputFile))" -ForegroundColor Red
        return $false
    }
}

function Convert-ToAudio {
    param ([string]$InputFile, [string]$OutputFile)
    
    try {
        $params = $config.TTS_Params.Clone()
        $params.InputFile = $InputFile
        $params.OutputPath = $OutputFile
        
        & $paths.SpeakText @params
        Write-Host "  ✔ Generated WAV: $([System.IO.Path]::GetFileName($OutputFile))" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ✘ Failed to generate audio" -ForegroundColor Red
        return $false
    }
}

function Convert-ToMP3 {
    param ([string]$InputFile)
    
    try {
        $outputFile = [System.IO.Path]::ChangeExtension($InputFile, ".mp3")
        ffmpeg -i $InputFile -codec:a libmp3lame -qscale:a 2 $outputFile -hide_banner -loglevel error
        Write-Host "  ✔ Converted to MP3: $([System.IO.Path]::GetFileName($outputFile))" -ForegroundColor Green
        return $outputFile
    }
    catch {
        Write-Host "  ✘ Failed to convert to MP3" -ForegroundColor Red
        return $null
    }
}

function Cleanup-TempFiles {
    try {
        Remove-Item -Path $paths.TempFolder -Recurse -Force
        return $true
    }
    catch {
        return $false
    }
}

function Move-MP3Files {
    param ([string]$SourcePath, [string]$DestinationPath)
    
    try {
        Get-ChildItem -Path $SourcePath -Filter *.mp3 | ForEach-Object {
            Move-Item -Path $_.FullName -Destination $DestinationPath -Force
        }
        return $true
    }
    catch {
        return $false
    }
}

Write-Host "`nMARKDOWN TO AUDIO CONVERSION" -ForegroundColor Cyan
Write-Host ("─" * 50) -ForegroundColor DarkCyan
Write-Host "Processing files from: $([System.IO.Path]::GetFileName($config.ContentPath))`n" -ForegroundColor Gray

Initialize-Environment

foreach ($file in $config.FilesToProcess) {
    $inputFile = "$($config.ContentPath)\$file.md"
    $textOutput = "$($paths.TempFolder)\$file.txt"
    $audioOutput = "$($paths.TempFolder)\$file.wav"
    
    Write-Host "PROCESSING: $file" -ForegroundColor Yellow
    
    if (Test-Path $inputFile) {
        if (Process-Markdown -InputFile $inputFile -OutputFile $textOutput) {
            if (Convert-ToAudio -InputFile $textOutput -OutputFile $audioOutput) {
                $null = Convert-ToMP3 -InputFile $audioOutput
            }
        }
    } else {
        Write-Host "  File not found: $([System.IO.Path]::GetFileName($inputFile))" -ForegroundColor Yellow
    }
    Write-Host ""
}

$null = Move-MP3Files -SourcePath $paths.TempFolder -DestinationPath $config.OneDriveFolder
$null = Cleanup-TempFiles

Write-Host ("─" * 50) -ForegroundColor DarkCyan
Write-Host "✔ Conversion completed successfully" -ForegroundColor Green
Write-Host "MP3 files saved to: $($config.OneDriveFolder)" -ForegroundColor White
Write-Host ""