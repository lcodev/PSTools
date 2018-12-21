# ---------------------------------------------------------------
# Function Name: Get-DriverData
# Retrieve driver information from a system
# ---------------------------------------------------------------
function Get-DriverData($computer, $name) {
    Get-WmiObject -Query "SELECT * FROM Win32_PnPSignedDriver WHERE DeviceName LIKE '%$name%'" -ComputerName $computer |
        Sort-Object -Property DeviceName |
        Select-Object @{Name="System";Expression={$_.__Server}}, DeviceName,
        @{Name="DriverDate";Expression={[System.Management.ManagementDateTimeconverter]::ToDateTime($_.DriverDate).ToString("MM/dd/yyyy")}}, DriverVersion
}