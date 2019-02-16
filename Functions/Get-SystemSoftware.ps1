function Get-SystemSoftware {

    <#
    .SYNOPSIS
    Script retrives software list from a system.
    
    .DESCRIPTION
    Get-SystemSoftware uses Get-ItemProperty to query a system or group 
    of systems registry and return a collection of software applications
    that are installed on the system. 
    
    .PARAMETER ComputerName
    One or more computer names or IP addresses to collect software from.
    
    .PARAMETER LogErrors
    Specify this switch to create a text log file of computers that could
    not be queried.
    
    .PARAMETER ErrorLog
    When used with -LogErrors, specifies the file path and name to which 
    failed computer names will be written. Defaults to C:\Retry.txt
    
    .EXAMPLE 
    Get-Content names.txt | Get-SystemSoftware
    
    .EXAMPLE
    Get-SystemSoftware -ComputerName SERVER1, SERVER2
        
    #>
    
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]
        $ComputerName,

        [string]$ErrorLog = $ErrorLogPreference,

        [switch]$LogErrors
    )
    
    begin { Write-Verbose -Message "Starting software collection...." }

    process {
        foreach ($Computer in $ComputerName) {
            Write-Verbose -Message "Querying $Computer"
    
            try {
                $pass = $true
                $apps = Invoke-Command -ScriptBlock {
                    Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                    Where-Object {$null -ne $_.DisplayName}
                } -ComputerName $Computer -Credential $admin -ErrorAction Stop
            }
            catch {
                if ($LogErrors) {
                    Write-Warning -Message "$Computer did not respond."
                    $Computer | Out-File -FilePath $ErrorLog -Append
                    $pass = $false
                    Write-Warning -Message "System name logged at $ErrorLog"
                }
            }
    
            # Computer online. Process data
            if ($pass) {
                # Iterate through each app
                foreach ($app in $apps) {
                    $props = @{
                        ComputerName = $Computer
                        DisplayName  = $app.DisplayName
                        Version      = $app.DisplayVersion
                        InstallDate  = $app.InstallDate
                    }
    
                    # Custom output object
                    $obj = New-Object -TypeName psobject -Property $props
                    Write-Output -InputObject $obj
    
                    # Remove app variable for next computer
                    Remove-Variable -Name app
    
                } # end foreach-loop $apps
    
            } # end if-statement
    
        } # end foreach-loop $Computer

    } # end process block

    end { Write-Verbose "Queries completed" }

} # end function

Get-SystemSoftware -Verbose