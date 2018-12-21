New-AzureRmResourceGroup -Name LCONET2 -Location eastus
New-AzureRmVirtualNetwork -ResourceGroupName LCONET2 -Name VNet2 -AddressPrefix 192.168.0.0/16 -Location eastus
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName LCONET2 -Name VNet2
Add-AzureRmVirtualNetworkSubnetConfig -Name Subnet2 -VirtualNetwork $vnet -AddressPrefix 192.168.1.0/24
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet