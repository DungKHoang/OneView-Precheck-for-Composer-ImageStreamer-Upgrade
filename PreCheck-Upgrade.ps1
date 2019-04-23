Param (
  $credential , 
  $hostname,
  [Boolean]$CreateBackupSupport)




# Check connection
if (-not ($credential))
{
    $credential = get-credential -message "Please provide **** admin credential***  to log to OneView...."
}

if (-not ($hostname))
{
    $hostname   = read-host "Please provide the FQDN name or IP address of OneView"
}

write-host -foreground CYAN  '#################################################'
write-host -foreground CYAN  "Connecting to OneView ... $hostname"
write-host -foreground CYAN  '##################################################'
Connect-HPOVMgmt -hostname $hostname -Credential $cred

if ($CreateBackupSupport)
{
    # Create folder to host backup and Dump
  $currentFolder  = Split-Path $MyInvocation.MyCommand.Path
  $folder         = "$currentFolder\OV-Backup-Dump"

  if (-not (test-path $folder))
  {
    md $folder
  }

  write-host -foreground CYAN '1#  save the Appliance support dump to C:'
  New-HPOVSupportDump -location  $folder -type appliance


  write-host -foreground CYAN  '2# generate a new backup, and if a remote location is configured, will initiate the file transfer. If not configured, then the Cmdlet will download the file to the current working directory.'
  New-HPOVBackup

  write-host -foreground CYAN 'The backup file is..'
  Get-HPOVBackup

  write-host -foreground CYAN 'Downloading the backup file..'
  Save-HPOVBackup -location $folder
}

write-host
write-host -foreground CYAN '3# check composer health active/standy cluster'
Get-HPOVComposerNode | select ApplianceConnection,modelNumber,Name,Role,state,status

write-host -foreground CYAN '4# check appliance web server certificate expiration'
Get-HPOVApplianceCertificateStatus 

write-host -foreground CYAN '5# Confirm no critical alerts on the uplinks or logical Enclosure or interconnect modules'
'Enclosure','InterconnectBay','Network'| % { get-hpovalert -Timespan (New-TimeSpan -Days 2) -HealthCategory $_   | where Severity -eq 'Critical' }


write-host  -foreground CYAN '6# Check all interconnect modules are in a configured state'
Get-HPOVInterconnect | format-table -auto name, state

write-host  -foreground CYAN '7# Check local login'
if ( (Get-HPOVLdap).allowLocalLogin )
{
  write-host -foreground CYAN "Local login is allowed"
}
else 
{
  write-host -foreground YELLOW "Local login is NOT allowed"  
}


Disconnect-HPOVMgmt