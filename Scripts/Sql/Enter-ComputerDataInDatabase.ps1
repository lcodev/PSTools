# first use invoke-databasequery to insert computer names into database
$connstr = 'server=hn1;database=inventory;trusted_connection=true'

# prompt user for ou path
$oupath = Read-Host "enter OU path"

$systems = Get-ADComputer -Filter * -SearchBase $oupath | Select-Object -ExpandProperty name 

foreach ($system in $systems) {
    $sqlInsert = "INSERT INTO systems (computername) VALUES ('$system')"
    Invoke-DatabaseQuery -ConnectionString $connstr -mssql -query $sqlInsert

    # populate data
    Get-SystemData -ComputerName $system -LogErrors | Set-InventoryInDatabase
}