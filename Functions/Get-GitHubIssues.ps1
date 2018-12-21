function Get-Issues
{
    param (
        [string]$Username,
        [string]$Repo,
        [ValidateRange(1, 100)]
        [int]$PerPage = 100
    )

    $body = @{
        per_page = $PerPage
    }

    # Set security protocol to Tls12
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $uri = "https://github.com/splunk/splunk-reskit-powershell/issues"
    while ($uri)
    {
        $response = Invoke-WebRequest -Uri $uri -Body $body
        $response.Content | ConvertTo-Json | Write-Output

        $uri = $null
        foreach ($link in $response.Headers.Link -split ',') {
            if ($link -match '\s*<(.*)>;\s+rel="next"') {
                $uri = $Matches[1]
            } # end if statement

        } # end foreach loop

    } # end while loop

} # end function

$issues = Get-Issues -Username lcodev -Repo PSTools

$issues.Count

$issues | Sort-Object -Descending comments | Select-Object -First 15 | Format-Table number, comments, title

foreach ($issue in $issues) {
    if ($issue.labels.name -contains 'bug' -and $issue.labels.name -contains 'vi mode') {
        "{0} is a vi mode bug" -f $issue.url
    }
}

"Done Processing"