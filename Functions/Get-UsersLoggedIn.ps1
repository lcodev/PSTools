# -------------------------------------------------------
# Function Name: Get-UsersLoggedIn
# Return the current logged-in users of a remote system
# -------------------------------------------------------
function Get-UsersLoggedIn {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$True)]
        [string[]]
        $ComputerName
    )
    
    foreach ($computer in $ComputerName) {
        $logged_in = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer).username
        $name = $logged_in.split("\")[1]
        "{0}: {1}" -f $computer, $name
    }
}