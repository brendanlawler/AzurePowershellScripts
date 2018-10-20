$rsgnet = "WEU-RSG-NET"
$rsgagw = "WEU-RSG-AGW"
$rsgweb = "WEU-RSG-WEB"
$vnetname = "WEU-VNET-01"
$agwname = "WEU-AGW-01"
$Location1 = "West Europe"

#Create RSG
#New-AzureRmResourceGroup -Name $rsgagw -Location $Location1

Create PIP
New-AzureRmPublicIpAddress `
  -ResourceGroupName $rsgagw `
  -Location $Location1 `
  -Name $agwname-pip `
  -AllocationMethod Dynamic


#Create AGW
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rsgnet -Name $vnetname
$pip = Get-AzureRmPublicIPAddress -ResourceGroupName $rsgagw -Name $agwname-pip
$subnet=$vnet.Subnets[1]
$gipconfig = New-AzureRmApplicationGatewayIPConfiguration `
  -Name myAGIPConfig `
  -Subnet $subnet
$fipconfig = New-AzureRmApplicationGatewayFrontendIPConfig `
  -Name myAGFrontendIPConfig `
  -PublicIPAddress $pip
$frontendport = New-AzureRmApplicationGatewayFrontendPort `
  -Name myFrontendPort `
  -Port 80

$address1 = Get-AzureRmNetworkInterface -ResourceGroupName $rsgweb -Name myNic1
$address2 = Get-AzureRmNetworkInterface -ResourceGroupName $rsgweb -Name myNic2
$backendPool = New-AzureRmApplicationGatewayBackendAddressPool `
  -Name BackendPool-01 `
  -BackendIPAddresses $address1.ipconfigurations[0].privateipaddress, $address2.ipconfigurations[0].privateipaddress
$poolSettings = New-AzureRmApplicationGatewayBackendHttpSettings `
  -Name myPoolSettings `
  -Port 80 `
  -Protocol Http `
  -CookieBasedAffinity Enabled `
  -RequestTimeout 120

  $defaultlistener = New-AzureRmApplicationGatewayHttpListener `
  -Name myAGListener `
  -Protocol Http `
  -FrontendIPConfiguration $fipconfig `
  -FrontendPort $frontendport
$frontendRule = New-AzureRmApplicationGatewayRequestRoutingRule `
  -Name rule1 `
  -RuleType Basic `
  -HttpListener $defaultlistener `
  -BackendAddressPool $backendPool `
  -BackendHttpSettings $poolSettings

  $sku = New-AzureRmApplicationGatewaySku `
  -Name Standard_Small `
  -Tier Standard `
  -Capacity 2 
New-AzureRmApplicationGateway `
  -Name $agwname `
  -ResourceGroupName $rsgagw `
  -Location $Location1 `
  -BackendAddressPools $backendPool `
  -BackendHttpSettingsCollection $poolSettings `
  -FrontendIpConfigurations $fipconfig `
  -GatewayIpConfigurations $gipconfig `
  -FrontendPorts $frontendport `
  -HttpListeners $defaultlistener `
  -RequestRoutingRules $frontendRule `
  -Sku $sku