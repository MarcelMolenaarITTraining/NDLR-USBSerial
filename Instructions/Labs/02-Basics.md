---
lab:
    title: 'Lab: Basic Communication with the NDLR'
    module: 'Module 02: Communication'
---

# Lab Environment Setup
# Student lab answer key

## Lab scenario

### PowerShell and Serial Ports 
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

## Objectives

After you complete this lab, you will be able to:

- Communicate with the NDLR over Serial by PowerShell

## Lab Setup

  - **Estimated Time**: 30 minutes

## Instructions

### Before you start

#### Sign in to the lab virtual machine
Sign in to your Windows 10 virtual machine (VM) by using the following credentials:

- Username: **Admin**
- Password: **Pa55w.rd**

> **Note**: On a Windows 10 machine, PowerShell and a Windows USB to Serial driver is already installed. The USB Serial driver is [installed automatically](https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/usb-driver-installation-based-on-compatible-ids). 

#### Review the installed applications

Find the taskbar on your Windows 10 desktop. The taskbar contains the icons for the applications that you'll use in this lab:

- Microsoft Edge
- File Explorer
- Windows Terminal
- Visual Studio Code
- [Cool Term](https://github.com/Barilium8/The-NDLR-Librarian/wiki/0)


### Exercise 1: Read and write data using Cool Term 

#### Task 1: Connect
1. On the taskbar, select the **Cool Term** icon.

1. In Cool Term press **Connect**
![CoolTerm_Connect](images/coolterm_connect.png)

1. When the NDLR is connected, select **options**
![CoolTerm_Connected](images/coolterm_connected.png)

1. Make note of the **Serial Port Options**
![CoolTerm_Options](images/coolterm_options.png)

1. Open Notepad and write down:

    1. portName: *COM[yourportnumber]*
    1. baudRate: 9600
    1. parity: None
    1. dataBits: 8
    1. stopBits: 1

#### Task 2: Write data
1. Enter the following command in the main window, and then select Enter to send data to the NDLR:
    ```
    <a>
    ```

    ![coolterm_command_a1](images/coolterm_commanda.png)
    > **Note**: You don't see any text while typing

1. Enter the following command in the main window, and then select Enter to send data to the NDLR:
    ```
    <a1>
    ```

    ![coolterm_command_a1](images/coolterm_commanda1.png)
    > **Note**: You don't see any text while typing

#### Task 3: Read data

#### Task 4: Disconnect

1. Select **disconnect** to disconnect the connection with the NDLR.

### Exercise 2: Read and write data using PowerShell 

After connecting you NDLR, you need to retrieve the available COM ports and find out on which port your NDLR is listening. On my machine it returns COM 5:

![GetPortNames](images/getportnames.png)


#### Task 1: Open the Serial Port

1. On the taskbar, select the **Windows Terminal** icon.
1. Enter the following command, and then select Enter to retrieve the available COM ports and find out on which port your NDLR is listening:

    ```
    [System.IO.Ports.SerialPort]::getportnames()
    ```
    
1. Enter the following command, and then select enter to specify the variables to use in the next PowerShell commands:

    ```
    $portName = "COM5"
    $baudRate = 9600
    $parity = [system.io.ports.parity]::None
    $dataBits = 8
    $stopBits = [system.io.ports.stopbits]::One
    ```
    > **Note**: Make sure to change the name of the $portname if the Port Name is other the COM5.
    
1. Enter the following command, and then select Enter to create a Serial connection:
    ```
    $port= new-Object System.IO.Ports.SerialPort $portName,$baudRate,$parity,$dataBits,$stopBits
    ```
    
1. Enter the following command, and then select Enter to open the Serial Port:
  
    ```
    $port.Open()
    ```

1. Leave the Terminal open for the next task.

#### Task 2: Write data

To send data to the NDLR, you can use the [WriteLine()](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.serialport.writeline) method.

1. Enter the following command, and then select Enter to send data to the NDLR:

    ```PowerShell
    $command = "text"
    $port.WriteLine($command)
    ```

    ![powershell_writedata](images/powershell_writedata.png)


#### Task 3: Read data

To read data back from the NDLR after sending the command, you can use of course [ReadLine()](https://docs.microsoft.com/en-us/dotnet/api/system.io.ports.serialport.readline). However you can also use [ReadExisting()](https://docs.microsoft.com/dotnet/api/system.io.ports.serialport.readexisting) to read all the data at once. 

1. Enter the following command, and then select Enter to receive data from the NDLR:
    ```PowerShell
    $port.ReadExisting()
    ```
    ![powershell_readexisting](images/powershell_readexisting.png)

    > **Note**: Of course, the command **text** isn't recognized by the NDLR.

#### Task 4: Show NDLR Advanced settings Menu

If a wrong command is sent to the NDLR, it will respond with limited help information. 
   
1. Enter the following command, and then select Enter to show the **NDLR Advanced settings menu**:
    ```PowerShell
    $command = "?"
    $port.WriteLine($command)
    $port.ReadExisting()
    ```
    ![powershell_command_a1](images/powershell_showmenu.png)
    
#### Task 5: Show App Version Info

If a wrong command is sent to the NDLR, it will respond with limited help information. 
   
1. Enter the following command, and then select Enter to show the **NDLR Advanced settings menu**:
 
   ```PowerShell
    $command = "a"
    $port.WriteLine($command)
    $port.ReadExisting()
    ```
 
   ![powershell_menu_a](images/powershell_menu_a.png)

#### Task 6: Show Boot Menu Settings

If a wrong command is sent to the NDLR, it will respond with limited help information. 
   
1. Enter the following command, and then select Enter to show the **NDLR Advanced settings menu**:

    ```PowerShell
    $command = "b"
    $port.WriteLine($command)
    $port.ReadExisting()
    ```
 
   ![powershell_menu_b](images/powershell_menu_b.png)

#### Task 7: Disconnect
The Serial connection will be disconnected automatically when you close PowerShell. However to prevent the COM port to remain open, it is recommended to close the port.

1. Enter the following command, and then select Enter to close the COM port:

    ```PowerShell
    $port.Close()
    ```
 
   ![powershell_command_a1](images/powershell_close.png)

1. Close all currently running instances of the **Windows Terminal** application.


