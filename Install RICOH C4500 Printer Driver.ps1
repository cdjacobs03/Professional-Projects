Import-Module $env:SyncroModule -WarningAction SilentlyContinue


function installDriver {
#Store driver path in DriverInf
$driverInf = "C:\temp\z04410L1d\disk1\MPC4500_.inf"
$driverName = "RICOH IM C4500 PCL 6"

    #Add if statement to see if inf is already on system. 
    if(!(Test-Path $driverInf)) {
    
        #Expand zipped folder
        Expand-Archive -Path "c:\temp\z04410L1c.zip" -DestinationPath "c:\temp"
        #Rename the unzipped file so it doesnt get mixed up with the zipped file. 
        Rename-Item "C:\temp\z04410L1c" "C:\temp\z04410L1d"
        
        #Test again to see if path is there.
        if(!(Test-Path $driverInf)) {
            
            Write-Host "Driver does not exist in specified location."
            
            #Exit whole script, driver does not exist in location it needs to continue
            exit
        }
    }   
    else {
        Write-Host "Driver already exists in C:\temp.."
    }
    
    #Install Driver.
    
    #Add-PrinterDriver -InfPath $driverInf
    $Output = & pnputil /add-driver $driverInf /install /subdirs
    
    #Register Driver
    Add-PrinterDriver -Name $driverName
    
    #Capture and display possibe error from pnputil
    Write-Host $Output
     
}# End of function

function installPrinter {
    Add-PrinterDriver -Name "RICOH IM C4500 PCL 6"

    $driverName = "RICOH IM C4500 PCL 6"
    #Install Printer, check if driver is installed. 
    if (Get-PrinterDriver -Name $driverName -ErrorAction SilentlyContinue) {
        
        #Add Printer Port if needed
        if(Get-PrinterPort -Name "IP_10.0.13.205" -ErrorAction SilentlyContinue) {
            Write-Host "Printer Port IP_10.0.13.205 already exists."
        }
        else {
            #Add Prtiner Port
            Add-PrinterPort -Name "IP_10.0.13.205" -PrinterHostAddress "10.0.13.205"
        }
    
    #Add C4500 Printer
    Add-Printer -Name "CS4500" -DriverName $driverName -PortName "IP_10.0.13.205"
    Write-Host "Printer was installed"
    
      }
    else {
        Write-Host "Driver Name Not Found - Cannot Add Printer"
      }
      
}


function main {
    #Call unzipFolder
    installDriver
    #Install Printer if Driver is 
    installPrinter
}

main