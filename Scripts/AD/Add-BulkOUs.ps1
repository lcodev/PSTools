# retrieve content from OU text file
$labs = Get-Content labs.txt
$root_path = "DC=lco,DC=net"

# iterate through each lab and create container for users
foreach ($lab in $labs) {
    New-ADOrganizationalUnit -Name "$lab-Users" -Path "OUT=$lab,$root_path"
}