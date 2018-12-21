# Get vlan list of IP addresses

# Prompt user for subnet
$subnet = Read-Host "enter subnet"

1..254 | ForEach-Object {
    if (!(Test-Connection 10.1.$subnet.$_ -ErrorAction SilentlyContinue)) {
        Write-Output "10.1.$subnet.$_ is available"
    }
}