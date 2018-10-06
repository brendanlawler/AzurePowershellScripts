        $rsglist = Get-AzureRmResourceGroup
    foreach ($rsg in $rsglist)
    {
        $VMlist = Get-AzureRmVM -ResourceGroupName $rsg.ResourceGroupName
        foreach ($VM in $vmlist)
        {
        Get-AzureRmResource -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id | Get-AzureRmNetworkInterface | Select-Object -Property name, EnableAcceleratedNetworking
    }
    }

    




$vm = Get-Azurermvm -ResourceGroupName "RSGNAME" -Name "VMNAME"

Get-AzureRmResource -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id | Get-AzureRmNetworkInterface `
| Select-Object -Property name, EnableAcceleratedNetworking