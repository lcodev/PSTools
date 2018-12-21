function Get-ComputerNamesFromDatabase {
    <#
    .SYNOPSIS
    Reads computer names from the APL sample database,
    placing them into the pipeline as strings.
    #>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory = $true)]
        [string]$Query
    )

    Get-DatabaseData -ConnectionString $APLConnectionString -mssql -query $Query

} # end function