$RG1         = "WEU-RSG-NET"
$VNet1       = "WEU-VNET-01"
$Location1   = "West Europe"
$subnet01   = "WEU-RSG-NET-DMZ"
$subnet02   = "WEU-RSG-NET-AGW"
$subnet03   = "WEU-RSG-NET-Frontend"
$subnet04   = "WEU-RSG-NET-Backend"
$GwSubnet1   = "GatewaySubnet"
$VNet1Prefix = "10.1.0.0/16"
$subnet01Prefix   = "10.1.0.0/24"
$subnet02Prefix   = "10.1.1.0/24"
$subnet03Prefix   = "10.1.2.0/24"
$subnet04Prefix   = "10.1.3.0/24"
$GwPrefix1   = "10.1.255.0/27"

New-AzureRmResourceGroup -Name $RG1 -Location $Location1

$sub01 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnet01 -AddressPrefix $subnet01Prefix
$sub02 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnet02 -AddressPrefix $subnet02Prefix
$sub03 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnet03 -AddressPrefix $subnet03Prefix
$sub04 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnet04 -AddressPrefix $subnet04Prefix
$gwsub1 = New-AzureRmVirtualNetworkSubnetConfig -Name $GWSubnet1 -AddressPrefix $GwPrefix1
New-AzureRmVirtualNetwork `
            -Name $VNet1 `
            -ResourceGroupName $RG1 `
            -Location $Location1 `
            -AddressPrefix $VNet1Prefix `
            -Subnet $sub01,$sub02,$sub03,$sub04,$gwsub1