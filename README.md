# NDLR-USBSerial

## Serial communication over USB to the NDLR with PowerShell

For those NDLR-ers who want to play around with the [NDLR Librarian](https://github.com/Barilium8/The-NDLR-Librarian) and talk to the NDLR over USB without having to install the [Cool Term](https://github.com/Barilium8/The-NDLR-Librarian/wiki/0) serial terminal program, I have created this [PowerShell script](/blob/main/Allfiles/Labs/01/Solution/NDLRUSBSerial.ps1) to get started. It shows that you don't need install any program to communicate with your [NDLR](https://conductivelabs.com/). 

I also created a [PowerShell mini course](https://marcelmolenaarittraining.github.io/NDLR-USBSerial) to get started. 

On a Windows 10 machine, PowerShell and a Windows USB to Serial driver is already installed. The USB Serial driver is [installed automatically](https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/usb-driver-installation-based-on-compatible-ids).

## PowerShell 

[Writing and Reading info from Serial Ports](https://devblogs.microsoft.com/powershell/writing-and-reading-info-from-serial-ports/) with PowerShell is quite easy. After connecting the NDLR, you need to open the COM port, send a command to the NDLR and read the response.

As far as I know, there is no special Serial Port module to install. However you can use the .Net SerialPost Class and call it directly from PowerShell.

| Class/Enum/Method | Description |
| - | - |
| [SerialPort Class](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.serialport) | Represents a serial port resource |
| [Parity Enum](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.parity) | Specifies the parity bit for a SerialPort object |
| [StopBits Enum](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.stopbits) | Specifies the number of stop bits used on the SerialPort object |
| [ReadExisting](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.serialport.readexisting) | Specifies the number of stop bits used on the SerialPort object |
| [WriteLine](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.serialport.writeline) | Specifies the number of stop bits used on the SerialPort object |

> **Note**: The System.IO.Ports.SerialPort class is also available in [.Net Core](https://www.nuget.org/packages/System.IO.Ports/) so you can also try to run this script on Linux or a Mac.

## Find available COM ports

After connecting you NDLR, you need to retrieve the available COM ports and find out on which port your NDLR is listening. You can use this PowerShell command:

```PowerShell
[System.IO.Ports.SerialPort]::getportnames()
```

## Serial options

```PowerShell
$portName = "COM5"
$baudRate = 9600
$parity = [system.io.ports.parity]::None
$dataBits = 8
$stopBits = [system.io.ports.stopbits]::One
```
> **Note**: Make sure to use the [Parity Enum](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.parity) and [StopBits Enum](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.stopbits) Enums instead of a String.

## Open the Serial Port

```PowerShell
$port= new-Object System.IO.Ports.SerialPort $portName,$baudRate,$parity,$dataBits,$stopBits
$port.Open()
```

If have put that command with some logging to the console in a try catch block

# Write data

```PowerShell
$command = "text"
$port.WriteLine($command)
```

# Read data

```PowerShell
$port.ReadExisting()
```

# Examples

### Presets command - \<a\>

To Read a preset from **all** of The NDLR memory slots. The NDLR has 8 memory slots:

```PowerShell
$command = "<a>"
$port.WriteLine($command)
```

![powershell_command_a](Instructions/Labs/images/powershell_commanda.png)

### Presets command - \<a1\>

To Read a preset from The NDLR memory slot 1:

```PowerShell
$command = "<a1>"
$port.WriteLine($command)
```

PowerShell:

![powershell_command_a1](Instructions/Labs/images/powershell_commanda1.png)

**Happy noodling!**
