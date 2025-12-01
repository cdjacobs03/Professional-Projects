Import-Module $env:SyncroModule -WarningAction SilentlyContinue

#Store variables. 

#Conversion Status
$conversionStatus = (manage-bde -status C: | find "Conversion Status:") -replace '.*Conversion Status:\s*', ''
#Status of Encryption.
$status = (manage-bde -status C: | find "Protection Status:") -replace '.*Protection Status:\s*', ''
#Operating Sytem.
$OS = (systeminfo | find "OS Name:") -replace '.*OS Name:\s*', ''
#Percentage Encrypted
$PE = (manage-bde -status C: | find "Percentage Encrypted:") -replace '.*Percentage Encrypted:\s*', ''
#Global Variable LoopCount
$global:loopCount = 0




#Output function
function output {
    #Key Prtoectors
    $kpLines = manage-bde -status C: | ForEach-Object {
    if ($_ -match "Key Protectors:") { $start = $true; return }
    if ($start -and $_ -match "^\s+\S") { $_.Trim() }
} 

    #Main If/Else Statement, that only continues if status is not "In Progress", is not "Decrypted",  and system is not a Virtual Machine.
    if($OS -notmatch "\bHome\b" -and $conversionStatus -notmatch "\bIn Progress\b" -and $conversionStatus -notmatch "\bDecrypted\b" -and $assetModel -notmatch "\bVirtual Machine\b" -and $conversionStatus -notmatch "\bPaused\b") {
        #Logical if else statement for if system is fully encrypted, and has tpm and numberical password as Key Protectors.
        $count = 0
        $tpmStatus = 0
        $numericalStatus = 0
        
        #Check encryption status 
        Write-Host "Encryption shows Enabled. Checking Percentage..."
        $Body = "Encryption shows Enabled.<br><br>"
        
        #Check Percentage Encrypted
        if($PE -ne "100.0%") {
            Write-Host "System is not 100% Encrypted."
            Write-Host "  "
            Write-Host "Checking Key Protectors..."
            $Body +="System is NOT 100% Encrypted. It is at $PE<br><br>"
        }
        else {
            Write-Host "System is 100% Encrypted."
            $Body += "System is 100% Encrypted.<br><br>"
        }
        #Check Key Protectors: TPM
        Write-Host "Checking if Key Protectors include TPM and Numerical Password..."
        if($kpLines -match "\bTPM\b") {
            Write-Host "TPM is a Key Protector."
            $Body += "TPM is a Key Protector.<br><br>"
            $tpmStatus += 1
        }
        else {
            Write-Host "TPM is Not a Key Protector."
            $Body += "TPM is NOT a key Protector.<br><br>"
        }
        
        #Check Key Protectors: Numberical Password
        if($kpLines -match "\bNumerical Password\b") {
            Write-Host "Numerical Password is a Key Protector."
            $Body += "Numerical Password is a Key Protector.<br><br>"
            #Grab Key and write to ouput. 'Get-Bitloccker Keys' script is supposed to run, but incase it doesnt. Better safe than sorry. 
            $var = (Get-BitLockerVolume -MountPoint $drive).KeyProtector.recoverypassword
            Write-Host "BitLocker Key(s) in Case Syncro does not grab them: $var" 
            $numericalStatus += 1
        }
        else {
            Write-Host "Numerical Password is Not a Key Protector."
            $Body +="Numerical Password is Not a Key Protector.<br><br>"
        }
        
        #See if TPM and Numberical Password are both there, if not then remediate: count = 2 if both are there. 
        $count = $tpmStatus + $numericalStatus
        if($count -eq 2) {
            #Return true, so no email is sent and no auto remediation occurs. 
            Write-Host "System is Fully Encrypted with no missing parts."
            return "true" #Returning true to email function, will make it NOT send an email. 
        }
        #This mean something needs remediated, tpm and/or numerical password.
        else {
            #Check that it has not already gone through remediation, because its recursive.
            if($loopCount -eq 0) {
                Write-Host "System's Encryption has missing parts, attempting to automatically remediate..."
                #Check for individual Status's 
                if($tpmStatus -ne 1) {
                    #Call TPM remediation function. 
                    tpmFix
                    
                }
                if($numericalStatus -ne 1) {
                    #Call Numerical Passsword remediation function.
                    numericalFix
                    
                }
            #Finish remediation by recursively calling output again. 
            #Wait 10 seconds before going through and checking again. 
            Start-Sleep -Seconds 10
            $loopCount += 1
            return output
            }
            #This executes after automatic remediation occurs once, so we can get notified to manually remediate.
            else {    
                Write-Host "System Is Encrypted but Not 100% or has missing parts and unsuccessfully auto remediated."
                $body += "Please Manually Remediate Encryption."
                return $body
            }
        } #End of main Else statement
    }#End of main If statement
    #If system is decrypted and is not a Virtual Machine. Then start Encryption.
    elseif($conversionStatus -match "\bDecrypted\b" -and $assetModel -notmatch "\bVirtual Machine\b" -and $OS -notmatch "\bHome\b") {
        #Call fullyEncrypt to start encryption of C:
        Write-Host "System is not Encrypted with BitLocker. Starting to Encrypt now."
        fullyEncrypt # Call Fully Encrypt
        return "false"
      
    }
    #Rare case that status is Paused and system is not a VM, then Resume encryption. 
    elseif($conversionStatus -match "\bPaused\b" -and $assetModel -notmatch "\bVirtual Machine\b") {
        Write-Host "Status of Encryption is Paused, resuming encryption and will check back in tomorrow."
        manage-bde -resume C:
        return "false"
    }
    #If system is a VM. 
    elseif($assetModel -match "\bVirtual Machine\b") {
        Write-Host "System is a Virtual Machine, no need to Encrypt."
        return "true"
    }
    #If system is running windows home.
    elseif($OS -match "\bHome\b") {
        Write-Host "System is running Windows Home and needs to be upgraded. Sending email to queue."
        return "Home"
    }
    #Main If/Else Statement, needs to return nothing if Conversion Status is in Progress. 
    else {
        Write-Host "Conversion Status is In Progress, will check on status again tomorrow."
        return "true"
    }
}


