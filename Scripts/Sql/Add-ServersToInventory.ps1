$connstr = "server=sql-csv;database=inventory;trusted_connection=true"

# Get the server names that need to be added
$srv_file_path = Read-Host 'enter server list'
$srv_list = Get-Content $srv_file_path

# iterate through the list and add the names to the invetory database
foreach ($name in $srv_list) {
    $sqlstr = "INSERT INTO Servers (computername) VALUES ('$name')"
    try {
        $pass = $true
        Invoke-DatabaseQuery -ConnectionString $connstr -mssql -query $sqlstr -ErrorAction Stop
    }
    catch {
        Write-Warning -Message "$name could not be added to database"
    }

    if ($pass) {
        Get-SystemData -ComputerName $name | Set-InventoryInDatabase 
    }
}