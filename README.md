# Pre-check for upgrade

The script runs pre-check operations before OneView upgrade to 4.20



## Prerequisites
The script requires:
   * the latest OneView PowerShell library : https://github.com/HewlettPackard/POSH-HPOneView/releases




## Syntax

```
   $cred    = get-credential   # Provide admin credential to connect to OneView
    .\precheck-upgrade.ps1  -hostname  <FQDN-OneView> -credential $cred 

```

    
