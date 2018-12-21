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
            $query = "UPDATE computers SET
                       biosserial = '$($obj.BIOSSerial)',
                       manufacturer = '$($obj.Manufacturer)',
                       model = '$($obj.Model)',
                       osname = '$($obj.OSName)',
                       osversion = '$($obj.OSVersion)',
                       spversion = '$($obj.SPVersion)',
                       adminpass = '$($obj.AdminPass)'
                       WHERE computername = '$($obj.computername)'"

            Write-Verbose "Query will be $query"

            Invoke-DatabaseQuery -ConnectionString $ConnectionString -mssql -query $query

        } # end foreach-loop

    } # end PROCESS block

} # end function