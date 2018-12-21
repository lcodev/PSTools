function Set-ComputerState {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]

    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Logoff", "Shutdown", "Restart", "Poweroff")]
        [string]$Action,
        [switch]$Force
    )

    BEGIN {
        Write-Verbose "Starting Set-ComputerState"

        # Set the state value
        switch ($Action) {
            "Logoff"    { $Flag = 0 }
            "Shutdown"  { $Flag = 1 }
            "Restart"   { $Flag = 2 }
            "Poweroff"  { $Flag = 8 }
        }

        if ($Force) {
            Write-Verbose "Flag enabled"
            $Flag += 4
        }

    } # end BEGIN block

    PROCESS {
        Write-Verbose "Beginning PROCESS block"

        foreach ($computer in $ComputerName) {
            Write-Verbose "Processing $computer"
            $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer

            if ($PSCmdlet.ShouldProcess($computer)) {
                Write-Verbose "Passing flag $flag"
                $os.Win32Shutdown($Flag)
            }

        } # end foreach-loop $computer

    } # end PROCESS block

    END {
        Write-Verbose "Ending Set-ComputerState"
    }

} # end function

Set-ComputerState -ComputerName sql1 -Action Logoff -Force -WhatIf -Verbose