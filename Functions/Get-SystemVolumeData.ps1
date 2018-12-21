function Get-SystemVolumeData {

<#
	.SYNOPSIS
	Tool retrieves local disk volume information from one to ten computers.

	.DESCRIPTION
	Get-APLSystemVolumeData uses Common Information Module (CIM) Instance
	to retrieve specific local disk volume information, which includes
	volume letter, size and freespace.

	.PARAMETER ComputerName
	One or more computer names or IP addresses, up to a maximum of 10.

	.PARAMETER LogErrors
	Specify this switch to create a text log file of computers that could
	not be queried.

	.PARAMETER ErrorLog
	When used with -LogErrors, specifies the file path and name to which 
	failed computer names will be written. Defaults to C:\Retry.txt

	.EXAMPLE
	Get-APLSystemVolumeData -ComputerName SERVER1, SERVER2

	.EXAMPLE
	Get-Content servers.txt | Get-APLSystemVolumeData
#>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   HelpMessage = "Computer name or IP address")]
        [Alias("Hostname")]
        [string[]]$ComputerName,
        [string]$ErrorLog = 'D:\retry.txt',
        [switch]$LogErrors
    )

    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
    }

    PROCESS {
        Write-Verbose "Beginning PROCES block" 

        foreach ($computer in $ComputerName) {
            Write-Verbose "Querying $computer"

            # test for online systens
            try {
                $passtest = $true
                # extract only local disk data
                $data = Get-CimInstance -ClassName Win32_Volume -ComputerName $computer -Filter "DriveType = 3" -ErrorAction Stop
            }
            catch {
                if ($LogErrors) {
                    Write-Warning -Message "$computer did not respond"
                    $passtest = $false
                    $computer | Out-File $ErrorLog -Append
                    Write-Warning -Message "Errors logged to $ErrorLog"
                }
            } # end try-catch block

            if ($passtest) {
                foreach ($drive in $data) {
                    # format size and freespace to two decimal places in GB
                    $size = "{0:N2}" -f ($drive.Capacity / 1GB) + " GB"
                    $freespace = "{0:N2}" -f ($drive.freespace / 1GB) + " GB"

                    # hash table for data
                    $properties = @{
                        ComputerName = $computer
                        Drive        = $drive.name
                        Size         = $size
                        Freespace    = $freespace
                    }

                    # Custom output object
                    $object = New-Object -TypeName psobject -Property $properties
                    $object.psobject.TypeNames.Insert(0, 'APL.SystemVolumeData')
                    Write-Output $object

                } # end foreach-loop $drive

                # remove $data variable for next computer
                Remove-Variable -Name data 

            } # end if statement

        } # end foreach-loop $computer

    } # end PROCESS block

    END {
        Write-Verbose "CIM queries completed"
    }

} # end function

Get-SystemVolumeData -LogErrors