#Called when system is decrypted and needs encryption.
function fullyEncrypt {
    #Start Encryption with skipping hardware test. 
    manage-bde -on C: -skiphardwaretest > $null 2>&1 # this extra bit on the end makes sure it doesnt return anything
    #Add Numerical Password
    manage-bde -protectors -add -recoverypassword c: > $null 2>&1
    #Add TPM
    manage-bde -protectors -add c: -tpm > $null 2>&1
    
    #Write Bitlocker keys to output in case syncro does not catch them until next day 
    $var = (Get-BitLockerVolume -MountPoint $drive).KeyProtector.recoverypassword
    Write-Host "BitLocker Key(s) in Case Syncro does not grab them: $var"
       
}

#If TPM is NOT a key protector. 
function tpmFix {
    #Add TPM Protector
    manage-bde -protectors -add c: -tpm > $null 2>&1
}
  
#If Numberical Password is NOT a key protector. 
function numericalFix {
    #Add RecoveryPassword ("Numerical Password")
    manage-bde -protectors -add -recoverypassword c: > $null 2>&1
}
    
   
#Emails queue if returned value is true. 
function email {
    $output = (output)
    if($output -match "\bEncryption\b" -or $output -match "false" -or $output -match "Home") { 
        #Compose Email and send
        $ipAddress = (ipconfig | find "IPv4 Address") -replace '.*IPv4 Address. . . . . . . . . . . :\s*', '' #Find private IP address. 
        $ipPublicAddress = (Invoke-RestMethod ipinfo.io).ip #Uses Rest to grab public IP.
        $assetname = hostname
        $EmailFrom = "noreply@resolveitcomputers.com"
        $EmailTo = "support@resolveitcomputers.com"
        
        if($output -eq "false") {
            $Body = "This System is Not Encrypted with Bitlocker.<br><br>The Script has attempted to start Encryption and will check on its status again tomorrow.<br><br>Private IP:   $ipAddress<br><br>Public IP:   $ipPublicAddress<br><br> "
            $Subject = "$assetname at $companyName is Decrypted and will Start to Encrypt Now."
        }
        elseif($output -eq "Home"){
            $Body = "This System is running Windows Home and needs to be upgraded.<br><br>Private IP:   $ipAddress<br><br>Public IP:   $ipPublicAddress<br><br> "
            $Subject = "$assetname at $companyName is running Windows Home and needs to be upgraded."
        }
        else {
            $Body = $output + "<br><br>Private IP:   $ipAddress<br><br>Public IP:   $ipPublicAddress<br><br>"
            $Subject = "$assetname at $companyName is Not Fully Encrypted with Bitlocker and Needs Manual Remediation"
        }
        $SMTPServer = "mail.smtp2go.com"
        $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 2525)   
        $SMTPClient.EnableSsl = $true    
        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("noreply@resolveitcomputers.com", "PASSWORD")
        $mailMessage = New-Object System.Net.Mail.MailMessage
        
        #Compose more
        $mailMessage.From = $EmailFrom
        $mailMessage.To.Add($EmailTo)
        $mailMessage.Subject = $Subject
        $mailMessage.Body = $Body
        $mailMessage.IsBodyHtml = $True
        
        #Send
        $SMTPClient.Send($mailMessage)
    
    }
}


function main() {
    #Call Email Function
    email
}

#Call main
main