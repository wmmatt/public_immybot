<# 
    .DESCRIPTION
    By default, Windows allows logged on user credentials to be stored in memory in plain text. This is a simple way to obtain credentials when an attacker has even a small foothold in an environment.

    Disabling this setting has no consequence, and should be disabled by default for all systems.

    This Task is designed to check the current configuration of the WDigest reg key for "UseLogonCredential", then to disable WDigest if it finds it is not already disabled.
#>

# Define the registry path for the key to be checked or modified
$registryPath = 'HKLM:\\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'
# Define the name of the registry key
$registryName = 'UseLogonCredential'
# Define the value to compare or set for the registry key
$value = 0

# Default method to 'test' if not specified
If (!$method) {
    $method = 'test'
}

# Switch statement to handle different methods: 'test' or 'set'
Switch ($method) {
    # 'test' mode: check if the current registry value matches the specified value
    'test' {
        Confirm-RegistryValue -Path $registryPath -Name $registryName -Value $value -Method $method
    }

    # 'set' mode: set the registry value to the specified value
    'set' {
        Confirm-RegistryValue -Path $registryPath -Name $registryName -Value $value -Method $method
    }
}
