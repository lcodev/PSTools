[int]$scopes = Read-Host "number of scopes being created"

for ($i = 0; $i -lt $scopes; $i++) {
    $ComputerName = 'dhcp-server'
    $ScopeName = Read-Host "enter scope name"
    $StartRange = Read-Host "start range"
    $EndRange = Read-Host "end range"
    $SubnetMask = "255.255.255.0"
    $Description = Read-Host "enter scope description"
    $ScopeId = Read-Host "enter scope id"
    $DefaultGateway = Read-Host "enter default gateway"
    $Domain = "lco.net"

    # create the scopes
    Add-DhcpServerv4Scope -Name $ScopeName -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubnetMask -ComputerName $ComputerName -Description $Description
    Set-DhcpServerv4OptionValue -ScopeId $ScopeId -Router $DefaultGateway -DnsDomain $Domain -DnsServer 8.8.8.8 -ComputerName $ComputerName
}