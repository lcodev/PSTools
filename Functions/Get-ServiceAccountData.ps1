function Get-ServiceAccountData {

<#
    .SYNOPSIS
    Tool retrieves service account expiration date and the
    last time the password was set.

    .DESCRIPTION
    Get-ServiceAccountData uses Get-ADUser cmdlet to retrieve
    data from service accounts. The data retrieved includes
    account expiration date and last password reset.

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
    param (
        # Parameter help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Username,
        [string]$ErrorLog = 'C:\retry.txt',
        [switch]$LogErrors
    )

    process {
        Write-Verbose -Message "Beginning PROCESS block"
        foreach ($user in $Username) {

            # Check if service account exists
            try {
                $pass = $true
                $data = Get-ADUser -Identity $user -Properties * -ErrorAction Stop
            }
            catch {
                if ($LogErrorss) {
                    Write-Warning -Message "Could not get $user data"
                    $pass = $false
                    $user | Out-File $ErrorLog -Append
                    Write-Warning -Message "Error will be logged to $ErrorLog"
                }

            } # end try-catch statement

            # Account exists. Process data
            if ($pass) {
                # hash table for data
                $properties = @{
                    ServiceAccount        = $data.Name
                    AccountExpirationDate = $data.AccountExpirationDate
                    PasswordLastSet       = $data.PasswordLastSet
                    Enabled               = $data.Enabled
                }

                # custom output object
                $obj = New-Object -TypeName psobject -Property $properties
                $obj.psobject.TypeName.Insert(0, 'LCO.ServiceAccountData')
                Write-Output $obj
            }

        } # end foreach-loop $user

    } # end PROCESS block

} # end function