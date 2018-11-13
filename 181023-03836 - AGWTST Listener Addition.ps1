#Select Subscription
Select-AzureRmSubscription -SubscriptionId "dad51067-a563-4ea9-9a3c-8d7029308ed5"

#Bacup AGW config
Get-AzureRmApplicationGateway -Name UKW-SHR-AGW-TST01 -ResourceGroupName UKW-RSG-PRD-SHR > C:\Users\brendan.lawler\Desktop\AppGWBackup.txt

#First Step, load the existing Application Gateway configuration into the $agw variable
    $agw = Get-AzureRmApplicationGateway -Name UKW-SHR-AGW-TST01 -ResourceGroupName UKW-RSG-PRD-SHR

#Define Hostname variable
    $hostName1 = "aster.aareon360.com"
    $hostName2 = "broadacres.aareon360.com"
    $hostName3 = "curo.aareon360.com"

############################
### Add whitelist cert ###
############################
    $whitelistCertPath = "C:\Users\brendan.lawler\Desktop\Certs\aareon360.cer"
    $agw | Add-AzureRmApplicationGatewayAuthenticationCertificate -Name 'wildcard-aareon360-cer' -CertificateFile $whitelistCertPath

############################
## Add .pfx for listener ###
############################
#Certificate must be in pfx format
    $certDirectory1 = "C:\users\brendan.lawler\desktop\Certs\aareon360.pfx"

#Certificate password must be between 4 to 12 characters.
    $certName1 = "wildcard-aareon360-pfx"
    $certPassword1 = ConvertTo-SecureString A@reon –asplaintext –force

    $agw | Add-AzureRmApplicationGatewaySslCertificate -Name $certName1 -CertificateFile $certDirectory1 -Password $certPassword1
############################

Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-HTTPS" -Port 443
Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-36001" -Port 36001
Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-36011" -Port 36011
Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-36021" -Port 36021

#SSL certs variable
    $cert01 = $agw | Get-AzureRmApplicationGatewaySslCertificate | ? {$_.Name -eq "wildcard-aareon360-pfx"}

#Whitelist certs variable
    $authcert01 = $agw.AuthenticationCertificates | ?{$_.Name -eq "wildcard-aareon360-cer"}

#Assumes you are using existing FrontendIP Config and single Backend Address Pool (may need to be adjusted to what exists in the $agw variable you just loaded)
    $fipconfig01 = $agw.FrontendIPConfigurations | ? {$_.Name -eq "appGatewayFrontendIP"}

    $backendpool1 = $agw.BackendAddressPools | ? {$_.Name -eq "Client5-Backendpool"}

#Frontend port variable
    $fphttp = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort" -ApplicationGateway $agw
    $fphttps = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-HTTPS" -ApplicationGateway $agw
    $fp36001 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-36001" -ApplicationGateway $agw
    $fp36011 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-36011" -ApplicationGateway $agw
    $fp36021 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-36021" -ApplicationGateway $agw

#Loads the current AGW config and adds Health probes
    $agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName1-https-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
    $agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName1-36001-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3

    $agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName2-https-probe" -Protocol Https -HostName $hostName2 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
    $agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName2-36011-probe" -Protocol Https -HostName $hostName2 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3

    $agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName3-https-probe" -Protocol Https -HostName $hostName3 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
    $agw | Add-AzureRmApplicationGatewayProbeConfig -Name "$hostName3-36021-probe" -Protocol Https -HostName $hostName3 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3

#Defines Health probe variable
    $httpprobe01 = $agw.Probes | ?{$_.Name -eq "$hostName1-https-probe"}
    $httpprobe02 = $agw.Probes | ?{$_.Name -eq "$hostName1-36001-probe"}

    $httpprobe03 = $agw.Probes | ?{$_.Name -eq "$hostName2-https-probe"}
    $httpprobe04 = $agw.Probes | ?{$_.Name -eq "$hostName2-36011-probe"}

    $httpprobe05 = $agw.Probes | ?{$_.Name -eq "$hostName3-https-probe"}
    $httpprobe06 = $agw.Probes | ?{$_.Name -eq "$hostName3-36021-probe"}

#Loads the current AGW config and adds three backend HTTP Setting objects
    $agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName1-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe01
    $agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName1-36001-setting" -Port 36001 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe02

    $agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName2-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe03
    $agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName2-36011-setting" -Port 36011 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe04

    $agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName3-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe05
    $agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$hostName3-36021-setting" -Port 36021 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe06

#Defines HTTP setting variable
    $poolSetting01 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName1-https-setting"}
    $poolSetting02 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName1-36001-setting"}

    $poolSetting03 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName2-https-setting"}
    $poolSetting04 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName2-36011-setting"}

    $poolSetting05 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName3-https-setting"}
    $poolSetting06 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "$hostName3-36021-setting"}

