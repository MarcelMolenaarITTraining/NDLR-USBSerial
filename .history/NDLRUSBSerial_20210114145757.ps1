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
$ReadInterval = 1000
$connected = $false
$presetNumber = 0;
$presetName = "All"
$presetcommand = "<a>"
$patternCommand = "<b>"
$rhythimCommand = "<c>"
$chordSeqCommand = "<d>"

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

# Clear screen
Clear-Host
    
$continue = $True
While ($continue) {
    
    # Check is still connected to the NDLR
    if ($port.IsOpen) { 
        $connected = $true
    }
    else {
        $connected = $false
        Clear-Host
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
    Write-Host "a. Read Presets ($presetName)"
    Write-Host "b. Read Patterns"
    Write-Host "c. Read Rhythims"
    Write-Host "d. Read Chord Seq" 
    Write-Host ""
    Write-Host "0. (Re)Connect to NDLR"
    Write-Host "1. Toggle Presets"
    Write-Host "8. Toggle Port"
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
        8{
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
        9{
            if ($null -ne $port) { $port.Close() }
            $connected = $false
 
        }
        a { 
            $command = $presetcommand
        }
        b { 
            $command = $patternCommand
        }
        c { 
            $command = $rhythimCommand
        }
        d { 
            $command = $chordSeqCommand
        }

        'X' { $continue = $false }
        'x' { $continue = $false }
        default { Write-Host "Unknown choice" -ForegroundColor red }
    } # End Switch


    # Read NDLR
    if ($connected)
    {
        if ($null -ne $command)
        { 
            Write-Output ("Write command $command...")
            $port.WriteLine($command)
        
            Start-Sleep -Milliseconds $ReadInterval

            $data = $port.ReadExisting()
            
            $getTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
            Write-Output ("[" + $getTimestamp + "] " + $data)

            Start-Sleep -Milliseconds 1000
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
