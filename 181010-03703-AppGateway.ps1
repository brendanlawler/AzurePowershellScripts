Get-AzureRmApplicationGateway -Name UKW-SHR-AGW01-PRD -ResourceGroupName UKW-RSG-PRD-SHR > C:\Users\brendan.lawler\Desktop\AppGWBackup.txt

Select-AzureRmSubscription -SubscriptionId "dad51067-a563-4ea9-9a3c-8d7029308ed5"

#The Script updates an existing Application Gateway and adds multiple components
#
#
#First Step, load the existing Application Gateway configuration into the $agw variable
$agw = Get-AzureRmApplicationGateway -Name UKW-SHR-AGW01-PRD -ResourceGroupName UKW-RSG-PRD-SHR
 
#Set the variables for the additional components to be added
$hostName1 = "staffportal.newcharter.co.uk"
$hostName2 = "customerhub.newcharter.co.uk"
 
#Assumes you are using existing FrontendIP Config and single Backend Address Pool (may need to be adjusted to what exists in the $agw variable you just loaded)
$fipconfig01 = $agw.FrontendIPConfigurations | ? {$_.Name -eq "appGatewayFrontendIP"}
$pool3 = $agw.BackendAddressPools | ? {$_.Name -eq "Client3-Backendpool"}

$whitelistCertDirectory = "C:\users\brendan.lawler\desktop\stardtonewcharter.cer"

$agw | Add-AzureRmApplicationGatewayAuthenticationCertificate -Name 'stardtonewcharter.cer' -CertificateFile $whitelistCertDirectory

$authcert01 = $agw.AuthenticationCertificates | ?{$_.Name -eq "stardtonewcharter.cer"}


$certName1 = "stardtonewcharterCert"
  
#Certificate must be in pfx format
$certDirectory1 = "C:\users\brendan.lawler\desktop\stardtonewcharter.pfx"

#Certificate password must be between 4 to 12 characters.
$certPassword1 = ConvertTo-SecureString 1stTouch –asplaintext –force

$agw = New-AzureRmApplicationGatewaySslCertificate -Name $certName1 -CertificateFile $certDirectory1 -Password $certPassword1

$cert01 = Get-AzureRmApplicationGatewaySslCertificate -ApplicationGateway UKW-SHR-AGW01-PRD -Name "stardtonewcharterCert"

 
#If Frontend ports already exist in the configuration you can use the following variables and modify the where clause. Uncomment to make active:
#$fp01 = $agw.FrontendPorts | ?{$_.Port -eq 83}
#$fp02 = $agw.FrontendPorts | ?{$_.Port -eq 84}
#$fp03 = $agw.FrontendPorts | ?{$_.Port -eq 85}

#Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $agw -Name "appGatewayFrontendPort-36011" -Port 36011

#If you need to create new Frontend ports, use the following:
$fp01 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-36011" -ApplicationGateway $agw
$fphttp = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendHTTP" -ApplicationGateway $agw
$fphttps = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort" -ApplicationGateway $agw
$fp36001 = Get-AzureRmApplicationGatewayFrontendPort -Name "appGatewayFrontendPort-36001" -ApplicationGateway $agw


#Loads the current AGW config and adds Health probes
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "staffportal.newcharter.co.uk-https-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "staffportal.newcharter.co.uk-36011-probe" -Protocol Https -HostName $hostName1 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
#$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "customerhub.newcharter.co.uk-https-probe" -Protocol Https -HostName $hostName2 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3
$agw | Add-AzureRmApplicationGatewayProbeConfig -Name "customerhub.newcharter.co.uk-36001-probe" -Protocol Https -HostName $hostName2 -Interval 30 -Path "/" -Timeout 30 -UnhealthyThreshold 3

$httpprobe01 = $agw.Probes | ?{$_.Name -eq "staffportal.newcharter.co.uk-https-probe"}
$httpprobe02 = $agw.Probes | ?{$_.Name -eq "staffportal.newcharter.co.uk-36011-probe"}
$httpprobe03 = $agw.Probes | ?{$_.Name -eq "customerhub.newcharter.co.uk-https-probe"}
$httpprobe04 = $agw.Probes | ?{$_.Name -eq "customerhub.newcharter.co.uk-36001-probe"}

