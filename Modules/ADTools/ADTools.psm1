# Implement your module commands in this script.
function Set-SystemLocation {

    <#
        .SYNOPSIS
        Sets a system location for the Active Directory object
        
        .DESCRIPTION
        Set-SystemLocation uses the Set-ADComputer AD Cmdlet
        to set a system location for one or many computer objects.
        Specify computers by AD object identity.
        
        .PARAMETER ComputerName
        One or more Active Directory computer objects.
        
        .EXAMPLE 
        Get-Content names.txt | Set-SystemLocation
        
        .EXAMPLE
        Set-SystemLocation -ComputerName SERVER1, SERVER2
            
    #>

    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $ComputerName,
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]
        $Location   
    )
    
    begin {
        Write-Verbose -Message "Starting function"
    }
    
    process {
        Write-Verbose -Message "Beginning PROCESS block"
        foreach ($computer in $ComputerName) {
            $date = Get-Date
            $str = $Location
            Set-ADComputer -Identity $computer -Location "$str - $date" -Credential lco\admin
        }
    }
    
    end {
        Write-Verbose -Message "Set location process completed"
    }
}

function Get-DomainInfo {

    <#
        .SYNOPSIS
        Get local or remote system domain information
        
        .DESCRIPTION
        Get-DomainInfo uses Common Information Module (CIM) Instance
        to retrieve Windows Domain information from local or remote computers.
        Specify computers by name of by IP address.
        
        .PARAMETER ComputerName
        One or more computer names or IP addresses, up to a maximum of 10.
        
        .EXAMPLE
        Get-DomainInfo -ComputerName SERVER1, SERVER2
            
    #>

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
            ComputerName  = $computer
            DnsForestName = $domainData.DnsForestName[1]
            DCAddress     = $domainData.DomainControllerAddress[1]
            DCName        = $domainData.DomainControllerName[1]
            DomainGUID    = $domainData.DomainGuid[1]
        }

        $obj = New-Object -TypeName psobject -Property $properties
        Write-Output $obj

    } # end foreach loop

} # end function

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
