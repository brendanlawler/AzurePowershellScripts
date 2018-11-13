Select-AzureRmSubscription -SubscriptionId "24901bd8-e577-4496-8747-215cc441c1ed"


#name of NSG that you want to copy 
$nsgOrigin = "WEU-VNET01-DMZ-PRD-NSG" 
#name new NSG  
$nsgDestination = "WEU-VNET01-CBAST-PRD-NSG" 
#Resource Group Name of source NSG 
$rgName = "WEU-RSG-ALL-PRD" 
#Resource Group Name when you want the new NSG placed 
$rgNameDest = "WEU-RSG-ALL-PRD" 
 
$nsg = Get-AzureRmNetworkSecurityGroup -Name $nsgOrigin -ResourceGroupName $rgName 
$nsgRules = Get-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg 
$newNsg = Get-AzureRmNetworkSecurityGroup -name $nsgDestination -ResourceGroupName $rgNameDest 
foreach ($nsgRule in $nsgRules) { 
    Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsgDestination ` 
        -Name $nsgRule.Name ` 
        -Protocol $nsgRule.Protocol ` 
        -SourcePortRange $nsgRule.SourcePortRange ` 
        -DestinationPortRange $nsgRule.DestinationPortRange ` 
        -SourceAddressPrefix $nsgRule.SourceAddressPrefix ` 
        -DestinationAddressPrefix $nsgRule.DestinationAddressPrefix ` 
        -Priority $nsgRule.Priority ` 
        -Direction $nsgRule.Direction ` 
        -Access $nsgRule.Access 
} 
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $newNsg 

 Add-AzureRmNetworkSecurityRuleConfig -Name -


 $TemplateNSGRules =  Get-AzureRmNetworkSecurityGroup -Name 'WEU-VNET01-DMZ-PRD-NSG' -ResourceGroupName 'WEU-RSG-ALL-PRD' | Get-AzureRmNetworkSecurityRuleConfig
This creates a variable called TemplateNSGRules that we will use in step three. Next create your new NSG by running the following:

$NSG = New-AzureRmNetworkSecurityGroup -ResourceGroupName 'WEU-RSG-ALL-PRD' -Location 'West Europe' -Name 'WEU-VNET01-CBAST-PRD-NSG'
If you have already created an NSG in the portal, you would use this instead:

$NSG = Get-AzureRmNetworkSecurityGroup -Name 'WEU-VNET01-CBAST-PRD-NSG' -ResourceGroupName 'WEU-RSG-ALL-PRD'
Once you have executed one of the previous two commands, you will have a new variable called NSG that we will run a foreach loop on to import our rules from the original NSG:

 foreach ($rule in $TemplateNSGRules) {
    $NSG | Add-AzureRmNetworkSecurityRuleConfig -Name $rule.Name -Direction $rule.Direction -Priority $rule.Priority -Access $rule.Access -SourceAddressPrefix $rule.SourceAddressPrefix -SourcePortRange $rule.SourcePortRange -DestinationAddressPrefix $rule.DestinationAddressPrefix -DestinationPortRange $rule.DestinationPortRange -Protocol $rule.Protocol # -Description $rule.Description
    $NSG | Set-AzureRmNetworkSecurityGroup
}



$NSGList = Get-AzureRmNetworkSecurityGroup
foreach ($NSG in $NSGList) { 
        Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG `
            -Name "ALLOW_CBAST_WEU-PRD-CBAS01_RDP_SSH" `
            -Protocol Tcp `
            -SourcePortRange * `
            -DestinationPortRange "22,3389" `
            -SourceAddressPrefix "192.168.0.176/28" `
            -DestinationAddressPrefix "Any" `
            -Priority "275" `
            -Direction Inbound `
            -Access Allow `
            -Description "Rackspace ticket 181107-01365"
        } 



$NSGList = Get-AzureRmNetworkSecurityGroup
$NSGList.Name









NSG - NEU-RSG-ALL-PRD
NEU-VNET01-DMZ-PRD-NSG
NEU-VNET01-PBI-PRD-NSG
NEU-VNET01-PRDDB-PRD-NSG
NEU-VNET01-STD-PRD-NSG
NEU-VNET01-STW-PRD-NSG

NSG - WEU-RSG-ALL-PRD  
WEU-VNET01-DMZ-PRD-NSG
WEU-VNET01-PBI-PRD-NSG
WEU-VNET01-PRDDB-PRD-NSG
WEU-VNET01-STD-PRD-NSG
WEU-VNET01-STW-PRD-NSG
WEU-VNET01-TSTDB-PRD-NSG
WEU-VNET01-TSTWEB-PRD-NSG


$NSGName = "NEU-VNET01-DMZ-PRD-NSG"
$NSG = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName "NEU-RSG-ALL-PRD"

        Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG `
            -Name "ALLOW_CBAST_WEU-PRD-CBAS01_SSH" `
            -Protocol Tcp `
            -SourcePortRange * `
            -DestinationPortRange "22" `
            -SourceAddressPrefix "192.168.0.176/28" `
            -DestinationAddressPrefix * `
            -Priority "275" `
            -Direction Inbound `
            -Access Allow `
            -Description "Rackspace ticket 181107-01365"

        Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG `
            -Name "ALLOW_CBAST_WEU-PRD-CBAS01_RDP" `
            -Protocol Tcp `
            -SourcePortRange * `
            -DestinationPortRange "3389" `
            -SourceAddressPrefix "192.168.0.176/28" `
            -DestinationAddressPrefix * `
            -Priority "276" `
            -Direction Inbound `
            -Access Allow `
            -Description "Rackspace ticket 181107-01365"
         
 Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $Nsg 

