#Bacup AGW config
Get-AzureRmApplicationGateway -Name UKW-SHR-AGW01-PRD -ResourceGroupName UKW-RSG-PRD-SHR > C:\Users\brendan.lawler\Desktop\AppGWBackup.txt

#Select Subscription
Select-AzureRmSubscription -SubscriptionId "dad51067-a563-4ea9-9a3c-8d7029308ed5"

############################
### Add whitelist cert ###
############################
$whitelistCertPath = "C:\users\brendan.lawler\desktop\stardtonewcharter.cer"
$agw | Add-AzureRmApplicationGatewayAuthenticationCertificate -Name 'stardtonewcharter.cer' -CertificateFile $whitelistCertPath


############################
## Add .pfx for listener ###
############################
#Certificate must be in pfx format
$certDirectory1 = "C:\users\brendan.lawler\desktop\stardtonewcharter.pfx"

#Certificate password must be between 4 to 12 characters.
$certName1 = "stardtonewcharterCert"
$certPassword1 = ConvertTo-SecureString 1stTouch –asplaintext –force

$agw | Add-AzureRmApplicationGatewaySslCertificate -Name $certName1 -CertificateFile $certDirectory1 -Password $certPassword1
############################

Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-36011" -Port 36011


#First Step, load the existing Application Gateway configuration into the $agw variable
$agw = Get-AzureRmApplicationGateway -Name UKW-SHR-AGW01-PRD -ResourceGroupName UKW-RSG-PRD-SHR
 
#Hostname variable
$hostName1 = "360demo.1sttouch.com"
$hostName2 = "newcharter.1sttouch.com"
$hostName3 = "ongo.1sttouch.com"
$hostName4 = "adactus.1sttouch.com"
$hostName5 = "customerhub.newcharter.co.uk"
$hostName6 = "staffportal.newcharter.co.uk"

#SSL certs variable
$cert01 = $agw | Get-AzureRmApplicationGatewaySslCertificate | ? {$_.Name -eq "star.1sttouch.com.2018"}
$cert02 = $agw | Get-AzureRmApplicationGatewaySslCertificate | ? {$_.Name -eq "360demo.1sttouch.com.pfx"}
$cert03 = $agw | Get-AzureRmApplicationGatewaySslCertificate | ? {$_.Name -eq "star.1sttouch.new.com"}
$cert04 = $agw | Get-AzureRmApplicationGatewaySslCertificate | ? {$_.Name -eq "stardtonewcharterCert"}


#Whitelist certs variable
$authcert01 = $agw.AuthenticationCertificates | ?{$_.Name -eq "wildcard.1sttouch.com"}
$authcert02 = $agw.AuthenticationCertificates | ?{$_.Name -eq "stardtonewcharter.cer"}

#Assumes you are using existing FrontendIP Config and single Backend Address Pool (may need to be adjusted to what exists in the $agw variable you just loaded)
$fipconfig01 = $agw.FrontendIPConfigurations | ? {$_.Name -eq "appGatewayFrontendIP"}

$backendpool1 = $agw.BackendAddressPools | ? {$_.Name -eq "Client1-Backendpool"}
$backendpool2 = $agw.BackendAddressPools | ? {$_.Name -eq "Client2-Backendpool"}
$backendpool3 = $agw.BackendAddressPools | ? {$_.Name -eq "Client3-Backendpool"}

#Frontend port variable
$fphttp = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendHTTP" -ApplicationGateway $agw
$fphttps = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort" -ApplicationGateway $agw
$fp36001 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-36001" -ApplicationGateway $agw
$fp36001 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-36011" -ApplicationGateway $agw

#Health probe variable
$httpprobe01 = $agw.Probes | ?{$_.Name -eq "360demo.1sttouch.com-https-probe"}
$httpprobe02 = $agw.Probes | ?{$_.Name -eq "360demo.1sttouch.com-36001-probe"}
$httpprobe03 = $agw.Probes | ?{$_.Name -eq "newcharter.1sttouch.com-https-probe"}
$httpprobe04 = $agw.Probes | ?{$_.Name -eq "ongo.1sttouch.com-https-probe"}
$httpprobe05 = $agw.Probes | ?{$_.Name -eq "adactus.1sttouch.com-https-probe"}
$httpprobe06 = $agw.Probes | ?{$_.Name -eq "customerhub.newcharter.co.uk-https-probe"}
$httpprobe07 = $agw.Probes | ?{$_.Name -eq "customerhub.newcharter.co.uk-36001-probe"}
$httpprobe08 = $agw.Probes | ?{$_.Name -eq "staffportal.newcharter.co.uk-https-probe"}
$httpprobe09 = $agw.Probes | ?{$_.Name -eq "staffportal.newcharter.co.uk-36011-probe"}

