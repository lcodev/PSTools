$control = Read-Host "Are you querying a single host? yes/no"

if ($control -eq 'yes') {
    $system = Read-Host 'enter system name'
    Invoke-Command -ScriptBlock {
        Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL12\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\' | Select-Object -Property tcpdynamicports
    } -ComputerName $system
}

else {
    $list = Read-Host 'enter path to the list of hosts'
    $systems = Get-Content $list

    foreach ($system in $systems) {
        Invoke-Command -ScriptBlock {
            Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL12\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\' | Select-Object -Property tcpdynamicports
        } -ComputerName $system
    }
}