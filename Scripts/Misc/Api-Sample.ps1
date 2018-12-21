# Set security protocol to Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$uri = "https://api.github.com/repos/PowerShell/PowerShell/releases"
$content = Invoke-WebRequest -Uri $uri

$content.ToString() | Select-String 'download_count'
Show-Object $content

$content = ((Invoke-WebRequest $uri).AllElements[3].Innertext | ConvertFrom-Json)[0].Assets
$content | Sort-Object download_count -Descending | Format-Table name, down*
"Total Downloads: $(($content | Measure-Object download_count -sum).Sum)"

# Use Invoke-RestMethod for APIs
$content = Invoke-RestMethod "api.github.com/repos/PowerShell/PowerShell/releases"
Show-Object $content
(irm $uri)[0].Assets | sort -d d* | ft n*,d*


# Splunk query API
$content = Invoke-WebRequest -Uri "https://github.com/splunk/splunk-reskit-powershell/issues"
Show-Object $content