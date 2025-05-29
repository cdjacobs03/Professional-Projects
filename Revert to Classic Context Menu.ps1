Import-Module $env:SyncroModule

#Run Command
function Run {
    Write-Host "Running Command to Revert Context Menu"
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /d "" /f
}

function Restart {
    Write-Host "Restarting Explorer.exe"
    taskkill /f /im explorer.exe
    Start-Sleep -Seconds 2  
    start explorer.exe  
}

#Main Function to call Command to Run & Reboot File Explorer
function Main {
    #Call the Run function
    Run

    #Call the Restart function
    Restart
}


Main