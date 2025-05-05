[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Text,
    
    [Parameter(Mandatory=$false)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$ListVoices,
    
    [Parameter(Mandatory=$false)]
    [string]$VoiceName,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Male", "Female", "Neutral", "Default")]
    [string]$Gender = "Female",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Child", "Teen", "Adult", "Senior", "Default")]
    [string]$Age = "Adult",
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(-10, 10)]
    [int]$Rate = 0,
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(0, 100)]
    [int]$Volume = 70,
    
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if ($_ -match '\.wav$') { $true }
        else { throw "OutputPath must end with .wav extension" }
    })]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(-10, 10)]
    [int]$Pitch,
    
    [Parameter(Mandatory=$false)]
    [switch]$NoSpeak
)

begin {
    Add-Type -AssemblyName System.Speech -ErrorAction Stop
    $SpeechSynthesizer = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer -ErrorAction Stop
    $global:StopSpeech = $false

    function Get-AvailableVoices {
        try {
            return $SpeechSynthesizer.GetInstalledVoices() | 
                   Select-Object -ExpandProperty VoiceInfo
        }
        catch {
            Write-Error "Failed to get available voices: $_"
            exit 1
        }
    }

    function Set-VoiceParameters {
        try {
            if ($VoiceName) {
                $SpeechSynthesizer.SelectVoice($VoiceName)
            }
            else {
                $genderEnum = [System.Speech.Synthesis.VoiceGender]::$Gender
                $ageEnum = [System.Speech.Synthesis.VoiceAge]::$Age
                $SpeechSynthesizer.SelectVoiceByHints($genderEnum, $ageEnum)
            }

            $SpeechSynthesizer.Rate = $Rate
            $SpeechSynthesizer.Volume = $Volume

            if ($PSBoundParameters.ContainsKey('Pitch')) {
                $SpeechSynthesizer.Pitch = $Pitch
            }
        }
        catch {
            Write-Error "Failed to configure voice parameters: $_"
            exit 1
        }
    }

    function ConvertTo-Speech {
        param([string]$TextToSpeak)

        try {
            if ($OutputPath) {
                $SpeechSynthesizer.SetOutputToWaveFile($OutputPath)
                $SpeechSynthesizer.Speak($TextToSpeak)
                $SpeechSynthesizer.SetOutputToDefaultAudioDevice()
                Write-Verbose "Speech saved to: $OutputPath"
            }

            if (-not $NoSpeak) {
                $SpeechSynthesizer.SpeakAsync($TextToSpeak) | Out-Null
                Write-Host "Speech started. Press 'S' to stop..."
                while ($SpeechSynthesizer.State -eq 'Speaking') {
                    if ([Console]::KeyAvailable) {
                        $key = [Console]::ReadKey($true)
                        if ($key.Key -eq 'S') {
                            $SpeechSynthesizer.SpeakAsyncCancelAll()
                            Write-Host "Speech stopped by user."
                            break
                        }
                    }
                    Start-Sleep -Milliseconds 100
                }
            }
        }
        catch {
            Write-Error "Failed during speech generation: $_"
            exit 1
        }
    }
}

process {
    try {
        if ($ListVoices) {
            Write-Host "Available Voices:" -ForegroundColor Cyan
            Get-AvailableVoices | ForEach-Object {
                Write-Host " - $($_.Name)" -ForegroundColor Yellow
                Write-Host "   Culture: $($_.Culture), Gender: $($_.Gender), Age: $($_.Age)"
            }
            return
        }

        if ($InputFile) {
            $resolvedPath = try {
                Resolve-Path $InputFile -ErrorAction Stop
            } catch {
                Write-Error "Input file not found: $InputFile (Current directory: $(Get-Location))"
                exit 1
            }
            
            if (-not (Test-Path $resolvedPath -PathType Leaf)) {
                Write-Error "Specified path is not a file: $resolvedPath"
                exit 1
            }
            
            $Text = Get-Content $resolvedPath -Raw
        }

        if (-not $Text) {
            Write-Error "Either Text parameter or InputFile must be specified"
            exit 1
        }

        Set-VoiceParameters
        ConvertTo-Speech -TextToSpeak $Text
    }
    finally {
        if ($SpeechSynthesizer) {
            $SpeechSynthesizer.Dispose()
        }
    }
}

end {
    Write-Verbose "Text-to-speech conversion completed"
}