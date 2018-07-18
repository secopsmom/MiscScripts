$FileDate = Get-Date -UFormat %m%d%Y'-'%H%M
$DateTime = Get-Date
$ContentFile = "C:\Temp\servers.txt"
$LogFilePath = ".\"
$LogFile = $LogFilePath + "DNSLogging-" + $FileDate + ".txt"
$newDNS = “172.32.36.18","172.32.36.18"
$CSVfile = ".\DNSUpdate" + $FileDate + ".csv"
$sendtofile = ""
$errortofile = ""
      
$sendtofile += "HostName`tCurrent DNS`tCurrent  WINS`tNew DNS`tNewWINS`tDNS Success`tWINS Success`n"   
    try{
            $servers = Get-Content $ContentFile -ErrorAction Stop
      }
      catch{
            $errmsg = "Failed to Open Servers List.  Action Stopped"
            "***ERROR't $errMSG" | Out-File $LogFile -Append
            break
      }

foreach($server in $servers){
    Write-Host "Connecting to $server..."
    try{
        $nics = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $server -ErrorAction Stop | where{($_.IPEnabled -eq "TRUE") -and ($_.DNSServerSearchOrder -ne $Null)}
        
        foreach($nic in $nics){
        $WINSServer1 = $nic.WINSPrimaryserver
        $WINSServer2 = $nic.WINSSecondaryserver
        Write-Host "`tExisting DNS Servers " $nic.DNSServerSearchOrder
        
        ("`Hostname: " + $Server) | Out-File $LogFile -append
        $sendtofile += ($Server + "`t")
        ("`tCurrent DNS Settings " + $nic.DNSServerSearchOrder) | Out-File $LogFile -append
        $oldDNS = $nic.DNSServerSearchOrder
        $sendtofile += ("{" + $oldDNS + "}" + "`t")
        ("`tCurrent WINS Servers " + $WINSServer1 + " " + $WINSServer2) | Out-File $LogFile -append
        $sendtofile += ($WINSServer1 + " \ " + $WINSServer2 + "`t")
        
        
          $x = $nic.SetDNSServerSearchOrder($newDNS)
          $y = $nIC.SetWINSServer("100.11.11.11”, "")
        
        $WINSServer1 = ""
        $WINSServer2 = ""
             
        }
    }
    Catch{
        $ConnectionFailed = "Failed to connect to " + $server
        $ConeectionFailed | Out-File $LogFile -append
        #$sendtofile += ("`n***ERROR" + $ConnectionFailed + "`n")
    }
    finally{}
    
####################  REPORT CHANGES IN OBJECTITEM.DNSSERVERSEARCHORDER ######################
####################  REPORT CHANGES IN OBJECTITEM.WINSSERVERPRIMARY  ########################
####################  REPORT CHANGES IN OBJECTITEM.WINSSERVERSECONDARY #######################

    
    try{
        $updatednics = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $server -ErrorAction Stop | where{($_.IPEnabled -eq "TRUE") -and ($_.DNSServerSearchOrder -ne $Null)}
        
        foreach($updatednic in $updatednics){
        $WINSServer1 = $updatednic.WINSPrimaryserver
        $WINSServer2 = $updatednic.WINSSecondaryserver
        Write-Host "`tUpdated DNS Servers " $updatednic.DNSServerSearchOrder
        
        ("`Hostname: " + $Server) | Out-File $LogFile -append
        
        ("`tUpdated DNS Settings " + $updatednic.DNSServerSearchOrder) | Out-File $LogFile -append
        $UpdatedDNS = $updatednic.DNSServerSearchOrder
        $sendtofile += ("{" + $UpdatedDNS + "}" + "`t")
        ("`tUpdated WINS Servers " + $WINSServer1 + " " + $WINSServer2) | Out-File $LogFile -append
        $sendtofile += ($WINSServer1 + " \ " + $WINSServer2 + "`t")
        }
        
        if($newDNS -eq $updatedDNS){
        $DNSdelta = 2
        }
        else{
        $DNSdelta = "3"
        }
        
        if(($WINSServer1 -eq "100.11.11.11”) -and ($WINSServer2 -eq "")){
        $WINSdelta = 2
        }
        else{
        $WINSdelta = ""
        }
    }
    Catch{
        $errmsg = "`n" + $server + " DNS & WINS check SKIPPED" 
        $errmsg | Out-File $LogFile -append
        $ConnectionFailed = $server + "`t****ERROR**** Failed To Connect`t****ERROR**** Failed To Connect`t****ERROR**** Failed To Connect`t****ERROR**** Failed To Connect`t****ERROR**** Failed To Connect`t****ERROR**** Failed To Connect"
        $errortofile += $ConnectionFailed + "`n"        
    }

    finally{}

}

###############  REPORT DNS & WINS SUCCESS or FAIL ################
if($DNSdelta = 2){
$Sendtofile += "DNS Update Success"
}  
else{
$sendtofile += "DNS Update Failed"
}

if($WINSdelta = 2){
$sendtofile += "`tWINS Change Success"
} 
else{
$sendtofile += "`tWINS Update Failed"
}

#if($ConnectionFailed -ne $null){
#$sendtofile += ("`n***ERROR" + $ConnectionFailed + "`n")
#} 

$sendtofile | Out-File $CSVfile