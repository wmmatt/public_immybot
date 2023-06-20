<# 
    .DESCRIPTION
    By default, Windows allows logged on user credentials to be stored in memory in plain text. This is a simple way to obtain credentials when an attacker has even a small foothold in an environment.

    Disabling this setting has no consequence, and should be disabled by default for all systems.

    This Task is designed to check the current configuration of the WDigest reg key for "UseLogonCredential", then to disable WDigest if it finds it is not already disabled.
#>

# Test
# The desired value is 0 to disable plain text creds so if true, we're good!
# Note that when ran as Audit, $method -ne 'Set' which means this will just check the value and return truthy/falsy and not actually set it
Get-WindowsRegistryValue -Path 'HKLM:\\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' -Name UseLogonCredential | RegistryShould-Be -Value 0

# Get
(Get-WindowsRegistryValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' -Name UseLogonCredential).Value

# Set
# Setting this value to 0 disables plain text creds in memory
Get-WindowsRegistryValue -Path 'HKLM:\\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' -Name UseLogonCredential | RegistryShould-Be -Value 0