# NDLR port settings
# SerialPort(String, Int32, Parity, Int32, StopBits)
# Parameters
# portName String - The port to use (for example, COM1).
# baudRate Int32 - The baud rate.
# parity Parity - One of the Parity values.
# dataBits Int32 - The data bits value
# stopBits StopBits - One of the StopBits values.

$baudRate = 9600
$parity = [system.io.ports.parity]::None
$dataBits = 8
$stopBits = [system.io.ports.stopbits]::One
$ReadInterval = 500
$connected = $false
$presetNumber = 0;
$presetName = "All"
$presetcommand = "<a>"
$patternCommand = "<b>"
$rhythimCommand = "<c>"
$chordSeqCommand = "<d>"
$monitorLive = $false

$availablePorts = [System.IO.Ports.SerialPort]::getportnames()
$selectedPort = $availablePorts.Count - 1
$portName = $availablePorts[$selectedPort]
foreach ($item in $availablePorts)
{
    if ($item -eq $portName)
    {
        $proceed = $true
        Write-Output ("--> PortName " + $portName + " is available")
        break
    }
}
# --> PortName COM5 is available
if ($proceed -eq $false)
{
    Write-Warning ("--> PortName " + $portName + " not found")
    return
}

$port= new-Object System.IO.Ports.SerialPort $portName,$baudRate,$parity,$dataBits,$stopBits

Start-Sleep -Milliseconds 1000

    
$continue = $true
While ($continue) {
    # Clear screen
    Clear-Host
    
    # Check is still connected to the NDLR
    if ($port.IsOpen) { 
        $connected = $true
    }
    else {
        $connected = $false
        #Clear-Host
    }

    # Draw menu
    Write-Host "##################"
    Write-Host "#                #"
    Write-Host "# NDLR USBSerial #"
    Write-Host "#                #"
    Write-Host "##################"
    Write-Host -nonewline "Connection : " 
    if ($connected) 
    {
        Write-Host -foregroundcolor green "Connected"
    }
    else
    {
        Write-Host -foregroundcolor red "Disconnected"
    }
    Write-Host -nonewline "Portname   : " 
    Write-Host -foregroundcolor Yellow $portName
    Write-Host ""
    Write-Host "a. App Version Info" 
    Write-Host "b. Boot Menu Settings" 
    if ($presetNumber)
    {
        Write-Host -nonewline "c. Read Preset: "
        Write-Host -ForegroundColor Yellow "$presetName"
    }
    else {
        Write-Host -nonewline "c. Read "
        Write-Host -ForegroundColor Yellow "$presetName Presets"
    }
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
    # Write-Host "r." 
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
    Write-Host "1. Change COM Port"
    Write-Host -nonewline "2. Toggle Presets: "
    if ($presetNumber) 
    {
        Write-Host -foregroundcolor green "Single"
    }
    else
    {
        Write-Host -foregroundcolor yellow "All"
    }
    Write-Host -nonewline "3. Monitor Live: "
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
    # Write-Host "4. "
    # Write-Host "5. "
    # Write-Host "6. "
    # Write-Host "7. "
    # Write-Host "8. "
    Write-Host "9. Disconnect"
    Write-Host ""
    Write-Host "X. Exit the menu"
    Write-Host ""

    $choice = Read-Host "Enter your choice"
    $command = $null

    # Menu options
    Switch ($choice) {
        0 {
            # Close connection first
            if ($null -ne $port) 
            { 
                $port.Close() 
                Write-Output ("--> Connection closed.")
                
            }
            
            # (Re)Connect to NDLR
            try
            {
                # Reading from a Serial Port
                # $port= new-Object System.IO.Ports.SerialPort $portName,$baudRate,$parity,$dataBits,$stopBits
                
                Write-Output ("Establishing connection to the port...")
                Start-Sleep -Milliseconds 1000
                $port.Open()
                Write-Output $port
                Write-Output ("--> Connection established.")
                Write-Output ("")
                Start-Sleep -Milliseconds 1000
            }
            catch [System.Exception]
            {
                Write-Error ("Failed to connect : " + $_)
                Start-Sleep -Milliseconds 1000
                $error[0] | Format-List -Force
                if ($null -ne $port) { $port.Close() }
                
                $continue = $false
                exit 1
                
            }
        }
        1{
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
        2{
            # Toggle Presets from <a> to <a#>
            if ($presetNumber -lt 8)
            { 
                $presetNumber++
                $presetName = $presetNumber.ToString()
                $presetcommand = "<a$presetNumber>"
            }
            else 
            { 
                $presetNumber = 0
                $presetName = "All"
                $presetcommand = "<a>"
            }
        }
        3 { if ($monitorLive) { $monitorLive = $false } else { $monitorLive = $true } }
        9{
            if ($null -ne $port) { $port.Close() }
            $connected = $false
 
        }
        a { $command = "a" }
        b { $command = "b" }
        c { $command = $presetcommand }
        d { $command = $patternCommand }
        e { $command = $rhythimCommand }
        f { $command = $chordSeqCommand }
        h { $command = "?" }
        # x { 
        #     $command = ""
        # }
        # x { $command = "" }
        
        'X' { $continue = $false }
        'x' { $continue = $false }
        default { Write-Host "Unknown choice" -ForegroundColor red }
    } # End Switch


    # Read NDLR
    if ($connected)
    {
        if ($null -ne $command)
        { 
            $loop = $true
            do {
                # Run only once
                $loop = $monitorLive

                # Send command to the NDLR
                Write-Host ""
                Write-Output ("Write command $command...")
                $port.WriteLine($command)
            
                # Wait before reading the result
                Start-Sleep -Milliseconds $ReadInterval

                # In monitor mode clear screen in loop
                if ($monitorLive) { Clear-Host }

                # Read result from NDLR
                $data = $port.ReadExisting()
                
                $getTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
                Write-Output ("[" + $getTimestamp + "] " + $data)

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

# Always close connection
if ($null -ne $port) 
{ 
    $port.Close() 
    Write-Output ("--> Connection closed.")
    
}                
