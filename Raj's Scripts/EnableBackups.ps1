param(
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Resource Group Name:", ValueFromPipeline = $false)] $VMRSG,
	[Parameter(Position = 1, Mandatory = $true, HelpMessage = "VaultName:", ValueFromPipeline = $false)] $VaultName,
    [Parameter(Position = 2, Mandatory = $true, HelpMessage = "Backup Policy Name:", ValueFromPipeline = $false)] $ProtectionPolicyName
	)


$Servers = Get-azurermvm -ResourceGroupName $VMRSG


# Get Azure Recovery Vault and set vault context
Get-AzureRmRecoveryServicesVault -Name $VaultName | Set-AzureRmRecoveryServicesVaultContext
$ProtectionPolicy = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name $ProtectionPolicyName

foreach ($Server in $Servers) {

# Enable Protection of Azure VM
Enable-AzureRmRecoveryServicesBackupProtection -Policy $ProtectionPolicy -Name $Server.Name -ResourceGroupName $VMRSG

}
