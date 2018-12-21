function Set-ServicePassword {

<#
    .SYNOPSIS
    Tool used to set or change a service password and/or
    account service account a service runs as.

    .DESCRIPTION
    Set-ServicePassword uses Windows Management Instrumentation (WMI)
    to set the password for a windows service. User can specify
    Computer, Service, Service account and password.

    .PARAMETER ComputerName
    One or more computer names or IP addresses.

    .PARAMETER ServiceName
    Name of the windows service.

    .PARAMETER ServiceAccount
    Name of the service account the service will run as.

    .EXAMPLE
    Set-ServicePassword -ComputerName SERVER1, -ServiceName BITS -ServiceAccount SVC -NewPassword *******
#>

    [CmdletBinding(SupportsShouldProcess=$true,
                   ConfirmImpact='Medium')]
    
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string]$ServiceName,

        [string]$ServiceAccount,

        [Parameter(Mandatory=$true)]
        [SecureString]$NewPassword
    )

    PROCESS {
        foreach ($computer in $ComputerName) {
            $svcs = Get-WmiObject -Class Win32_Service -ComputerName $computer -Filter "name='$ServiceName'"

            foreach ($svc in $svcs) {
                if ($PSCmdlet.ShouldProcess("$svc on $computer")) {
                    $svc.Change($null,
                                $null,
                                $null,
                                $null,
                                $null,
                                $null,
                                $ServiceAccount,
                                $NewPassword) | Out-Null
                } # end if statement

            } # end foreach-loop $svc

        } # end foreach-loop $computer

    } # end PROCESS block

} # end function

Set-ServicePassword -ComputerName sql2 -ServiceName bits -ServiceAccount lco\svc_splunk