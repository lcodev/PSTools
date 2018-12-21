function Get-RemoteSmbShare  {

    <#
        .SYNOPSIS
        Tool used to get a list of current shared folders from one, and
        up to five computers.

        .DESCRIPTION
        Get-RemoteSmbShare uses Get-SmbShare cmdlet to retrive a complete
        list of current shared folders from each specified computer. User
        specifies computers by name or IP address.

        .PARAMETER ComputerName
        One or more computer names or IP addresses, up to a maximum of 5.

        .EXAMPLE
        Get-RemoteSmbShare -ComputerName SERVER1, SERVER2

        .EXAMPLE
        Get-Content servers.txt | Get-RemoteSmbShare
    #>

    [CmdletBinding()]

    param(
        # Parameter help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('Hostname')]
        [ValidateCount(1, 5)]
        [string[]]$ComputerName,
        [string]$ErrorLog = 'C:\retry.txt',
        [switch]$LogErrors
    )

    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
    }

    PROCESS {
        Write-Verbose "Beginning PROCESS block"

        # Retrieve a list of current shared folders from each specified computer
        foreach ($computer in $ComputerName) {
            Write-Verbose "Querying $computer" 

            # test for online systems
            try {
                $pass = $true
                $data = Invoke-Command -ScriptBlock { Get-SmbShare } -ComputerName $computer -ErrorAction Stop
            } catch {
                if ($LogErrors) {
                    Write-Warning -Message "$computer did not respond"
                    $pass = $false
                    $computer | Out-File $ErrorLog -Append
                    Write-Warning -Message "Logging errors to $ErrorLog"
                }

            } # end try-catch block

            # Systems online. Continue processing
            if ($pass) {
                foreach ($share in $data) {
                    # hash table for share data
                    $properties = @{
                        ComputerName = $computer
                        ShareName    = $share.Name 
                        Description  = $share.Description
                        Path         = $share.Path
                    }

                    # Custom output object
                    $obj = New-Object -TypeName psobject -Property $properties
                    Write-Output $obj

                } # end foreach-loop $share

                # remove $data variable for next computer
                Remove-Variable $data

            } # end if statement

        } # end foreach-loop $computer

    } # end PROCESS block

    END {
        Write-Verbose "Queries complete"
    }

} # end function

Get-RemoteSmbShare -LogErrors