#HTTP setting variable
$poolSetting01 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "360demo.1sttouch.com-https-setting"}
$poolSetting02 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "360demo.1sttouch.com-36001-setting"}
$poolSetting03 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "newcharter.1sttouch.com-https-setting"}
$poolSetting04 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "ongo.1sttouch.com-https-setting"}
$poolSetting05 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "adactus.1sttouch.com-https-setting"}
$poolSetting06 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "customerhub.newcharter.co.uk-https-setting"}
$poolSetting07 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "customerhub.newcharter.co.uk-36001-setting"}
$poolSetting08 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "staffportal.newcharter.co.uk-https-setting"}
$poolSetting09 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "staffportal.newcharter.co.uk-36011-setting"}

#Listener variable
$listener01 = $agw.HttpListeners | ?{$_.Name -eq "360demo.1sttouch.com-http"}
$listener02 = $agw.HttpListeners | ?{$_.Name -eq "360demo.1sttouch.com-https"}
$listener03 = $agw.HttpListeners | ?{$_.Name -eq "360demo.1sttouch.com-36001"}
$listener04 = $agw.HttpListeners | ?{$_.Name -eq "newcharter.1sttouch.com-http"}
$listener05 = $agw.HttpListeners | ?{$_.Name -eq "newcharter.1sttouch.com-https"}
$listener06 = $agw.HttpListeners | ?{$_.Name -eq "ongo.1sttouch.com-http"}
$listener07 = $agw.HttpListeners | ?{$_.Name -eq "ongo.1sttouch.com-https"}
$listener08 = $agw.HttpListeners | ?{$_.Name -eq "adactus.1sttouch.com-http"}
$listener09 = $agw.HttpListeners | ?{$_.Name -eq "adactus.1sttouch.com-https"}
$listener10 = $agw.HttpListeners | ?{$_.Name -eq "customerhub.newcharter.co.uk-http"}
$listener11 = $agw.HttpListeners | ?{$_.Name -eq "customerhub.newcharter.co.uk-https"}
$listener12 = $agw.HttpListeners | ?{$_.Name -eq "customerhub.newcharter.co.uk-36001"}
$listener13 = $agw.HttpListeners | ?{$_.Name -eq "staffportal.newcharter.co.uk-http"}
$listener14 = $agw.HttpListeners | ?{$_.Name -eq "staffportal.newcharter.co.uk-https"}
$listener15 = $agw.HttpListeners | ?{$_.Name -eq "staffportal.newcharter.co.uk-36011"}


#Loads the current AGW config and adds Health probes
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "360demo.1sttouch.com-https-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "360demo.1sttouch.com-36001-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "newcharter.1sttouch.com-https-probe" -Protocol Https -HostName $hostName2 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "ongo.1sttouch.com-https-probe" -Protocol Https -HostName $hostName3 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "adactus.1sttouch.com-https-probe" -Protocol Https -HostName $hostName4 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "customerhub.newcharter.co.uk-https-probe" -Protocol Https -HostName $hostName5 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "customerhub.newcharter.co.uk-36001-probe" -Protocol Https -HostName $hostName5 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "staffportal.newcharter.co.uk-https-probe" -Protocol Https -HostName $hostName6 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "staffportal.newcharter.co.uk-36011-probe" -Protocol Https -HostName $hostName6 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3


#Loads the current AGW config and adds three backend HTTP Setting objects
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "360demo.1sttouch.com-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe01
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "360demo.1sttouch.com-36001-setting" -Port 36001 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe02
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "newcharter.1sttouch.com-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe03
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "ongo.1sttouch.com-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe04
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "adactus.1sttouch.com-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe05
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "customerhub.newcharter.co.uk-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert02 -Probe $httpprobe06
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "customerhub.newcharter.co.uk-36001-setting" -Port 36001 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert02 -Probe $httpprobe07
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "staffportal.newcharter.co.uk-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert02 -Probe $httpprobe08
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "staffportal.newcharter.co.uk-36011-setting" -Port 36011 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert02 -Probe $httpprobe09


