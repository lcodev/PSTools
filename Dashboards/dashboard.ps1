$dashboard = New-UDDashboard -Title "Processes" -Content {
    New-UDChart -Title "Process Memory" -Endpoint {
        Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 | Out-UDChartData -DataProperty "WorkingSet" -LabelProperty "Name"
    }
}

Start-UDDashboard -Dashboard $dashboard -Port 10002 -AutoReload