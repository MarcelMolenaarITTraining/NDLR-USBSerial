function Connect-NDLR {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Serial Port Name (COM5 or COM6)')]
        [string]$PortName
    )
    BEGIN {

    }
    PROCESS {

        if ($global:NDLRConnected -eq "") { $global:NDLRConnected = $false }
        
        if (!$global:NDLRConnected)
        {
            # Serial config
            $baudRate = 9600
            $parity = [system.io.ports.parity]::None
            $dataBits = 8
            $stopBits = [system.io.ports.stopbits]::One

            $availablePorts = [System.IO.Ports.SerialPort]::getportnames()
            $selectedPort = $availablePorts.Count - 1
            if ($PortName -eq "")
            {
                $PortName = $availablePorts[$selectedPort]
                Write-Host "Available port: $PortName"
            }
            Write-Host "Checking port: $PortName"

            foreach ($item in $availablePorts)
            {
                if ($item -eq $PortName)
                {
                    $proceed = $true
                    Write-Host ("--> PortName " + $PortName + " is available")
                    break
                }
            }
            # --> PortName is available
            if ($proceed -eq $false)
            {
                Write-Host -ForegroundColor Red ("--> PortName " + $PortName + " not found")
                exit 1
            }

            try {
                Write-Host "Connecting..."
                $global:NDLRPort= new-Object System.IO.Ports.SerialPort $PortName,$baudRate,$parity,$dataBits,$stopBits
                $global:NDLRport.Open()

                Write-Output ("--> Connection established.")
                Write-Output $global:NDLRport | Format-Table
                Write-Host "Connected!"
            }
            catch [System.Exception]
            {
                Write-Error ("Failed to connect : " + $_)
                Start-Sleep -Milliseconds 1000
                $error[0] | Format-List -Force
                if ($null -ne $global:NDLRPort) { 
                    Write-Host "Disconnecting..."
                    $global:NDLRPort.Close() 
                    Write-Host "Disconnected!"
                }
                exit 1
            }
 
            $global:NDLRConnected = $true
            $global:NDLRPortName = $PortName
        } # if not connected
        else {
            Write-Host "Already connected to port: $global:NDLRPortName"
        }

    } # Process
    END {
        # Delay
        Start-Sleep -Milliseconds 1000
    }
} # function Connect-NDLR

function Disconnect-NDLR {
    [CmdletBinding()]
    param(
    )
    BEGIN {

    }
    PROCESS {
        # Always close connection
        if ($null -ne $global:NDLRPort) 
        { 
            Write-Host ("Disconnecting...")
            $global:NDLRPort.Close() 
            Write-Host ("--> Connection closed.")
        }
        Write-Host ("Disconnected!")
    }
    END {
        $global:NDLRConnected = $false
        $global:NDLRPortName = ""
        $global:NDLRPort = $null

        # Delay
        Start-Sleep -Milliseconds 1000
    }

} # function Disconnect-NDLR

function Write-NDLRSerialCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Serial Command to NDLR')]
        [string]$Command
    )
    BEGIN {

    }
    PROCESS {
        if ($Command -eq "" -or $Command -eq $null)
        {
            Write-Host "No command entered...exiting"
            Exit 1
        }

        if ($global:NDLRconnected -and $global:NDLRPort)
        {
            
            # Send command to the NDLR
            Write-Output ("Write command $command...")
            $global:NDLRport.WriteLine($command)
        }
        else {
            Write-Host -foregroundcolor Red "Not connected to the NDLR, command not sent"
        }

    } # Process
    END {
        # Delay
        Start-Sleep -Milliseconds 1000
    }
} # function Write-NDLRSerialCommand

function Read-NDLRSerialResult {
    [CmdletBinding()]
    param(
    )
    BEGIN {

    }
    PROCESS {
        if ($global:NDLRconnected -and $global:NDLRPort)
        {
            # Read command result from the NDLR
            Write-Host ("Reading result...")
            $data = $global:NDLRport.ReadExisting()
            Write-Output $data
        }
        else {
            Write-Host -foregroundcolor Red "Not connected to the NDLR, command not sent"
        }

    } # Process
    END {
        # Delay
        Start-Sleep -Milliseconds 1000
    }
} # function Read-NDLRSerialResult

