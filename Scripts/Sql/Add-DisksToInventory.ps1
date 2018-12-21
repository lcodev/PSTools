<#
    .SYNOPSIS
    Tool used to add disk drives into the Inventory database.
#>
$filepath = Read-Host 'enter file path'
$computers = Get-Content $filepath

foreach ($computer in $computers) {
    $connectionString = "server=sql-csv;database=inventory;trusted_connection=true"
    $obj = Get-DiskDriveData -ComputerName server1
    $computername = $obj.ComputerName
    $model = $obj.Model
    $serial = $obj.Serial
    $sqlquery = "INSERT INTO disks VALUES ('$computername', '$model', '$serial')"

    Invoke-DatabaseQuery -ConnectionString $connectionString -mssql -query $sqlquery
}