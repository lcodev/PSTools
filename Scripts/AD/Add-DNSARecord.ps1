$zonename = 'lco.net'
$dc = 'dc'
$name = Read-Host 'enter dns record name'
$ip = Read-Host 'enter ip address'

Add-DnsServerResourceRecordA -ZoneName $zonename -Name $name -IPv4Address $ip -CreatePtr -ComputerName $dc