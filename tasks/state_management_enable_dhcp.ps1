<#
    .DESCRIPTION
    This script manages DHCP settings on network interfaces (NICs), excluding non-network adapters like Bluetooth.
    In 'test' mode, it checks if DHCP is enabled on all network NICs, returning $true if so, $false otherwise.
    In 'set' mode, it enables DHCP on all network NICs.
#>


# Determine the method to execute ('test' or 'set')
If (!$method) {
    $method = 'test'
}


switch ($method) {
    'test' {
        # Retrieve all network adapters with a NetConnectionID (typically excludes non-network adapters like Bluetooth)
        $networkAdapters = Get-NetAdapter | Where-Object { $_.PhysicalMediaType -ne 'BlueTooth' }
        # Initialize a flag to indicate whether DHCP is enabled on all network NICs
        $dhcpEnabledOnAll = $true

        # Iterate over each network adapter
        foreach ($adapter in $networkAdapters) {
            # Retrieve the IP configuration for the current adapter
            $ipConfig = ($adapter | Get-NetIPConfiguration).NetIPv4Interface

            # Check if DHCP is not enabled on the adapter
            if ($ipConfig.Dhcp -ne 'Enabled') {
                # Set the flag to false if DHCP is not enabled on any adapter
                $dhcpEnabledOnAll = $false
                break
            }
        }

        # Output the result
        # $true if DHCP is enabled on all network NICs, $false otherwise
        $dhcpEnabledOnAll
    }

    'set' {
        # Retrieve all network adapters with a NetConnectionID
        $networkAdapters = Get-NetAdapter | Where-Object { $_.PhysicalMediaType -ne 'BlueTooth' }

        # Iterate over each network adapter
        foreach ($adapter in $networkAdapters) {
            try {
                # Retrieve the IP configuration for the current adapter
                $ipConfig = ($adapter | Get-NetIPConfiguration).NetIPv4Interface

                # Check if DHCP is not enabled on the adapter
                if ($ipConfig.Dhcp -ne 'Enabled') {
                    # Attempting to enable DHCP on the adapter
                    $adapter | Set-NetIPInterface -Dhcp Enabled -ErrorAction Stop
                    $adapter | Set-DnsClientServerAddress -ResetServerAddresses -ErrorAction Stop
                    Write-Host "DHCP has been successfully enabled on adapter: $($adapter.Name)"
                }
            } catch {
                # Throwing an error if enabling DHCP fails
                throw "Failed to enable DHCP on adapter: $($adapter.Name). Error: $_"
            }
        }

        Write-Host "DHCP has been enabled on all applicable network NICs."
    }
}