function Convert-NDLRDataToJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Serial input data from the NDLR')]
        [string]$Data
    )
    
    # Convert Raw data to PowerShell Object
    $rawLines = $data -split '\r\n'
    Write-Host "Found $($rawLines.Count) lines in data block"

    
    $ndlrHashtable = @()  # Level 1     Preset Type, Presets
    $ndlrPresets = @()    # Level 2     Preset, Slots
    $ndlrSlots = @()      # Level 3     Slot, Lines
    $ndlrLines = @()      # Level 4     Line, Data
    $presetCount = 0     # intial preset nr
    $slotCount = 0        # intial slot nr
    $lineCount = 0        # intial line nr
    
    # Parse raw lines
    $presetNumber = 1  # Create first preset
    foreach ($rawLine in $rawLines)
    {
        if ($rawLine -match "Dump")  
        {
            Write-Host "-----------"
            Write-Host "Memory slot"
            Write-Host "-----------"
            $separator = " ", ":" 
            $dumpParts = $rawLine.Split($separator)
            $presetType = $dumpParts[1]  
            $slotNumber = $dumpParts[2]
            Write-Host "Type: $presetType"
            Write-Host "Memory slot: $slotNumber"

            # $ndlrHashtable.add('Type', $type)
            # $ndlrHashtable.add('Slot', $slot)
            # $ndlrHashtable.add('Lines', @{})
            # $ndlrSlots += [PSCustomObject]@{
            #     'Slot' = $slot
            #     'Lines' = $ndlrLines
            # }
            # $ndlrPresets += [pscustomobject]@{
            #     'Preset' = $presetCount
            #     'Slots' = $ndlrSlots
            # }      
            # $ndlrHashtable += [PSCustomObject]@{
            #     'PresetType' = $type
            #     'Presets' = $ndlrPresets
            # }
            if ($slotNumber -gt $slotCount)
            {
                Write-Host "Add new slot"
                $ndlrSlots += [PSCustomObject]@{
                    'Slot' = $slotNumber
                    'Lines' = @()
                }
                $slotCount = $slotNumber
            } # add slot
            else {
                Write-Host "Update existing slot"
                $ndlrSlots[$slotCount-1] = [PSCustomObject]@{
                    'Slot' = $slotNumber
                    'Lines' = $ndlrLines
                }
            } # update slot
            
        } # match dump 
        elseif ($rawLine -match "#") {
            Write-Verbose "Found data line: $rawLine"
            $lineParts = $rawLine -replace '#' -split ' '
            $lineNumber = $lineParts[0]  
            $lineData = $lineParts[1]
            Write-Host "Line number: $lineNumber"
            Write-Host "Line data: $lineData"
            # $ndlrHashtable.Lines.add('Line', $lineNumber)
            # $ndlrHashtable.Lines.add('Data', $lineData)
            
            if ($lineNumber -gt $lineCount)
            {
                Write-Host "Add new line"
                $ndlrLines += [PSCustomObject]@{
                    Line = $lineNumber
                    Data = $lineData
                }
                $lineCount = $lineNumber
            } # add line
            else {
                Write-Host "Update existing line"
                $ndlrLines[$lineCount-1] = [PSCustomObject]@{
                    Line = $lineNumber
                    Data = $lineData
                }
            } # update line
        } # match line
    
        # Update presets
        if ($presetNumber -gt $presetCount)
        {
            $ndlrPresets += [pscustomobject]@{
                'Preset' = $presetCount
                'Slots' = @()
            }
            $presetCount = $presetNumber
        } # add preset
        else {
            $ndlrPresets[$presetCount-1] = [pscustomobject]@{
                'Preset' = $presetCount
                'Slots' = $ndlrSlots
            }
        } # update preset
    }
    $ndlrHashtable += [PSCustomObject]@{
        'PresetType' = $presetType
        'Presets' = $ndlrPresets
    }    
    # # Count Dump lines
    # $dumps = $rawData -match "Dump"
    # Write-Host "Found $($dumps.Count) memory slots"
    
    # $separator = " ", ":" 
    # foreach ($dump in $dumps) {
    #     $dumpParts = $dump.Split($separator)
    #     $type = $dumpParts[1]  
    #     $slot = $dumpParts[2]
    #     Write-Host "Type: $type"
    #     Write-Host "Memory slot: $slot" 
    # }

    # $separator = "<","><",">"
    # $presetData = $rawData.Split($separator, [System.StringSplitOptions]::RemoveEmptyEntries)
    # $presetNr = $presetData[0] -replace '^Dump *:[\d{2}]*?'
    # $presetHashtable = [ordered]@{
    #     Preset = $presetNr
    #     PreL01 = @($presetData[1] -replace 'PreL\d{02}\-' -split ',')
    #     PreL02 = @($presetData[2] -replace 'PreL\d{02}\-' -split ',')
    #     PreL03 = @($presetData[3] -replace 'PreL\d{02}\-' -split ',')
    #     PreL04 = @($presetData[4] -replace 'PreL\d{02}\-' -split ',')
    #     PreL05 = @($presetData[5] -replace 'PreL\d{02}\-' -split ',')
    #     PreL06 = @($presetData[6] -replace 'PreL\d{02}\-' -split ',')
    #     PreL07 = @($presetData[7] -replace 'PreL\d{02}\-' -split ',')
    #     PreL08 = @($presetData[8] -replace 'PreL\d{02}\-' -split ',')
    #     PreL09 = @($presetData[9] -replace 'PreL\d{02}\-' -split ',')
    #     PreL10 = @($presetData[10] -replace 'PreL\d{02}\-' -split ',')
    # }

    # $presetObject = [pscustomobject]$presetHashtable

    # # Convert data to Json
    # $outputJson = $presetObject | ConvertTo-Json -Depth 2
    # Write-Output $outputJson
    # Write-Host -foregroundcolor Yellow "To Do: NDLR Json format"
    # # return $outputJson
   
    $ndlrObject = [pscustomobject]$ndlrHashtable
    $outputJson = $ndlrObject | ConvertTo-Json -Depth 2

    Write-Output $outputJson
    Write-Host -foregroundcolor Yellow "To Do: NDLR Json format"
    

} # function Convert-NDLRDataToJson

