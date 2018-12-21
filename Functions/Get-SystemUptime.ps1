# ---------------------------------------------------------------
# Function Name: Get-SystemUptime
# Calculate and display system uptime on a local or remote system
# ---------------------------------------------------------------
function Get-SystemUptime {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [switch[]]
        $ComputerName
    )
    
    foreach ($computer in $ComputerName) {
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer
        $diff = $os.ConvertToDateTime($os.LocalDateTime) - $os.ConvertToDateTime($os.LastBootUpTime)

        $properties = @{
            ComputerName  = $computer
            UptimeDays    = $diff.Days 
            UptimeHours   = $diff.Hours
            UptimeMinutes = $diff.Minutes 
            UptimeSeconds = $diff.Seconds
        }

        # create custom output object
        $obj = New-Object -TypeName psobject -Property $properties
        Write-Output $obj
    }
}