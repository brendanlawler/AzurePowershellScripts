$rsgnet = "UKW-RSG-PRD-MGT"
$rsgagw = "UKW-RSG-PRD-SHR"
$rsgweb = "UKW-RSG-PRD-CLT5"
$vnetname = "UKW-VNET01"
$agwname = "UKW-SHR-AGW-TST01"
$subnet = "UKW-VNET01-AGW-PRD"
$Location1 = "UK West"

#My Variables
$rsgnet = "WEU-RSG-NET"
$rsgagw = "WEU-RSG-AGW"
$rsgweb = "WEU-RSG-WEB"
$vnetname = "WEU-VNET-01"
$agwname = "UKW-SHR-AGW-TST01"
$subnet = "WEU-RSG-NET-AGW"
$Location1 = "West Europe"


#Create PIP
New-AzureRmPublicIpAddress `
  -ResourceGroupName $rsgagw `
  -Location $Location1 `
  -Name $agwname-pip `
  -AllocationMethod Dynamic

$agw = $agwname

############################
### Add whitelist cert ###
############################
    $whitelistCertPath = "C:\Users\brendan.lawler\Desktop\Certs\aareon360.cer"
    $authcert01 = New-AzureRmApplicationGatewayAuthenticationCertificate -Name 'wildcard-aareon360-cer' -CertificateFile $whitelistCertPath

############################
## Add .pfx for listener ###
############################
#Certificate must be in pfx format
    $certDirectory1 = "C:\Users\brendan.lawler\Desktop\Certs\aareon360.pfx"

#Certificate password must be between 4 to 12 characters.
    $certName1 = "wildcard-aareon360-pfx"
    $certPassword1 = ConvertTo-SecureString A@reon –asplaintext –force
    $cert01 = New-AzureRmApplicationGatewaySslCertificate -Name $certName1 -CertificateFile $certDirectory1 -Password $certPassword1

##############
#Configure AGW
##############
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rsgnet -Name $vnetname
$pip = Get-AzureRmPublicIPAddress -ResourceGroupName $rsgagw -Name $agwname-pip
$hostname1 = "aareon360.com"

#Gateway IP config
$gipconfig = New-AzureRmApplicationGatewayIPConfiguration `
  -Name appGatewayIP `
  -Subnet $subnet

#Frontend IP config
$fipconfig = New-AzureRmApplicationGatewayFrontendIPConfig `
  -Name appGatewayFrontendIP `
  -PublicIPAddress $pip

#Frontend Port config
$frontendporthttp = New-AzureRmApplicationGatewayFrontendPort `
  -Name appGatewayFrontendPort-HTTP `
  -Port 80
$frontendporthttps = New-AzureRmApplicationGatewayFrontendPort `
  -Name appGatewayFrontendPort-HTTPS `
  -Port 443
$frontendport36001 = New-AzureRmApplicationGatewayFrontendPort `
  -Name appGatewayFrontendPort-36001 `
  -Port 36001


#Backend pool config
#$address1 = Get-AzureRmNetworkInterface -ResourceGroupName $rsgweb -Name VM-WEB1-CLT5-nic
$address1 = Get-AzureRmNetworkInterface -ResourceGroupName $rsgweb -Name myNic1
$address2 = Get-AzureRmNetworkInterface -ResourceGroupName $rsgweb -Name myNic2
$backendPool = New-AzureRmApplicationGatewayBackendAddressPool `
  -Name Client5-Backendpool `
  -BackendIPAddresses $address1.ipconfigurations[0].privateipaddress, $address2.ipconfigurations[0].privateipaddress

#Health Probes
$healthprobe01 = New-AzureRmApplicationGatewayProbeConfig `
    -Name "$hostName1-https-probe" `
    -Protocol Https `
    -HostName $hostName1 `
    -Interval 30 `
    -Path "/" `
    -Timeout 30 `
    -UnhealthyThreshold 3

$healthprobe02 = New-AzureRmApplicationGatewayProbeConfig `
    -Name "$hostName1-36001-probe" `
    -Protocol Https `
    -HostName $hostName1 `
    -Interval 30 `
    -Path "/" `
    -Timeout 30 `
    -UnhealthyThreshold 3

#Backend HTTP settings
$backenthttpSetting01 = New-AzureRmApplicationGatewayBackendHttpSettings `
  -Name myPoolSettings `
  -Port 80 `
  -Protocol Http `
  -CookieBasedAffinity Enabled `
  -RequestTimeout 120 `
  -AuthenticationCertificates $authcert01
  -Probe $httpprobe01

$backenthttpSetting02 = New-AzureRmApplicationGatewayBackendHttpSettings `
  -Name myPoolSettings `
  -Port 443 `
  -Protocol Https `
  -CookieBasedAffinity Enabled `
  -RequestTimeout 120 `
  -AuthenticationCertificates $authcert01
  -Probe $httpprobe01

$backenthttpSetting03 = New-AzureRmApplicationGatewayBackendHttpSettings `
  -Name myPoolSettings `
  -Port 36001 `
  -Protocol Https `
  -CookieBasedAffinity Enabled `
  -RequestTimeout 120 `
  -AuthenticationCertificates $authcert01
  -Probe $httpprobe02


#Listeners
  $defaultlistener = NewAzureRmApplicationGatewayHttpListener `
        -Name "$hostName1-http" `
        -Protocol Http `
        -FrontendIPConfiguration $fipconfig01 `
        -FrontendPort $fphttp `
        -HostName $hostName1 `
        -SslCertificate $cert01

#Rules
$frontendRule01 = New-AzureRmApplicationGatewayRequestRoutingRule `
  -Name rule1 `
  -RuleType Basic `
  -HttpListener $defaultlistener `
  -BackendAddressPool $backendPool `
  -BackendHttpSettings $poolSettings

  $sku = New-AzureRmApplicationGatewaySku `
  -Name Standard_Small `
  -Tier Standard `
  -Capacity 1

New-AzureRmApplicationGateway `
  -Name $agwname `
  -ResourceGroupName $rsgagw `
  -Location $Location1 `
  -BackendAddressPools $backendPool `
  -BackendHttpSettingsCollection $poolSettings `
  -FrontendIpConfigurations $fipconfig `
  -GatewayIpConfigurations $gipconfig `
  -FrontendPorts $frontendporthttp, $frontendporthttps, $frontendport36001 `
  -HttpListeners $defaultlistener `
  -RequestRoutingRules $frontendRule `
  -Sku $sku