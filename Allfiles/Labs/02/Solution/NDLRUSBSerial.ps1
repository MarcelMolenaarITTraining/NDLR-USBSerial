# NDLR port settings
# SerialPort(String, Int32, Parity, Int32, StopBits)
# Parameters
# portName String - The port to use (for example, COM1).
# baudRate Int32 - The baud rate.
# parity Parity - One of the Parity values.
# dataBits Int32 - The data bits value
# stopBits StopBits - One of the StopBits values.

$ReadInterval = 500
$presetNumber = 0;
$presetName = "All"
# $presetcommand = "<a>"
# $patternCommand = "<b>"
# $rhythimCommand = "<c>"
# $chordSeqCommand = "<d>"
$monitorLive = $false
$outputFolder =  Get-Location
$portName = "COM6" # Default COM6
    
$continue = $true
While ($continue) {
    # Clear screen
    Clear-Host
  
    # Draw menu
    Write-Host "##################"
    Write-Host "#                #"
    Write-Host "# NDLR USBSerial #"
    Write-Host "#                #"
    Write-Host "##################"
    Write-Host -nonewline "Connection NDLR: " 
    if ($global:NDLRconnected) 
    {
        Write-Host -foregroundcolor green "Connected"
    }
    else
    {
        Write-Host -foregroundcolor red "Disconnected"
    }
    Write-Host -nonewline "Connected Port : " 
    Write-Host -foregroundcolor Yellow $global:NDLRPortName
    Write-Host ""
    Write-Host "a. App Version Info" 
    Write-Host "b. Boot Menu Settings" 
    # if ($presetNumber)
    # {
    #     Write-Host -nonewline "c. Read Preset: "
    #     Write-Host -ForegroundColor Yellow "$presetName"
    # }
    # else {
    #     Write-Host -nonewline "c. Read "
    #     Write-Host -ForegroundColor Yellow "$presetName Presets"
    # }
    Write-Host "c. Read Presets"
    Write-Host "d. Read Patterns"
    Write-Host "e. Read Rhythims"
    Write-Host "f. Read Chord Seq" 
    Write-Host "h. Show help menu" 
    # Write-Host "i." 
    # Write-Host "j." 
    # Write-Host "k." 
    # Write-Host "l." 
    # Write-Host "m." 
    # Write-Host "n." 
    # Write-Host "o." 
    # Write-Host "p." 
    Write-Host "r. (Re)import NDLR PowerShell Module" 
    # Write-Host "s." 
    # Write-Host "t." 
    # Write-Host "u." 
    # Write-Host "v." 
    # Write-Host "w." 
    # Write-Host "x." 
    # Write-Host "y." 
    # Write-Host "z." 
    Write-Host ""
    Write-Host "0. (Re)Connect to NDLR"
    Write-Host -nonewline "1. Change COM Port "
    if ($portName) 
    {
        Write-Host -foregroundcolor green $portName
    }
    else
    {
        Write-Host -foregroundcolor yellow "-"
    }
    # Write-Host -nonewline "2. Toggle Presets: "
    # if ($presetNumber) 
    # {
    #     Write-Host -foregroundcolor green "$presetNumber (Single)"
    # }
    # else
    # {
    #     Write-Host -foregroundcolor yellow "All"
    # }
    # Write-Host "3. "
    # Write-Host "4. "
    # Write-Host "5. "
    # Write-Host "6. "
    # Write-Host "7. "
    Write-Host -nonewline "8. Monitor Live: "
    if ($presetNumber)
    {
        if ($monitorLive) 
        {
            Write-Host -foregroundcolor Green "On"
        }
        else
        {
            Write-Host -foregroundcolor Yellow "Off"
        }
    }
    else {
        Write-Host -foregroundcolor Magenta "Disabled"
    }
    Write-Host "9. Disconnect"
    Write-Host ""
    Write-Host "X. Exit the menu"
    Write-Host ""

    $choice = Read-Host "Enter your choice"
    $command = $null

    # Menu options
    Switch ($choice) {
        0 {
            # Make a connection to the NDLR
            Connect-NDLR -PortName $portName
            $portName = $global:NDLRPortName
        }
        1{
            # Disconnect first
            if ($global:NDLRconnected)
            {
                # Disconnect connection to the NDLR
                Disconnect-NDLR
            }

            # Toggle COM Ports
            $availablePorts = [System.IO.Ports.SerialPort]::getportnames()
            if ($selectedPort -lt ($availablePorts.Count - 1))
            { 
                $selectedPort++
            }
            else 
            { 
                $selectedPort = 0
            }
            $portName = $availablePorts[$selectedPort]
        }
        # 2{
        #     # Toggle Presets from <a> to <a#>
        #     if ($presetNumber -lt 8)
        #     { 
        #         $presetNumber++
        #         $presetName = $presetNumber.ToString()
        #         $presetcommand = "<a$presetNumber>"
        #     }
        #     else 
        #     { 
        #         $presetNumber = 0
        #         $presetName = "All"
        #         $presetcommand = "<a>"
        #     }
        # }
        8 { if ($monitorLive) { $monitorLive = $false } else { $monitorLive = $true } }
        9{
            # Disconnect connection with NDLR
            Disconnect-NDLR
        }
        a { $command = "a" }
        b { $command = "b" }
        c { $command = "c" }
        d { $command = "d" }
        e { $command = "e" }
        f { $command = "f" }
        h { $command = "?" }
        r { 
            Remove-Module NDLRTools
            Import-Module .\NDLRTools

            # Delay
            Start-Sleep -Milliseconds 1000
        }
        # x { 
        #     $command = ""
        # }
        # x { $command = "" }
        
        'X' { $continue = $false }
        'x' { $continue = $false }
        default { Write-Host "Unknown choice" -ForegroundColor red }
    } # End Switch


    # Read NDLR
    if ($global:NDLRconnected -and $global:NDLRPort)
    {
        if ($null -ne $command)
        { 
            $loop = $true
            do {
                # Run only once
                $loop = $monitorLive

                # Send command to the NDLR
                # Write-Host ""
                # Write-Output ("Write command $command...")
                # $global:NDLRport.WriteLine($command)
            
                # # Wait before reading the result
                # Start-Sleep -Milliseconds $ReadInterval
                Write-NDLRSerialCommand -Command $command

                # In monitor mode clear screen in loop
                if ($monitorLive) { Clear-Host }

                # $data = $global:NDLRport.ReadExisting()
                $data = Read-NDLRSerialResult
                
                $presetJson = Convert-NDLRDataToJson -Data $data
                # # Convert Raw data to PowerShell Object
                # $rawData = $data -replace '\r\n'
                # $separator = "<","><",">"
                # $presetData = $rawData.Split($separator, [System.StringSplitOptions]::RemoveEmptyEntries)
                # $presetNr = $presetData[0] -replace '^Dump RAW Preset:[\d{2}]*?'
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

                # $ndlr = @{
                #     'Presets' = @{
                #         'Lines' = @{
                #             'Name' = 'PreL01'
                #             'Params' = @{
                #                 50,0,4,1,0,0,0,63,26,1,5,0,0,0,0,1,3,7,0,0
                #             }
                #         }
                #         @{
                #             'Name' = 'PreL02'
                #             'Params' = @{
                #                 50,0,4,1,0,0,0,63,26,1,5,0,0,0,0,1,3,7,0,0
                #             }
                #         }
                        
                        
                #     }
                #     'Patterns' = @{

                #     }
                #     'Rhythms' = @{

                #     }
                #     'ChordSeq' = @{

                #     }
                # }
                # $ndlrObject = New-Object -TypeName PSObject -Property $ndlr

                # foreach ($memorySlot in $memorySlots)
                # {
                #     foreach ($layer in $layers)
                #     {
                #         foreach ($param in $params)
                #         {
                #         }
                #         $name = "PreL{0:00}" -f $layer.
                #         @$properties = @{
                #             'Name' = "PreL"
                #         }
                #         $output = New-Object -TypeName PSObject -Property $params
                #     }
                # }
                # $params = @()
                # for (1..10)
                # {   
                #    $name = "PreL($_)"
                # #    $value = @($presetData[$_] -replace 'PreL\d{02}\-' -split ',')
                #     $value = @(0,1,2,3,4,5,6,7,8,9)
                #    $params.add($name, $value) 
                # }
                # {'Name'="Param1";
                # 'OSVersion'   = $os.caption;
                # 'SPVersion'   = $os.servicepackmajorversion;
                # 'BIOSSerial'  = $bios.serialnumber;
                # 'Manufacturer'= $compsys.manufacturer;
                # 'Model'       = $compsys.model}

                # $presetObject = [pscustomobject]$presetHashtable

                # Convert data to Json
                # $presetJson = $presetObject | ConvertTo-Json -Depth 2
                
                $getTimestamp = Get-Date -Format "yyyy-MM-dd_HH:mm:ss:fff"
                Write-Output ("[" + $getTimestamp + "]`n" + $data)
                
                # $fileTimestamp = Get-Date -Format "yyyyMMdd_HHmmssfff"
                # $presetFileName = "c:\temp\Preset{0:00}-{1}.json" -f [int]$presetNr, $fileTimestamp
                # $presetJson | Out-File $presetFileName
                
                $presetFileName = "Preset{0:00}" -f [int]$presetNr
                Export-NDLRJson -Json $presetJson -Path $outputFolder -Name $presetFileName


                if ($monitorLive) { 
                    Write-Host "Press any key to stop..."
                    if ([console]::KeyAvailable -and [console]::ReadKey())
                    {
                        Write-Host ""
                        Write-Host -foregroundcolor Yellow "Exiting now...."
                        break;
                    }
                }
            } while ($loop)

            Write-Host "Press any key to continue..."
            [Console]::ReadKey("NoEcho,IncludeKeyDown")
        }
    }
    else {
        if ($command)
        {
            Write-Host "No connected, connect first to the NDLR..." -ForegroundColor Magenta
            Write-Host ""
            Start-Sleep -Milliseconds 1000
        }
    }
}

# Disconnect connection to the NDLR
Disconnect-NDLR               
