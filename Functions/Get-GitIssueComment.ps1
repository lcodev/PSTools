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

    $uri = "https://api.github.com/repos/$Owner/$Repo/issues/$issue/comments?per_page=100"
    Write-Verbose "URI = $uri"
    $items = Invoke-RestMethod -Uri $uri
    foreach ($item in $items) {
        $item.pstypenames.Insert(0,"LCO.GitIssueComment")
        Write-Output $item
    }

}

Get-GitIssueComment
