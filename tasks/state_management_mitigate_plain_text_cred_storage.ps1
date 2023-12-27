<# 
    .DESCRIPTION
    By default, Windows allows logged on user credentials to be stored in memory in plain text. This is a simple way to obtain credentials when an attacker has even a small foothold in an environment.

    Disabling this setting has no consequence, and should be disabled by default for all systems.

    This Task is designed to check the current configuration of the WDigest reg key for "UseLogonCredential", then to disable WDigest if it finds it is not already disabled.
#>
$method = 'test'
$registryPath = 'HKLM:\\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'
$registryName = 'UseLogonCredential'
$value = 0

Switch ($method) {
    'test' {
        Confirm-RegistryValue -Path $registryPath -Name $registryName -Value $value -Method $method
    }

    'set' {
        Confirm-RegistryValue -Path $registryPath -Name $registryName -Value $value -Method $method
    }
}
