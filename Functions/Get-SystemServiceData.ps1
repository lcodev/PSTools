function Get-SystemServiceData {

<#
	.SYNOPSIS
	Tool retrieves service and process information from one to
	ten computers.

	.DESCRIPTION
	Get-APLSystemServiceData uses Common Information Module (CIM) Instance
	to retrieve running service information and its associated 
	process. The data returned includes service name, process ID,
	virtual size, peak page file usage, and thread count.

	.PARAMETER ComputerName
	One or more computer names or IP addresses, up to a maximum of 10.

	.PARAMETER LogErrors
	Specify this switch to create a text log file of computers that could
	not be queried.

	.PARAMETER ErrorLog
	When used with -LogErrors, specifies the file path and name to which 
	failed computer names will be written. Defaults to C:\Retry.txt

	.EXAMPLE 
	Get-APLSystemServiceData -ComputerName SERVER1, SERVER2

	.EXAMPLE
	Get-Content servers.txt | Get-APLSystemServiceData
#>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   HelpMessage = "Computer name or IP address")]
        [Alias("Hostname")]
        [string[]]$ComputerName,
        [string]$ErrorLog = $ErrorActionPreference,
        [switch]$LogErrors
    )

    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
    }

    PROCESS {
        Write-Verbose "Beginning PROCESS block"

        foreach ($computer in $ComputerName) {
            Write-Verbose "Querying $computer"

            # Check for online systems
            try {
                $everything_ok = $true
                $services = Get-CimInstance -ClassName Win32_Service -ComputerName $computer -Filter "State = 'Running'" -ErrorAction Stop
            } catch {
                if ($LogErrors) {
                    Write-Warning -Message "$computer did not respond"
                    $everything_ok = $false 
                    $computer | Out-File $ErrorLog -Append
                    Write-Warning -Message "Errors logged in $ErrorLog"
                }
            }

            # Systems online. Continue processing
            if ($everything_ok) {
                foreach ($service in $services) {

                    # Hash table for data
                    $properties = @{
                        ComputerName = $computer
                        Service      = $service.Name
                        DisplayName  = $service.DisplayName
                    }
    
                    # Get services corresponding process data
                    $process = Get-CimInstance -ClassName Win32_Process -ComputerName $computer -Filter "ProcessID = '$($service.ProcessID)'"
                    
                    # adding process data to hash table
                    $properties.Add('ProcessName', $process.ProcessName)
                    $properties.Add('ProcessID', $process.ProcessId)
                    $properties.Add('VMSize', $process.VM)
                    $properties.Add('ThreadCount', $process.ThreadCount)
                    $properties.Add('PeakPageFile', $process.PeakPageFileUsage)
    
                     # creating custom output object
                    $object = New-Object -TypeName psobject -Property $properties
                    $object.psobject.TypeNames.Insert(0, 'APL.ServiceData')
                    Write-Output $object
    
                } # end foreach-loop $service

            } # end if statement
            
        } # end foreach-loop $computer

    } # end PROCESS block

    END {
        Write-Verbose "CIM queries complete"
    }

} # end function
Get-SystemServiceData -LogErrors