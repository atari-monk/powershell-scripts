# PowerShell Speak Text Documentation

## Function
Converts text to speech using System.Speech.Synthesis, with options for voice selection, output control, and audio parameters.

## Parameters

### Input Parameters
- `-Text` [string]: Text to convert to speech (alternative to InputFile)
- `-InputFile` [string]: Path to text file for conversion (alternative to Text)
- `-ListVoices` [switch]: Lists all available voices and exits
- `-VoiceName` [string]: Specific voice to use (bypasses gender/age selection)

### Voice Selection
- `-Gender` [string]: Voice gender (Male/Female/Neutral/Default, default: Female)
- `-Age` [string]: Voice age (Child/Teen/Adult/Senior/Default, default: Adult)

### Audio Parameters
- `-Rate` [int]: Speech rate (-10 to 10, default: 0)
- `-Volume` [int]: Volume level (0-100, default: 70)
- `-Pitch` [int]: Pitch adjustment (-10 to 10, optional)

### Output Control
- `-OutputPath` [string]: Save speech to .wav file (must end with .wav)
- `-NoSpeak` [switch]: Suppresses audio playback (useful when saving to file)

## Usage Examples

1. **Basic text-to-speech**:
   ```powershell
   .\Speak-Text.ps1 -Text "Hello world"
   ```

2. **Read from file with female adult voice**:
   ```powershell
   .\Speak-Text.ps1 -InputFile "input.txt" -Gender Female -Age Adult
   ```

3. **Save to file without playback**:
   ```powershell
   .\Speak-Text.ps1 -Text "Warning message" -OutputPath "alert.wav" -NoSpeak
   ```

4. **List available voices**:
   ```powershell
   .\Speak-Text.ps1 -ListVoices
   ```

5. **Custom voice with audio adjustments**:
   ```powershell
   .\Speak-Text.ps1 -Text "Emergency alert" -VoiceName "Microsoft David" -Rate 3 -Volume 90 -Pitch -2
   ```

## Error Handling
- Validates all parameters before execution
- Provides clear error messages for:
  - Missing required input (Text or InputFile)
  - Invalid file paths
  - Voice selection failures
  - Audio parameter out of range

## Cleanup
Automatically disposes speech synthesizer resources after execution.