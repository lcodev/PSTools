function Get-AVData {

<#
    .SYNOPSIS
    Retrieves Antivirus definitions version and latest virus definitions
    from one to n number of computers.

    .DESCRIPTION
    Get-AVData uses Invoke-Command cmdlet to query systems symantec registry
    values and retrieve product version and latest virus definitions date

    .PARAMETER ComputerName
    One or more computer names or IP addresses, up to a maximum of 10.

    .PARAMETER LogErrors
    Specify this switch to create a text log file of computers that could
    not be queried.

    .PARAMETER ErrorLog
    When used with -LogErrors, specifies the file path and name to which
    failed computer names will be written. Defaults to C:\Retry.txt

    .EXAMPLE
    Get-Content names.txt | Get-SystemData

    .EXAMPLE
    Get-SystemData -ComputerName SERVER1, SERVER2

#>

    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]
        $ComputerName,
        [string]$ErrorLog = 'C:\retry.txt',
        [switch]$LogError
    )

    begin {
        Write-Verbose "Errors sent to $ErrorLog"
    }

    process {
        Write-Verbose "Beginnig PROCESS block"
        foreach ($computer in $ComputerName) {
            Write-Verbose "Querying $computer"

            # test for online computers
            try {
                $pass = $true
                $version = Invoke-Command -ScriptBlock {(Get-ItemProperty -Path 'HKLM:\SOFTWARE\symantec\Symantec Endpoint Protection\CurrentVersion').PRODUCTVERSION} -ComputerName $computer -ErrorAction Stop
            }
            catch {
                if ($LogErrors) {
                    Write-Warning -Message "$computer did not respond"
                    $pass = $false
                    $computer | Out-File -FilePath $ErrorLog -Append
                    Write-Warning -Message "Errors logged at $ErrorLog"
                }

            } # end try-catch statement

            # Systems online. Process data
            if ($pass) {
                $virusdefs = Invoke-Command -ScriptBlock {(Get-ItemProperty -Path 'HKLM:\SOFTWARE\symantec\Symantec Endpoint Protection\CurrentVersion').LatestVirusDefsDate} -ComputerName $computer

                # hash table for data
                $properties = @{
                    ComputerName        = $computer
                    SymanteVersion      = $version
                    LatestDefinitions   = $virusdefs
                }

                # custom output object
                $obj = New-Object -TypeName psobject -Property $properties
                $obj.psobject.TypeNames.Insert(0, 'LCO.AVData')
                Write-Output $obj

            } # end if statement

        } # end foreach-loop $computer

    } # end PROCESS block

    end {
        Write-Verbose -Message "Symantec Endpoint Protection queryies complete"
    }

} # end function