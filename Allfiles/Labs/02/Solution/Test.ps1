.\ReImportModule.ps1
Set-Location "C:\Users\MarcelMolenaar\OneDrive - Marcel Molenaar\Git\NDLR-USBSerial\Allfiles\Labs\02\Solution\" 
Get-Command -noun NDLR*
Clear-Host

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

# Test Convert-NDLRDataToJson


