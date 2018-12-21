function Get-SystemInfo {
    
    [CmdletBinding()]

    param (
        
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        [string]$ErrorLog = 'c:\retry.txt'
    )

    BEGIN {
        
        Write-Debug "Log name is $ErrorLog"
    }
    PROCESS {
        
        foreach ($computer in $ComputerName) {
            
            $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer
            $cs = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer
            $bios = Get-WmiObject -Class Win32_BIOS -ComputerName $computer

            $properties = @{
                ComputerName = $cs.name 
                OSVersion    = $os.version
                SPVersion    = $os.servicepackmajorversion
                BIOSSerial   = $bios.serialnumber
                Manufacturer = $cs.manufacturer
                Model        = $cs.model
            }

            $obj = New-Object -TypeName psobject -Property $properties
            Write-Output $obj
        }
    }
    END {

    }
}

# Test function
Get-SystemInfo 