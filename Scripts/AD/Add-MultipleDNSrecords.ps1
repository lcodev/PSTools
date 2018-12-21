$zone = 'lco.net'
$dc = 'dc'
$start = 1
10..20 | ForEach-Object {
    Add-DnsServerResourceRecordA -ZoneName $zone -Name "srv$start-test" -IPv4Address 10.1.10.$_ -CreatePtr -ComputerName $dc
    $start++
}