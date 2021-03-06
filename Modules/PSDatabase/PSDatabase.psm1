function Get-DatabaseData {

    <#
    .SYNOPSIS
    Advanced PowerShell function used to connect to a remote or local database,
    and retrieve data in the form of a dataset. Function only works by using 
    SQL SELECT statements.

    .EXAMPLE
    Get-APLDatabaseData -connectionString "server=localhost;database=mydata;trusted_connection=true" 
                        -mssql
                        -query "SELECT object_id FROM objects"
    #>

    [CmdletBinding()]

    param(
        [string]$ConnectionString,
        [string]$query,
        [switch]$mssql
    )

    if ($mssql) {
        Write-Verbose "In MSSQL server mode"
        $Connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    } else {
        Write-Verbose "in oleDB mode"
        $Connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }

    $connection.ConnectionString = $ConnectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query

    if ($mssql) {
        $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    } else {
        $adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command 
    }

    $dataset = New-Object -TypeName System.Data.DataSet
    $adapter.Fill($dataset)
    $dataset.Tables[0]
    $connection.close()

} # end function

function Invoke-DatabaseQuery {

    <#
    .SYNOPSIS
    Advanced PowerShell function used to perform Data Definition Language (DDL), and
    Data Manipulation Language (DML) statements on a local or remote database.

    .EXAMPLE
    Invoke-DatabaseQuery -connectionString "server=localhost;database=mydata;trusted_connection=true" 
                         -mssql
                         -query "INSERT INTO table (col1, col2) VALUES ('val1', 'val2')" 
    #>

    [CmdletBinding(SupportsShouldProcess = $true,
                   ConfirmImpact = 'Low')]

    param(
        [string]$ConnectionString,
        [string]$query,
        [switch]$mssql
    )

    if ($mssql) {
        Write-Verbose "In MSSQL server mode"
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    } else {
        Write-Verbose "In oleDB mode"
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection 
    }

    $connection.ConnectionString = $ConnectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query

    if ($PSCmdlet.ShouldProcess($query)) {
        $connection.Open()
        $command.ExecuteNonQuery()
        $connection.Close()
    }

} # End function