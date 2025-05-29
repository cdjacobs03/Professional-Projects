# Will Detect an Archived system, when it comes ONLINE
Import-Module $envSyncroModule -WarningAction SilentlyContinue


# Send email to our support queue
function emailQueue() {
Send-Email -Subdomain SUBDOMAIN -To support@resolveitcomputers.COM -Subject $assetname ($customername) is Online -Body $assetname ($customername) is Online. brUser has been prompted to reach out. brbrSystem will restart every 15 minutes until EITHERbr1)We place Asset in defualt folder.brORbr2)System disconnects from Internet.brbrIf Reboot Loop Does Not StopbrThen go to asset in Syncro and run 'STOP Online System Reboot Loop' script. 
}


function placeScript() {
    
# Check to see if path i son system, if not add it. 
$Path = CUsersresolveittemp
if (-Not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path CUsersresolveittemp
}

# Put a file on system that runs at startup. 
    # The File will check for the Stop File, if no stop file, it will continue to restart system. 
    # Stop file is pushed by us, script name - STOP Online System Reboot Loop
$scriptPath = CUsersresolveittempRebootLoop.ps1

    # Put Script on System
    try {
@'
        #Test for Internet Connection First Before Proceeding with script.
    if (-not (Test-Connection -ComputerName 8.8.8.8 -Quiet -Count 1)) {  
    Write-Host No Internet Connection. Exiting Script.
    exit 
	}
    Write-Host Internet Connection is Established.
    #Prompt user warning and to reach out. 
 function promptUser() {   
  try { 
    $caption = Notice from ResolveIT
    $text = Notice This system has been decommissioned and does not have our managed security protections. Continuing to use this device poses a potential security risk. To ensure compliance and protection, please contact our team to have the system re-secured. We may need approval from your company’s management. Important As a precautionary measure, this system will automatically restart every 15 minutes until it is properly secured.

    Set-ItemProperty -Path HKLMSOFTWAREMicrosoftWindowsCurrentVersionPoliciesSystem -Name ArchiveNoticeCaption -Value $caption
    Set-ItemProperty -Path HKLMSOFTWAREMicrosoftWindowsCurrentVersionPoliciesSystem -Name ArchiveNoticeText -Value $text
  } catch {
      Write-Host Error $_
    }
}

function rebootComputer() {
    #Wait 5 minutes for Syncro Service to come online
    Start-Sleep -Seconds 600
    Write-Host Waited 10 minutes for Syncro Service
    
    try {
     
        Start-Sleep -Seconds 300
        Write-Host Waited 5 minutes to complete 15 min wait.
	    Write-Host Rebooted computer
        Restart-Computer -Force
        
    }
   } catch {
     Write-Host Error $_
    }
}
function main() {
    promptUser
    rebootComputer

}

main
'@  Set-Content -Path $scriptPath -Encoding UTF8
    }
    catch {
     Write-Host Error $_
    }
}


function registerScheduleTask() {
# This Registers a Scheduled Task at startup to run the RestartLoop file placed on system
    $scriptPath = CUsersresolveittempRebootLoop.ps1
    try {
        schtasks Create TN RebootEvery15Min `
         TR powershell.exe -ExecutionPolicy Bypass -File `$scriptPath` `
         SC ONSTART RL HIGHEST F RU SYSTEM
    }
    catch {
        Write-Host Error $_
    }
}


function main() {
    #Call all 3 functions.
    emailQueue
    placeScript
    registerScheduleTask
    
}



main

