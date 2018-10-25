#Select Subscription
Select-AzureRmSubscription -SubscriptionId "dad51067-a563-4ea9-9a3c-8d7029308ed5"

#Bacup AGW config
Get-AzureRmApplicationGateway -Name UKW-SHR-AGW01-PRD -ResourceGroupName UKW-RSG-PRD-SHR > C:\Users\brendan.lawler\Desktop\AppGWBackup.txt

#First Step, load the existing Application Gateway configuration into the $agw variable
    $agw = Get-AzureRmApplicationGateway -Name UKW-SHR-AGW01-PRD -ResourceGroupName UKW-RSG-PRD-SHR

#Define Hostname variable
    $hostName1 = "demo.aareon360.com"


############################
### Add whitelist cert ###
############################
    $whitelistCertPath = "C:\users\brendan.lawler\desktop\aareon360.cer"
    $agw | Add-AzureRmApplicationGatewayAuthenticationCertificate -Name 'aareon360.cer' -CertificateFile $whitelistCertPath

############################
## Add .pfx for listener ###
############################
#Certificate must be in pfx format
    $certDirectory1 = "C:\users\brendan.lawler\desktop\aareon360.pfx"

#Certificate password must be between 4 to 12 characters.
    $certName1 = "aareon360Cert"
    $certPassword1 = ConvertTo-SecureString A@reon –asplaintext –force

    $agw | Add-AzureRmApplicationGatewaySslCertificate -Name $certName1 -CertificateFile $certDirectory1 -Password $certPassword1
############################

Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-36011" -Port 36011

#SSL certs variable
    $cert01 = $agw | Get-AzureRmApplicationGatewaySslCertificate | ? {$_.Name -eq "aareon360Cert"}

#Whitelist certs variable
    $authcert01 = $agw.AuthenticationCertificates | ?{$_.Name -eq "aareon360.cer"}

#Assumes you are using existing FrontendIP Config and single Backend Address Pool (may need to be adjusted to what exists in the $agw variable you just loaded)
    $fipconfig01 = $agw.FrontendIPConfigurations | ? {$_.Name -eq "appGatewayFrontendIP"}

    $backendpool1 = $agw.BackendAddressPools | ? {$_.Name -eq "Client1-Backendpool"}

#Frontend port variable
    $fphttp = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendHTTP" -ApplicationGateway $agw
    $fphttps = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort" -ApplicationGateway $agw
    $fp36001 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-36001" -ApplicationGateway $agw

#Loads the current AGW config and adds Health probes
    $agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName1-https-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
    $agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName1-36001-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3

#Defines Health probe variable
    $httpprobe01 = $agw.Probes | ?{$_.Name -eq "$hostName1-https-probe"}
    $httpprobe02 = $agw.Probes | ?{$_.Name -eq "$hostName1-36001-probe"}

#Loads the current AGW config and adds three backend HTTP Setting objects
    $agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName1-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe01
    $agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName1-36001-setting" -Port 36001 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe02

#Defines HTTP setting variable
    $poolSetting01 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName1-https-setting"}
    $poolSetting02 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName1-36001-setting"}

#Loads the updated AGW config and adds three Multi-site HTTP Listener objects
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName1 -SslCertificate $cert01
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName1 -SslCertificate $cert01
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-36001" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp36001 -HostName $hostName1 -SslCertificate $cert01

#Defines Listener variable
    $listener01 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-http"}
    $listener02 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-https"}
    $listener03 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-36001"}

#Loads the updated AGW config and adds three routing rules associating the new listeners and backend settings
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-https-rule" -RuleType Basic -HttpListener $listener02 -BackendHttpSettings $poolSetting01 -BackendAddressPool $backendpool1
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-http-to-https-redirect" -RuleType Basic -HttpListener $listener01 -BackendHttpSettings $poolSetting01 -BackendAddressPool $backendpool1
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-36001-rule" -RuleType Basic -HttpListener $listener03 -BackendHttpSettings $poolSetting02 -BackendAddressPool $backendpool1

#Commits the updated $agw config to the Azure Application Gateway (Update time varies and potential downtime experienced)
    $agw | Set-AzureRmApplicationGateway