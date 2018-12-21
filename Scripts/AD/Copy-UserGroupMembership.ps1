$source = Read-Host 'enter source username'
$destination = Read-Host 'enter destination username'

$groups = Get-ADPrincipalGroupMembership -Identity $source | Select-Object -ExpandProperty name

foreach ($group in $groups) {
    Add-ADGroupMember -Identity $group -Members $destination
}