function Get-PSDownloadCount {
    param (
        [string]$Uri = "api.github.com/repos/PowerShell/PowerShell/releases"
    )

    # Set security protocol to Tls12
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Get Downloads from API
    $data = Invoke-RestMethod -Uri $Uri
    $data[0].Assets | Sort-Object -Descending download_count | Format-Table name, download_count

}

Get-PSDownloadCount