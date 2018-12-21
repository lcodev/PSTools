Function Get-SystemData {

<#
    .SYNOPSIS
    Retrieves key system version and model information
    from one to ten computers.
    
    .DESCRIPTION
    Get-SystemData uses Common Information Module (CIM) Instance
    to retrieve information from one to ten computers.
    Specify computers by name of by IP address.
    
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
    
    param(
        [Parameter(Mandatory = $true)]
        [Alias("Hostname")]
        [string[]]$ComputerName,
        [string]$ErrorLog,
        [switch]$LogErrors
    )
    
    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
    }
    
    PROCESS {
        Write-Verbose "Beginning PROCESS block"
    
        foreach ($computer in $ComputerName) {
            Write-Verbose "Querying $computer"
    
            # Test for online systems
            try {
                $everything_ok = $true
                $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
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
                $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $computer
                $bios = Get-CimInstance -ClassName Win32_BIOS -ComputerName $computer

                # Get total physical memory
                $totalram = "{0:N2}" -f ($cs.TotalPhysicalMemory / 1GB) + " GB"
    
                # Hash table for data
                $properties = @{
                    ComputerName = $computer
                    BIOSSerial   = $bios.SerialNumber
                    Manufacturer = $cs.Manufacturer
                    Model        = $cs.Model
                    OSName       = $os.Caption
                    OSVersion    = $os.Version
                    SPVersion    = $os.ServicePackMajorVersion
                    TotalRAM     = $totalram
                    Processors   = $cs.NumberOfProcessors
                    LProcessors  = $cs.NumberOfLogicalProcessors
                }
    
                Write-Verbose "CIM queries complete"
    
                # Custom object
                $object = New-Object -TypeName psobject -Property $properties
                $object.PSObject.TypeNames.Insert(0, 'APL.SystemData')
                Write-Output $object
    
            } # end if-statement
    
        } # end foreach-loop $computer

    } # end PROCESS block
    
    END {
        Write-Verbose "CIM queries complete"
    }

} # end function
Get-SystemData -LogErrors