#Loads the updated AGW config and adds three Multi-site HTTP Listener objects
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -SslCertificate $cert01 -Hostname $hostName1
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -SslCertificate $cert01 -Hostname $hostName1
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName1-36001" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp36001 -SslCertificate $cert01 -Hostname $hostName1

    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName2-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -SslCertificate $cert01 -Hostname $hostName2
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName2-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -SslCertificate $cert01 -Hostname $hostName2
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName2-36011" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp36011 -SslCertificate $cert01 -Hostname $hostName2

    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName3-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -SslCertificate $cert01 -Hostname $hostName3
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName3-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -SslCertificate $cert01 -Hostname $hostName3
    $agw | Add-AzureRmApplicationGatewayHttpListener -Name "$hostName3-36021" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp36021 -SslCertificate $cert01 -Hostname $hostName3

#Defines Listener variable
    $listener01 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-http"}
    $listener02 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-https"}
    $listener03 = $agw.HttpListeners | ?{$_.Name -eq "$hostName1-36001"}

    $listener04 = $agw.HttpListeners | ?{$_.Name -eq "$hostName2-http"}
    $listener05 = $agw.HttpListeners | ?{$_.Name -eq "$hostName2-https"}
    $listener06 = $agw.HttpListeners | ?{$_.Name -eq "$hostName2-36011"}

    $listener07 = $agw.HttpListeners | ?{$_.Name -eq "$hostName3-http"}
    $listener08 = $agw.HttpListeners | ?{$_.Name -eq "$hostName3-https"}
    $listener09 = $agw.HttpListeners | ?{$_.Name -eq "$hostName3-36021"}

#Loads the updated AGW config and adds three routing rules associating the new listeners and backend settings
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-https-rule" -RuleType Basic -HttpListener $listener02 -BackendHttpSettings $poolSetting01 -BackendAddressPool $backendpool1
        #Creates redirect config
        $agw | Add-AzureRmApplicationGatewayRedirectConfiguration -Name "$hostName1-http-to-https-redirect-config" -RedirectType "Permanent" -TargetListener $listener02 -IncludePath $true -IncludeQueryString $true
        #Defines redirect variable
        $redirectconfig1 = Get-AzureRmApplicationGatewayRedirectConfiguration -Name "$hostName1-http-to-https-redirect-config" -ApplicationGateway $agw
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-http-to-https-redirect" -RuleType Basic -HttpListener $listener01 -RedirectConfiguration $redirectconfig1
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName1-36001-rule" -RuleType Basic -HttpListener $listener03 -BackendHttpSettings $poolSetting02 -BackendAddressPool $backendpool1


    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName2-https-rule" -RuleType Basic -HttpListener $listener05 -BackendHttpSettings $poolSetting03 -BackendAddressPool $backendpool1
        #Creates redirect config
        $agw | Add-AzureRmApplicationGatewayRedirectConfiguration -Name "$hostName2-http-to-https-redirect-config" -RedirectType "Permanent" -TargetListener $listener05 -IncludePath $true -IncludeQueryString $true
        #Defines redirect variable
        $redirectconfig2 = Get-AzureRmApplicationGatewayRedirectConfiguration -Name "$hostName2-http-to-https-redirect-config" -ApplicationGateway $agw
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName2-http-to-https-redirect" -RuleType Basic -HttpListener $listener04 -RedirectConfiguration $redirectconfig2
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName2-36011-rule" -RuleType Basic -HttpListener $listener06 -BackendHttpSettings $poolSetting04 -BackendAddressPool $backendpool1

        
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName3-https-rule" -RuleType Basic -HttpListener $listener08 -BackendHttpSettings $poolSetting05 -BackendAddressPool $backendpool1
        #Creates redirect config
        $agw | Add-AzureRmApplicationGatewayRedirectConfiguration -Name "$hostName3-http-to-https-redirect-config" -RedirectType "Permanent" -TargetListener $listener08 -IncludePath $true -IncludeQueryString $true
        #Defines redirect variable
        $redirectconfig3 = Get-AzureRmApplicationGatewayRedirectConfiguration -Name "$hostName3-http-to-https-redirect-config" -ApplicationGateway $agw
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName3-http-to-https-redirect" -RuleType Basic -HttpListener $listener07 -RedirectConfiguration $redirectconfig3
    $agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "$hostName3-36021-rule" -RuleType Basic -HttpListener $listener09 -BackendHttpSettings $poolSetting06 -BackendAddressPool $backendpool1

#Commits the updated $agw config to the Azure Application Gateway (Update time varies and potential downtime experienced)
    $agw | Set-AzureRmApplicationGateway

