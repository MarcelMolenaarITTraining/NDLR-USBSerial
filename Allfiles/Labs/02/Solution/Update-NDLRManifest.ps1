# Update Manifest
$Parms = @{
    Path = ".\NDLRTools.psd1"
    ModuleVersion = "0.0.02"
    Author = "Marcel Molenaar"
    CompanyName = "Marcel Molenaar IT Training"
    Copyright = "(c) 2021 Marcel Molenaar IT Training. All rights reserved."
    RootModule = "NDLRTools"
    FunctionsToExport = 'Connect-NDLR','Convert-NDLRDataToJson','Convert-NDLRJsonToData','Disconnect-NDLR','Export-NDLRJson','Import-NDLRJson','Read-NDLRSerialResult','Write-NDLRSerialCommand'
  }
  
  Update-ModuleManifest @Parms

  .\ReImportModule.ps1

  Get-Command -noun NDLR*