function RemoteConnector
{
    param(
        [Parameter()]
        $ComputerName,
        [Parameter(Mandatory = $true)]
        $Credential
    )

    "Connecting as " + $Credential.UserName
}