#Loads the updated AGW config and adds three Multi-site HTTP Listener objects
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "360demo.1sttouch.com-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName1 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "360demo.1sttouch.com-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName1 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "360demo.1sttouch.com-36001" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp36001 -HostName $hostName1 -SslCertificate $cert01

$agw | Add-AzureRmApplicationGatewayHttpListener -Name "newcharter.1sttouch.com-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName2 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "newcharter.1sttouch.com-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName2 -SslCertificate $cert01

$agw | Add-AzureRmApplicationGatewayHttpListener -Name "ongo.1sttouch.com-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName3 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "ongo.1sttouch.com-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName3 -SslCertificate $cert01

$agw | Add-AzureRmApplicationGatewayHttpListener -Name "adactus.1sttouch.com-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName4 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "adactus.1sttouch.com-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName4 -SslCertificate $cert01

$agw | Add-AzureRmApplicationGatewayHttpListener -Name "customerhub.newcharter.co.uk-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName5 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "customerhub.newcharter.co.uk-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName5 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "customerhub.newcharter.co.uk-36001" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp36001 -HostName $hostName5 -SslCertificate $cert01

$agw | Add-AzureRmApplicationGatewayHttpListener -Name "staffportal.newcharter.co.uk-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName6 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "staffportal.newcharter.co.uk-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName6 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "staffportal.newcharter.co.uk-36011" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp36011 -HostName $hostName6 -SslCertificate $cert01


#Loads the updated AGW config and adds three routing rules associating the new listeners and backend settings
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "360demo.1sttouch.com-https-rule" -RuleType Basic -HttpListener $listener02 -BackendHttpSettings $poolSetting01 -BackendAddressPool $backendpool1
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "360demo.1sttouch.com-http-to-https-redirect" -RuleType Basic -HttpListener $listener01 -BackendHttpSettings $poolSetting01 -BackendAddressPool $backendpool1
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "360demo.1sttouch.com-36001-rule" -RuleType Basic -HttpListener $listener03 -BackendHttpSettings $poolSetting02 -BackendAddressPool $backendpool1

$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "newcharter.1sttouch.com-https-rule" -RuleType Basic -HttpListener $listener05 -BackendHttpSettings $poolSetting03 -BackendAddressPool $backendpool2
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "newcharter.1sttouch.com-http-to-https-redirect" -RuleType Basic -HttpListener $listener04 -BackendHttpSettings $poolSetting03 -BackendAddressPool $backendpool2

$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "ongo.1sttouch.com-https-rule" -RuleType Basic -HttpListener $listener07 -BackendHttpSettings $poolSetting04 -BackendAddressPool $backendpool2
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "ongo.1sttouch.com-http-to-https-redirect" -RuleType Basic -HttpListener $listener06 -BackendHttpSettings $poolSetting04 -BackendAddressPool $backendpool2

$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "adactus.1sttouch.com-https-rule" -RuleType Basic -HttpListener $listener09 -BackendHttpSettings $poolSetting05 -BackendAddressPool $backendpool2
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "adactus.1sttouch.com-http-to-https-redirect" -RuleType Basic -HttpListener $listener08 -BackendHttpSettings $poolSetting05 -BackendAddressPool $backendpool2

$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "customerhub.newcharter.co.uk-https-rule" -RuleType Basic -HttpListener $listener11 -BackendHttpSettings $poolSetting06 -BackendAddressPool $backendpool3
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "customerhub.newcharter.co.uk-http-to-https-redirect" -RuleType Basic -HttpListener $listener10 -BackendHttpSettings $poolSetting06 -BackendAddressPool $backendpool3
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "customerhub.newcharter.co.uk-36001-rule" -RuleType Basic -HttpListener $listener12 -BackendHttpSettings $poolSetting07 -BackendAddressPool $backendpool3

$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "staffportal.newcharter.co.uk-https-rule" -RuleType Basic -HttpListener $listener14 -BackendHttpSettings $poolSetting08 -BackendAddressPool $backendpool3
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "staffportal.newcharter.co.uk-http-to-https-redirect" -RuleType Basic -HttpListener $listener13 -BackendHttpSettings $poolSetting08 -BackendAddressPool $backendpool3
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "staffportal.newcharter.co.uk-36011-rule" -RuleType Basic -HttpListener $listener15 -BackendHttpSettings $poolSetting09 -BackendAddressPool $backendpool3


#Commits the updated $agw config to the Azure Application Gateway (Update time varies and potential downtime experienced)
$agw | Set-AzureRmApplicationGateway

        