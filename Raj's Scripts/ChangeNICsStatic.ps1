param(
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Resource Group Name", ValueFromPipeline = $false)] $RSG
	)

$NICS = Get-AzureRmResource -ResourceType Microsoft.Network/networkInterfaces -ResourceGroupName $RSG 

foreach($NI in $NICS){	    $NIC= Get-AzureRmNetworkInterface -Name $ni.name -ResourceGroupName $RSG     if($nic.IpConfigurations[0].PrivateIpAllocationMethod -eq 'Static') {}        else {	$nic.IpConfigurations[0].PrivateIpAllocationMethod = 'Static'	Set-AzureRmNetworkInterface -NetworkInterface $nic	$IP = $nic.IpConfigurations[0].PrivateIpAddress	Write-Host "The allocation method is now set to"$nic.IpConfigurations[0].PrivateIpAllocationMethod"for the IP address" $IP"." -NoNewline             }}
