If (!$method) {
    $method = 'test'
}

switch ($method) {
    'test' {
        # Retrieve all network adapters on the system
        $networkAdapters = Get-NetAdapter

        # Initialize a flag to indicate whether IPv6 is disabled on all NICs
        $ipv6DisabledOnAll = $true

        # Iterate over each network adapter
        foreach ($adapter in $networkAdapters) {
            # Retrieve the IPv6 binding for the current adapter using its name
            # ComponentID ms_tcpip6 represents the IPv6 protocol
            $ipv6Binding = Get-NetAdapterBinding -ComponentID ms_tcpip6 -InterfaceAlias $adapter.Name

            # Check if IPv6 is enabled on the adapter
            if ($ipv6Binding.Enabled) {
                # Set the flag to false if IPv6 is enabled on any adapter
                $ipv6DisabledOnAll = $false
                break
            }
        }

        # Output the result
        # $true if IPv6 is disabled on all NICs, $false otherwise
        $ipv6DisabledOnAll
    }

    'set' {
        # Retrieve all network adapters on the system
        $networkAdapters = Get-NetAdapter

        # Iterate over each network adapter
        foreach ($adapter in $networkAdapters) {
            # Retrieve the IPv6 binding for the current adapter using its name
            # ComponentID ms_tcpip6 represents the IPv6 protocol
            $ipv6Binding = Get-NetAdapterBinding -ComponentID ms_tcpip6 -InterfaceAlias $adapter.Name

            # If IPv6 is enabled on the adapter, attempt to disable it
            if ($ipv6Binding.Enabled) {
                try {
                    # Attempting to disable IPv6 on the adapter
                    Set-NetAdapterBinding -ComponentID ms_tcpip6 -InterfaceAlias $adapter.Name -Enabled $false -ErrorAction Stop
                    Write-Host "IPv6 has been successfully disabled on adapter: $($adapter.Name)"
                } catch {
                    # Throwing an error if disabling IPv6 fails
                    throw "Failed to disable IPv6 on adapter: $($adapter.Name). Error: $_"
                }
            }
        }

        Write-Host "IPv6 has been disabled on all applicable NICs."
    }
}
