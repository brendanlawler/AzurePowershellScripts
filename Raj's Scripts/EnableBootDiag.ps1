param(
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Resource Group Name:", ValueFromPipeline = $false)] $VMRSG,
	[Parameter(Position = 1, Mandatory = $true, HelpMessage = "Diagnostics Storage Name:", ValueFromPipeline = $false)] $DiagStorageAccountName,
    [Parameter(Position = 2, Mandatory = $true, HelpMessage = "Diagnostics RSG Name:", ValueFromPipeline = $false)] $DiagStorageAccountRSGName
	)


$Servers = Get-azurermvm -ResourceGroupName $VMRSG

foreach ($Server in $Servers) {

# Enable BootDiag of Azure VM
Set-AzureRmVMBootDiagnostics -VM $Server -Enable -ResourceGroupName $VMRSG -StorageAccountName $DiagStorageAccountName
}
