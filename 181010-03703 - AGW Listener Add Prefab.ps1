#####################
#Presuppositions:
#public cert has been extracted from .pfx provided by customer.


#Bacup AGW config
Get-AzureRmApplicationGateway -Name UKW-SHR-AGW01-PRD -ResourceGroupName UKW-RSG-PRD-SHR > C:\AppGWConfigBackup.txt

#Select Subscription
Select-AzureRmSubscription -SubscriptionId "dad51067-a563-4ea9-9a3c-8d7029308ed5"

############################
### Add whitelist cert ###
############################

$whitelistCertPath = "C:\SSLCertificates\PublicCertificate.cer"

$agw | Add-AzureRmApplicationGatewayAuthenticationCertificate -Name 'contoso.com-public-cer' -CertificateFile $whitelistCertPath


############################
## Add .pfx for listener ###
############################

$certDirectory1 = "C:\SSLCertificates\SSLCertificate.pfx"

#Certificate password must be between 4 to 12 characters.
$certName1 = "contoso.com-cert"
$certPassword1 = ConvertTo-SecureString PASSSWORD –asplaintext –force

$agw | Add-AzureRmApplicationGatewaySslCertificate -Name $certName1 -CertificateFile $certDirectory1 -Password $certPassword1

############################

############################
#Load the existing Application Gateway configuration into the $agw variable
############################
$agw = Get-AzureRmApplicationGateway -Name UKW-SHR-AGW01-PRD -ResourceGroupName UKW-RSG-PRD-SHR

############################
#Define variables
############################
#Hostname
$hostName1 = "blawlaw.com"
#Custom port e.g. 36001
$customport1 = "36001"
#Frontend IP Name
$frontendip1 = "appGatewayFrontendIP"
#Backendpool Name
$Backendpool1 = "Backendpool01"

#Whitelist Cert
$authcert01 = $agw.AuthenticationCertificates | ?{$_.Name -eq "$hostName1-public-cer"}
#SSL Cert
$cert01 = $agw | Get-AzureRmApplicationGatewaySslCertificate | ? {$_.Name -eq "$hostName1-cert"}
#FrontendIP
$fipconfig01 = $agw.FrontendIPConfigurations | ? {$_.Name -eq "$frontendip1"}
#BackendPool
$backendpool1 = $agw.BackendAddressPools | ? {$_.Name -eq "$Backendpool1"}
#Frontend port
$fphttp = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendHTTP" -ApplicationGateway $agw
$fphttps = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort" -ApplicationGateway $agw
$fpcust1 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-$customport1" -ApplicationGateway $agw




############################
#Set config
############################

#Loads the current AGW config and adds Health probes
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName1-https-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName1-$customport1-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
#Creates Health probe variable
$httpprobe01 = $agw.Probes | ?{$_.Name -eq "$hostName1-https-probe"}
$httpprobe02 = $agw.Probes | ?{$_.Name -eq "$hostName1-$customport1-probe"}

#Loads the current AGW config and adds three backend HTTP Setting objects
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName1-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe01
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName1-$customport1-setting" -Port $customport1 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe02
#Creates HTTP setting variable
$poolSetting01 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName1-https-setting"}
$poolSetting02 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName1-$customport1-setting"}

#Loads the updated AGW config and adds three Multi-site HTTP Listener objects
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName1 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName1 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-$customport1" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fpcust1 -HostName $hostName1 -SslCertificate $cert01
#Creates Listener variable
$listener01 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-http"}
$listener02 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-https"}
$listener03 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-$customport1"}

#Loads the updated AGW config and adds three routing rules associating the new listeners and backend settings
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-https-rule" -RuleType Basic -HttpListener $listener02 -BackendHttpSettings $poolSetting01 -BackendAddressPool $backendpool1
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-http-to-https-redirect" -RuleType Basic -HttpListener $listener01 -BackendHttpSettings $poolSetting01 -BackendAddressPool $backendpool1
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-$customport1-rule" -RuleType Basic -HttpListener $listener03 -BackendHttpSettings $poolSetting02 -BackendAddressPool $backendpool1

#Commits the updated $agw config to the Azure Application Gateway (Update time varies and potential downtime experienced)
$agw | Set-AzureRmApplicationGateway


Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-http-to-https-redirect" -RuleType Basic -HttpListener $listener01 -RedirectConfiguration 

Add-AzureRmApplicationGatewayRedirectConfiguration -ApplicationGateway $agw -Name "$hostName1-http-to-https-redirect" -RedirectType Permanent -TargetListener $listener02 -IncludePath -IncludeQueryString