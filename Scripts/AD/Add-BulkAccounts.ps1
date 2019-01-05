# Import csv file with account data
$filepath = Read-Host "enter file path"
Import-Csv -Path $filepath | ForEach-Object {

    # Prepare account parameters
    $params = @{
        GivenName           = $_.Givenname
        Surname             = $_.Surname
        Initials            = $_.Initials
        Name                = $_.Name
        DisplayName         = $_.DisplayName
        SamAccountName      = $_.SamAccountName
        UserPrincipalName   = $_.UserPrincipalName
        EmployeeId          = $_.EmployeeId
        Title               = $_.Title
        Office              = $_.Office
        OfficePhone         = $_.OfficePhone
        Department          = $_.Department
        Company             = $_.Company
        EmailAddress        = $_.EmailAddress
    }

    # Create accounts using parameters
    New-ADUser @params
    Start-Sleep -Seconds 3
    $user = Get-ADUser -Identity $_.samaccountname | Select-Object -ExpandProperty samaccountname
    Write-Output "Account $user created"
}