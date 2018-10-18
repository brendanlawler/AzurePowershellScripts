$rsg01 = 'EUS-RSG-ALL'
$vnet01 = 'EUS-VNET01'
$vng01 = 'EUS-VPN-SW-01'
$LNG01 = 'EUS-VPN-SW-LNG01'

$rsg02 = 'SCU-RSG-ALL'
$vnet02 = 'SCU-VNET01'
$vng02 = 'SCU-VPN-SW-01'
$LNG02 = 'SCU-VPN-SW-LNG01'

$Connection01 = Get-AzureRmVirtualNetworkGatewayConnection -Name "EUS-VPN-SW-CON05" -ResourceGroupName $rsg01
$Connection02 = Get-AzureRmVirtualNetworkGatewayConnection -Name "SCU-VPN-SW-CON05" -ResourceGroupName $rsg02

$newpolicy = New-AzureRmIpsecPolicy -IkeEncryption 'AES256' -IkeIntegrity 'SHA256' `
    -DhGroup 'DHGroup24' -IpsecEncryption 'AES256' -IpsecIntegrity 'SHA256' `
    -PfsGroup 'None' -SALifeTimeSeconds 3600 -SADataSizeKilobytes 102400000

$Connection01 | Set-AzureRmVirtualNetworkGatewayConnection -IpsecPolicies $newpolicy
$Connection02 | Set-AzureRmVirtualNetworkGatewayConnection -IpsecPolicies $newpolicy

$Connection01.IpsecPolicies
$Connection02.IpsecPolicies


$VPNGW01 = Get-AzureRmVirtualNetworkGateway -Name $vng01 -ResourceGroupName $rsg01
$VPNGW02 = Get-AzureRmVirtualNetworkGateway -Name $vng02 -ResourceGroupName $rsg02


