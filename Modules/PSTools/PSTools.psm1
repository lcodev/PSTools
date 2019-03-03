$ErrorLogPreference = "D:\FunctionLogs\ErrorLog.txt"
$ConnectionString = "server=lco-sql1;database=inventory;user id=sa;password=B33b0p@!"

Import-Module PSDatabase

function Get-ComputerNamesFromDatabase {
    <#
    .SYNOPSIS
    Reads computer names from the APL sample database,
    placing them into the pipeline as strings.
    #>

    [CmdletBinding()]

    param(
        [Parameter()]
        [string]$Query = "SELECT computername FROM lco_servers"
    )

    Get-DatabaseData -ConnectionString $ConnectionString -mssql -query $Query

} # end function

function Set-InventoryInDatabase {

    <#
    .SYNOPSIS
    Accepts the output of Get-SystemData and saves
    the results back to the inventory database.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [object[]]$InputObject
    )

    PROCESS {
        foreach ($obj in $InputObject) {
            $query = "UPDATE lco_servers SET
                       biosserial = '$($obj.BIOSSerial)',
                       manufacturer = '$($obj.Manufacturer)',
                       model = '$($obj.Model)',
                       osname = '$($obj.OSName)',
                       osversion = '$($obj.OSVersion)',
                       spversion = '$($obj.SPVersion)',
                       totalram = '$($obj.TotalRAM)',
                       processors = '$($obj.Processors)',
                       lprocessors = '$($obj.LProcessors)'
                       WHERE computername = '$($obj.computername)'"

            Write-Verbose "Query will be $query"

            Invoke-DatabaseQuery -ConnectionString $ConnectionString -mssql -query $query

        } # end foreach-loop

    } # end PROCESS block

} # end function

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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias("Hostname")]
        [string[]]$ComputerName,

        [System.Management.Automation.PSCredential]$Credential,

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
            $cim = New-CimSession -ComputerName $computer -Credential $Credential
        
            # Test for online systems
            try {
                $everything_ok = $true
                $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $cim -ErrorAction Stop
            }
            catch {
                if ($LogErrors) {
                    Write-Warning -Message "$computer did not respond"
                    $everything_ok = $false
                    $computer | Out-File $ErrorLog -Append
                    Write-Warning -Message "Errors logged in $ErrorLog"
                }
            }
        
            # Systems online. Continue processing
            if ($everything_ok) {
                $cs = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $cim
                $bios = Get-CimInstance -ClassName Win32_BIOS -CimSession $cim
    
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
                $object.PSObject.TypeNames.Insert(0, 'LCO.SystemData')
                Write-Output $object
        
            } # end if-statement
        
            Remove-CimSession $cim
        } # end foreach-loop $computer
    
    } # end PROCESS block
        
    END {
        Write-Verbose "CIM queries complete"
    }
    
} # end function

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

        [System.Management.Automation.PSCredential]$Credential,

        [string]$ErrorLog = $ErrorLogPreference,

        [switch]$LogErrors
    )
    
    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
    }
    
    PROCESS {
        Write-Verbose "Beginning PROCES block" 
    
        foreach ($computer in $ComputerName) {
            Write-Verbose "Querying $computer"
            $cim = New-CimSession -ComputerName $computer -Credential $Credential
    
            # test for online systens
            try {
                $passtest = $true
                # extract only local disk data
                $data = Get-CimInstance -ClassName Win32_Volume -CimSession $cim -Filter "DriveType = 3" -ErrorAction Stop |
                    Where-Object {$_.Name -notlike '\\?*'}
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
                    $object.psobject.TypeNames.Insert(1, 'LCO.VolumeData')
                    Write-Output $object
    
                } # end foreach-loop $drive
    
                # remove $data variable for next computer
                Remove-Variable -Name data 
    
            } # end if statement
    
            Remove-CimSession $cim
        } # end foreach-loop $computer
    
    } # end PROCESS block
    
    END {
        Write-Verbose "CIM queries completed"
    }
    
} # end function

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

        [System.Management.Automation.PSCredential]$Credential,

        [string]$ErrorLog = $ErrorLogPreference,

        [switch]$LogErrors
    )
    
    BEGIN {
        Write-Verbose "Error log will be $ErrorLog"
    }
    
    PROCESS {
        Write-Verbose "Beginning PROCESS block"
    
        foreach ($computer in $ComputerName) {
            Write-Verbose "Querying $computer"
            $cim = New-CimSession -ComputerName $computer -Credential $Credential
    
            # Check for online systems
            try {
                $everything_ok = $true
                $services = Get-CimInstance -ClassName Win32_Service -CimSession $cim -Filter "State = 'Running'" -ErrorAction Stop
            }
            catch {
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
                    $process = Get-CimInstance -ClassName Win32_Process -CimSession $cim -Filter "ProcessID = '$($service.ProcessID)'"
                        
                    # adding process data to hash table
                    $properties.Add('ProcessName', $process.ProcessName)
                    $properties.Add('ProcessID', $process.ProcessId)
                    $properties.Add('VMSize', $process.VM)
                    $properties.Add('ThreadCount', $process.ThreadCount)
                    $properties.Add('PeakPageFile', $process.PeakPageFileUsage)
        
                    # creating custom output object
                    $object = New-Object -TypeName psobject -Property $properties
                    $object.psobject.TypeNames.Insert(0, 'LCO.ServiceData')
                    Write-Output $object
        
                } # end foreach-loop $service
    
            } # end if statement
                
            Remove-CimSession $cim
        } # end foreach-loop $computer
    
    } # end PROCESS block
    
    END {
        Write-Verbose "CIM queries complete"
    }
    
} # end function

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
    
    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium')]
        
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string[]]$ComputerName,
    
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
    
        [string]$ServiceAccount,
    
        [Parameter(Mandatory = $true)]
        [SecureString]$NewPassword
    )
    
    PROCESS {
        foreach ($computer in $ComputerName) {
            $svcs = Get-CimInstance -ClassName Win32_Service -ComputerName $computer -Filter "name='$ServiceName'"
    
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

function Set-ComputerState {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]

    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Logoff", "Shutdown", "Restart", "Poweroff")]
        [string]$Action,
        [switch]$Force
    )

    BEGIN {
        Write-Verbose "Starting Set-ComputerState"

        # Set the state value
        switch ($Action) {
            "Logoff" { $Flag = 0 }
            "Shutdown" { $Flag = 1 }
            "Restart" { $Flag = 2 }
            "Poweroff" { $Flag = 8 }
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
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer

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

function Get-RemoteSmbShare {

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
        [string[]]$ComputerName,

        [System.Management.Automation.PSCredential]$Credential,

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
                $data = Invoke-Command -ScriptBlock { 
                            Get-SmbShare 
                        } -ComputerName $computer -Credential $Credential -ErrorAction Stop
            }
            catch {
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

# Export preference variable and all functions
Export-ModuleMember -Variable ErrorLogPreference
Export-ModuleMember -Function *-*
