[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072);
(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/dkbrookie/PowershellFunctions/master/Library.Users.ps1') | Invoke-Expression
$builtinAdmin = Get-BuiltInAdministrator
$ApprovedLocalAdmin = $ApprovedLocalAdmin + $EnforcedLocalAdmins

switch($method)
{
    'test' {
        # Check to ensure $EnforcedLocalAdmins exist and are members of the Local Administrators group
        If ($EnforcedLocalAdmins) {
            $EnforcedLocalAdmins | ForEach-Object {
                If (!(Get-LocalUserExists -UserName $_) -or !(Get-IsLocalAdmin -UserName $_)) {
                    $enforcedStatus = $False
                } Else {
                    $enforcedStatus = $True
                }
            }
        } Else {
            # This would mean $EnforcedLocalAdmins was not defined, so the status of this is good
            $enforcedStatus = $True
        }

        # Check to ensure $UsersToDisable are currently all disabled
        If ($UsersToDisable) {
            $UsersToDisable | ForEach-Object {
                If ((Get-LocalUserStatus -UserName $_).Enabled) {
                    $disableStatus = $False
                } Else {
                    $disableStatus = $True
                }
            }
        } Else {
            # This would mean $UsersToDisable was not defined, so the status of this is good
            $disableStatus = $True
        }

        # Check to ensure the built-in local Administrator account is disabled
        If ((Get-LocalUserStatus $builtinAdmin.Name).Enabled) {
            $builtinStatus = $False
        } Else {
            $builtinStatus = $True
        }

        # Return our end result
        If (!$enforcedStatus -or !$disableStatus -or !$builtinStatus) {
            Return $False
        } Else {
            Return $True
        }
    }
    'set' {
        # Make sure we stop on any errors to avoid breaking local admin access. Example would
        # include failing to make a new local admin account, then removing all local admin 
        # accounts and making us lose local admin access to the machine.
        $ErrorActionPreference = 'Stop'
        
        # Throw if this is an active directory server
        If ((wmic path win32_operatingsystem get producttype /value) -like '*ProductType=2*') {
            Throw "This script cannot run on domain controllers"
        } Else {
            "Verified [$env:COMPUTERNAME] is not a domain controller and is eligible to run this configuration management script"
        }

        # Check to see if the default EnforcedLocalAdmins local admin account exists and create it if not
        If ($EnforcedLocalAdmins) {
            $EnforcedLocalAdmins | ForEach-Object {
                If (!(Get-LocalUserExists -UserName $_)) {
                    New-LocalAdmin -UserName $_
                } Else {
                    "Verified the user [$_] exists"
                }

                # Ensure $EnforcedLocalAdmins are in the local administrators group
                If (!(Get-IsLocalAdmin -UserName $_)) {
                    Set-ExistingAccountConfig -UserName $_
                } Else {
                    "Verified [$_] is a member of the Local Administrators group"
                }
            }
        }

        # Verify the built-in Administrator local user is disabled and enforce disable
        If ((Get-LocalUserStatus $builtinAdmin.Name).Enabled -ne $False) {
            Disable-LocalUserAccount -UserName $builtinAdmin.Name
        } Else {
            "Verified the default [Administrator] account is disabled"
        }

        # Remove all users from the local Administrators group that have not been specified to stay
        Get-LocalAdminGroupMembers | Where-Object { $_.Name -notin $ApprovedLocalAdmin -and $_.Name -ne $builtinAdmin.Name } | ForEach-Object {
            Remove-FromLocalAdminGroup -UserName $_.Name
        }

        # Disable all accounts specified in the $UsersToDisable list
        If ($UsersToDisable) {
            $UsersToDisable | ForEach-Object {
                If ((Get-LocalUserStatus -UserName $_).Enabled) {
                    Disable-LocalUserAccount -UserName $_
                }
            }
        }
    }
}