#Loads the current AGW config and adds three backend HTTP Setting objects
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "staffportal.newcharter.co.uk-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe01
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "staffportal.newcharter.co.uk-36011-setting" -Port 36011 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe02
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "customerhub.newcharter.co.uk-https-setting" -Port 443 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe03
$agw | Add-AzureRmApplicationGatewayBackendHttpSettings -Name "customerhub.newcharter.co.uk-36001-setting" -Port 36001 -Protocol Https -CookieBasedAffinity Enabled -RequestTimeout 120 -AuthenticationCertificates $authcert01 -Probe $httpprobe04

$poolSetting01 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "staffportal.newcharter.co.uk-https-setting"}
$poolSetting02 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "staffportal.newcharter.co.uk-36011-setting"}
$poolSetting03 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "customerhub.newcharter.co.uk-https-setting"}
$poolSetting04 = $agw.BackendHttpSettingsCollection  | ?{$_.Name -eq "customerhub.newcharter.co.uk-36001-setting"}


 
#Loads the updated AGW config and adds three Multi-site HTTP Listener objects
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "staffportal.newcharter.co.uk-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName1 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "staffportal.newcharter.co.uk-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName1 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "staffportal.newcharter.co.uk-36011" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -HostName $hostName1 -SslCertificate $cert01
#$agw | Add-AzureRmApplicationGatewayHttpListener -Name "customerhub.newcharter.co.uk-http" -Protocol Http -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttp -HostName $hostName2 -SslCertificate $cert01
#$agw | Add-AzureRmApplicationGatewayHttpListener -Name "customerhub.newcharter.co.uk-https" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fphttps -HostName $hostName2 -SslCertificate $cert01
$agw | Add-AzureRmApplicationGatewayHttpListener -Name "customerhub.newcharter.co.uk-36001" -Protocol Https -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp36001 -HostName $hostName2 -SslCertificate $cert01

$listener01 = $agw.HttpListeners | ?{$_.Name -eq "staffportal.newcharter.co.uk-http"}
$listener02 = $agw.HttpListeners | ?{$_.Name -eq "staffportal.newcharter.co.uk-https"}
$listener03 = $agw.HttpListeners | ?{$_.Name -eq "staffportal.newcharter.co.uk-36011"}
$listener04 = $agw.HttpListeners | ?{$_.Name -eq "customerhub.newcharter.co.uk-http"}
$listener05 = $agw.HttpListeners | ?{$_.Name -eq "customerhub.newcharter.co.uk-https"}
$listener06 = $agw.HttpListeners | ?{$_.Name -eq "customerhub.newcharter.co.uk-36001"}


#Loads the updated AGW config and adds three routing rules associating the new listeners and backend settings
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "staffportal.newcharter.co.uk-https-rule" -RuleType Basic -HttpListener $listener02 -BackendHttpSettings $poolSetting01 -BackendAddressPool $pool3
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "staffportal.newcharter.co.uk-http-to-https-redirect" -RuleType Basic -HttpListener $listener01 -BackendHttpSettings $poolSetting01 -BackendAddressPool $pool3
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "staffportal.newcharter.co.uk-36011-rule" -RuleType Basic -HttpListener $listener03 -BackendHttpSettings $poolSetting02 -BackendAddressPool $pool3

#$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "customerhub.newcharter.co.uk-https-rule" -RuleType Basic -HttpListener $listener05 -BackendHttpSettings $poolSetting03 -BackendAddressPool $pool3
#$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "customerhub.newcharter.co.uk-http-to-https-redirect" -RuleType Basic -HttpListener $listener04 -BackendHttpSettings $poolSetting03 -BackendAddressPool $pool3
$agw |  Add-AzureRmApplicationGatewayRequestRoutingRule -Name "customerhub.newcharter.co.uk-36001-rule" -RuleType Basic -HttpListener $listener06 -BackendHttpSettings $poolSetting04 -BackendAddressPool $pool3
 
#Commits the updated $agw config to the Azure Application Gateway (Update time varies and potential downtime experienced)
$agw | Set-AzureRmApplicationGateway




