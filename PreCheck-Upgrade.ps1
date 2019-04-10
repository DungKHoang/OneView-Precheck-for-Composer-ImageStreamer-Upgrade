Param ($credential , $hostname)

# Check connection
if (-not ($credential))
{
    $credential = get-credential -message "Please provide admin credential to log into...."
}

if (-not ($hostname))
{
    $hostname   = read-host "Please provide the FQDN name or IP address of OneView"
}

write-host -foreground CYAN '1#  save the Appliance support dump to C:'
New-HPOVSupportDump -location  C: -type appliance


write-host -foreground CYAN  '2# generate a new backup, and if a remote location is configured, will initiate the file transfer. If not configured, then the Cmdlet will download the file to the current working directory.'
New-HPOVBackup

write-host -foreground CYAN 'The backup file is..'
Get-HPOVBackup


write-host
write-host '3# check composer health active/standy cluster'
$Composers = Get-HPOVComposerNode
Foreach ($Composer in $Composers) {
  write-host $Composer.ApplianceConnection,$composer.modelNumber,$composer.Name,$composer.Role,$composer.state,$composer.status
}

write-host -foreground CYAN '4# check appliance web server certificate expiration'
$AppCert = Get-HPOVApplianceCertificateStatus
write-host $AppCert.ApplianceConnection   $AppCert.validUntil

write-host -foreground CYAN '5# Confirm no critical alerts on the uplinks or logical Enclosure or interconnect modules'
'Enclosure','InterconnectBay','Network'| % { get-hpovalert -Timespan (New-TimeSpan -Days 2) -HealthCategory $_   | where Severity -eq 'Critical' }


write-host  -foreground CYAN '6# Check all interconnect modules are in a configured state'
Get-HPOVInterconnect | select name, state