param(
    [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Resource Group Name", ValueFromPipeline = $false)] $RSG
	)

$NICS = Get-AzureRmResource -ResourceType Microsoft.Network/networkInterfaces -ResourceGroupName $RSG 

foreach($NI in $NICS){