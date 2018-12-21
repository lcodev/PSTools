function Reset-AccountPassword {

<#
    .SYNOPSIS
    Reset a service or user account password

    .DESCRIPTION
    Function resets user account password. First, it checks the mandatory password entries
    to ensure that they match. If password entries do not match it keeps prompting user until they do.
    Once password entries are the same then the reset password process can begin. Last, a pop up window
    displays to the user that the process was successful on the account provided.

    .PARAMETER UserName
    User account that needs password reset.

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
        [Parameter(Mandatory=$true)]
        [string]
        $Username,
        [string]$ErrorLog = 'C:\retry.txt'
    )

    while ($true) {
        $pwd1 = Read-Host 'enter password' -AsSecureString
        $pwd2 = Read-Host 'confirm password' -AsSecureString

        $pwd1_text = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd1))
        $pwd2_text = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd2))

        if ($pwd1_text -eq $pwd2_text) {
            Set-ADAccountPassword -Identity $Username -NewPassword $pwd1
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("$Username password has been reset")
            break
        }
        else {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show('Password entries do not match. Try again')

        } # end if-else statement

    } # end while loop

} # end function