function Convert-NDLRJsonToData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Input from a json file')]
        [string]$json
    )

    $jsonObject = ConvertFrom-Json $json

    if ($null -eq $jsonObject)
    {
        return 0
    }
    Write-Output $jsonObject
    Write-Host -foregroundcolor Yellow "To Do: Convert PS Object to NDLR Data"
    # return $jsonObject

} # function Convert-NDLRJsonToData

function Import-NDLRJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Path to a json file')]
        [string]$Path
    )
    
    $output = Get-Content -path $Path -raw
    
    # Write-Output $output   
    return $output

} # function Import-NDLRJson

function Export-NDLRJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Json data')]
        [string]$Json,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Output folder for json filename')]
        [string]$Path,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Prefix of the json filename')]
        [string]$Name
    )
    
    # Test valid json
    $jsonObject = ConvertFrom-Json $json

    if ($null -eq $jsonObject)
    {
        Write-Error "Invalid Json data"
        return 0
    }

    # Test folder path
    if (!(Test-Path -path $Path))
    {
        Write-Error "Invalid folder"
        return 0
    }
    
    # Write json file
    $fileTimestamp = Get-Date -Format "yyyyMMdd_HHmmssfff"
    $outputFileName = "{0}\{1}-{2}.json" -f $Path, $Name, $fileTimestamp
    
    $json | Out-File -FilePath $outputFileName

    # # Import CSV
    # $importCsv = Import-Csv $csvFile
    # $importCsv
    # Export to Json
    # $jsonFile = "E:\servers.json"
    # $jsonOutPut = $importCsv | ConvertTo-Json
    # $jsonOutPut | Out-File $jsonFile

} # function Export-NDLRJson


# function test-jsondepth {
# [int] $maximumDepth = -1
    # [int] $depth = 0
    # [char[]] $startingBrackets = '[', '{'
    # [char[]] $endingBrackets = @(']', '}')
  
    # foreach ($c in $json.ToCharArray())
    # {
    #   if ($c -in $startingBrackets)
    #   {
    #     ++$depth
    #     $maximumDepth = if ($maximumDepth -ge $depth)
    #       { $maximumDepth } else { $depth }
    #   }
  
    #   elseif ($c -in $endingBrackets)
    #   {
    #     --$depth
    #   }
    # }
    # $result = @()

    # $jsonObject | ForEach-Object {
    #     $str = ($_.PreL01 -join ',')
    #     $result += "<PreL($_.PreL01 -join ',')>"
    # }
    # $PerL01 = ()
    # $presets = @($jsonObject.PresetNumber, $jsonObject.PreL01)
  
    # return $presets
# }