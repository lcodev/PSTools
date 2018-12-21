[int]$subnet = Read-Host "enter subnet"

1..254 | ForEach-Object {
    if (!(Resolve-DnsName 10.0.$subnet.$_ -ErrorAction SilentlyContinue)) {
        Write-Output "10.0.$subnet.$_ available"
    }
}