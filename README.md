**Archived System Online Script Overview:**  
This script was created as a replacement for an antivirus feature that was being phased out.

**What the script does:**  
- Detects when a system is powered on and connected to the internet.  
- Sends an email notification to the IT team that the system is online.  
- Prompts the user with security and compliance warnings.  
- Automatically reboots the system every 15 minutes until one of the following occurs:  
  - The user disconnects from the internet (reducing security risk).  
  - The user contacts IT to stop the reboot and install the required security software.  

---

**Revert to Classic Context Menu Script Overview:**  

**Classic Context Menu Reversion**  
This script is designed to revert the Windows 11 right-click (context) menu back to the classic Windows 10 style. Its primary purpose is to restore quick access to common options—such as the "Rename" function—that are otherwise hidden behind an additional "Show more options" submenu in Windows 11. This was per client requests; multiple users called in wanting to know if we could revert it back.  

**What It Does:**  
- Modifies specific Windows Registry values related to the context menu behavior.  
- Restarts File Explorer service for the registry changes to take effect.  
- Re-enables the full, classic right-click menu immediately—without requiring the extra step.  
- Helps improve workflow efficiency by restoring familiar functionality from Windows 10.

