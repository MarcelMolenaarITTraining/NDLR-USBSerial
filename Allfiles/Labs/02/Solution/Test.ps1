.\ReImportModule.ps1
Set-Location "C:\Users\MarcelMolenaar\OneDrive - Marcel Molenaar\Git\NDLR-USBSerial\Allfiles\Labs\02\Solution\" 
Get-Command -noun NDLR*
Clear-Host


# Test Convert-NDLRDataToJson
$preFile = ".\presets.txt"
$patFile = ".\patterns.txt"
$rhyFile = ".\rhythms.txt"
$choFile = ".\chordseq.txt"

# Get-Content -path $preFile -raw 
# Get-Content -path $patFile -raw 
# Get-Content -path $rhyFile -raw 
# Get-Content -path $choFile -raw 

Get-Content -path $preFile -raw | Convert-NDLRDataToJson
Get-Content -path $patFile -raw | Convert-NDLRDataToJson
Get-Content -path $rhyFile -raw | Convert-NDLRDataToJson
Get-Content -path $choFile -raw | Convert-NDLRDataToJson

$file = "Preset01-20210406_141222901.json"
$wrongFile = "Preset01-20210407_114925939.json"
$outputFolder = "."

# Test Import-NDLRJson
Import-NDLRJson -Path $file

# Test Export-NDLRJson
$jsonfile = Import-NDLRJson -Path $file
Export-NDLRJson -Json $jsonFile -Path $outputFolder -Name "Preset01"

# Wrong input
$jsonfile = Import-NDLRJson -Path $wrongFile
Export-NDLRJson -Json $jsonFile -Path $outputFolder -Name "Preset01"

# Test Convert-NDLRJsonToData

# Option 1
# $jsonfile = Get-Content -path $file -raw
$jsonfile = Import-NDLRJson -Path $file
Convert-NDLRJsonToData -Json $jsonfile

# Option 2
# Get-Content -Path $file -raw | Convert-NDLRJsonToData
Import-NDLRJson -Path $file | Convert-NDLRJsonToData

$ndlrHashtable = @()  # Level 1     Preset Type, Presets
$ndlrPresets = @()    # Level 2     Preset, Slots
$ndlrSlots = @()      # Level 3     Slot, Lines
$ndlrLines = @()      # Level 4     Line, Data

$ndlrLines += [PSCustomObject]@{
    'Line' = "1"
    'Data' = "1,2,3,4,5,6"
}

$ndlrLines += [PSCustomObject]@{
    'Line' = "2"
    'Data' = "5,4,3,2,1"
}

$ndlrSlots += [PSCustomObject]@{
    'Slot' = "1"
    'Lines' = $ndlrLines
}

$ndlrPresets += [PSCustomObject]@{
    'Preset' = "1"
    'Slots' = $ndlrSlots
}

$ndlrHashtable += [PSCustomObject]@{
    'PresetType' = "Pattern"
    'Presets' = $ndlrPresets
}

$ndlrHashtable

$ndlrHashtable | ConvertTo-Json -Depth 5