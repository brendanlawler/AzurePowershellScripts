$rsgweb = "WEU-RSG-WEB"
$rsgnet = "WEU-RSG-NET"
$vnet  = "WEU-VNET-01"
$location1   = "West Europe"
$dmzsubnet = "WEU-RSG-NET-DMZ"

New-AzureRmResourceGroup -Name $rsgweb -Location $location1

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rsgnet -Name $vnet
$cred = Get-Credential
for ($i=1; $i -le 2; $i++)
{
  $nic = New-AzureRmNetworkInterface `
    -Name myNic$i `
    -ResourceGroupName $rsgweb `
    -Location $location1 `
    -SubnetId $vnet.Subnets[0].Id
  $vm = New-AzureRmVMConfig `
    -VMName WEU-VM-0$i `
    -VMSize Standard_B2ms
  $vm = Set-AzureRmVMOperatingSystem `
    -VM $vm `
    -Windows `
    -ComputerName myVM$i `
    -Credential $cred
  $vm = Set-AzureRmVMSourceImage `
    -VM $vm `
    -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer `
    -Skus 2016-Datacenter `
    -Version latest
  $vm = Add-AzureRmVMNetworkInterface `
    -VM $vm `
    -Id $nic.Id
  $vm = Set-AzureRmVMBootDiagnostics `
    -VM $vm `
    -Disable
  New-AzureRmVM -ResourceGroupName $rsgweb -Location $location1 -VM $vm
  Set-AzureRmVMExtension `
    -ResourceGroupName $rsgweb `
    -ExtensionName IIS `
    -VMName WEU-VM-0$i `
    -Publisher Microsoft.Compute `
    -ExtensionType CustomScriptExtension `
    -TypeHandlerVersion 1.4 `
    -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}' `
    -Location $location1
}