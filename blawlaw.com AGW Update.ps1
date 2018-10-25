#####################
#Presuppositions:
#public cert has been extracted from .pfx provided by customer.

#Select Subscription
Select-AzureRmSubscription -SubscriptionId "78a56ad7-5cea-4967-a51e-ddc8523ff5ea"

############################
#Define variables
############################
    #Hostname
    $hostName1 = "blawlaw.com"
    #Custom port e.g. 360011
    $customport1 = "36001"
    #Frontend IP Name
    $frontendip1 = "appGatewayFrontendIP"
    #Backendpool Name
    $Backendpool1 = "appGatewayBackendPool"

############################
#Load the existing Application Gateway configuration into the $agw variable
############################
    $agw = Get-AzureRmApplicationGateway -Name WEU-AGW-01 -ResourceGroupName WEU-RSG-AGW

#Bacup AGW config
    Get-AzureRmApplicationGateway -Name WEU-AGW-01 -ResourceGroupName WEU-RSG-AGW > C:\Users\Jack\Desktop\AGWBackup.txt

#Add HTTPS frontend port
    Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-https" -Port 443
    Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-$customport1" -Port $customport1

#Define FrontendIP variable
    $fipconfig01 = $agw.FrontendIPConfigurations | ? {$_.Name -eq "$frontendip1"}

#Define BackendPool variable
    $backendpool1 = $agw.BackendAddressPools | ? {$_.Name -eq "$Backendpool1"}

#Define Frontend port variable
    $fphttp = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort" -ApplicationGateway $agw
    $fphttps = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-https" -ApplicationGateway $agw
    $fpcust1 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-$customport1" -ApplicationGateway $agw

############################
### Add whitelist cert ###
############################

    $authcertname1 = 'brlawlaw.com-cer'
    $whitelistCertPath = "C:\Users\Jack\Desktop\blawlaw.com.cer"
    $agw | Add-AzureRmApplicationGatewayAuthenticationCertificate -Name $authcertname1 -CertificateFile $whitelistCertPath

#Define Whitelist Cert variable
    $authcert01 = $agw.AuthenticationCertificates | ?{$_.Name -eq "$authcertname1"}

############################
## Add .pfx for listener ###
############################

    $certDirectory1 = "C:\Users\Jack\Desktop\blawlaw.com.pfx"
#Certificate password must be between 4 to 12 characters.
    $certName1 = "brlawlaw.com-pfx"
    $certPassword1 = ConvertTo-SecureString Pa55w0rd –asplaintext –force
    $agw | Add-AzureRmApplicationGatewaySslCertificate -Name $certName1 -CertificateFile $certDirectory1 -Password $certPassword1

#Define SSL Cert variable
    $cert01 = $agw | Get-AzureRmApplicationGatewaySslCertificate | ? {$_.Name -eq "$certName1"}

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

    #Creates redirect config
    $agw | Add-AzureRmApplicationGatewayRedirectConfiguration -Name "$hostName1-http-to-https-redirect-config" -RedirectType "Permanent" -TargetListener $listener02 -IncludePath $true -IncludeQueryString $true
    #Defines redirect variable
    $redirectconfig1 = Get-AzureRmApplicationGatewayRedirectConfiguration -Name "$hostName1-http-to-https-redirect-config" -ApplicationGateway $agw

    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-http-to-https-redirect" -RuleType Basic -HttpListener $listener01 -RedirectConfiguration $redirectconfig1
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-$customport1-rule" -RuleType Basic -HttpListener $listener03 -BackendHttpSettings $poolSetting02 -BackendAddressPool $backendpool1

#Commits the updated $agw config to the Azure Application Gateway (Update time varies and potential downtime experienced)
    $agw | Set-AzureRmApplicationGateway

    Get-AzureRmApplicationGatewaySku -ApplicationGateway $agw

    
    