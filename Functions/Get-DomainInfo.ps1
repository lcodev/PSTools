function Get-DomainInfo {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string[]]
        $ComputerName
    )
    
    foreach ($computer in $ComputerName) {
        $domainData = Get-CimInstance -ClassName Win32_NTDomain

        $properties = @{
            ComputerName    = $computer
            DnsForestName   = $domainData.DnsForestName[1]
            DCAddress       = $domainData.DomainControllerAddress[1]
            DCName          = $domainData.DomainControllerName[1]
            DomainGUID      = $domainData.DomainGuid[1]
        }

        $obj = New-Object -TypeName psobject -Property $properties
        Write-Output $obj

    } # end foreach loop

} # end function

Get-DomainInfo