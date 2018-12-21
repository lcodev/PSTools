# Implement your module commands in this script.
function Get-GitIssueComment {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter()]
        [string]
        $Owner = "PowerShell",

        # Parameter help description
        [Parameter()]
        [string]
        $Repo = "PowerShell-RFC",

        # Parameter help description
        [Parameter(Mandatory = 1)]
        [int]
        $Issue
    )

    # Set security protocol to Tls12
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $uri = "https://api.github.com/repos/$Owner/$Repo/issues/$issue/comments?per_page=100"
    Write-Verbose "URI = $uri"
    Invoke-RestMethod -Uri $uri | Write-Output

}

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

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
