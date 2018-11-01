param(
	[Parameter(Position = 0, Mandatory = $true, HelpMessage = "Resource Group Name:", ValueFromPipeline = $false)] $RSG,
    [Parameter(Position = 1, Mandatory = $true, HelpMessage = "Subscription ID:", ValueFromPipeline = $false)] $SubID
	)

Select-AzureRmSubscription -SubscriptionId $SubID
$VMNames = Get-azurermvm -ResourceGroupName $RSG

foreach ($VMName in $VMNames) {
$password = Get-StrongPassword -Length 15
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("cofcoadm", $secpasswd)

Set-AzureRmVMAccessExtension -ResourceGroupName $RSG -Location $VMName.Location -VMName $VMName.Name -Credential $mycreds -typeHandlerVersion "2.0" -Name VMAccessAgent 
write-host -nonewline "`n`tVM Name: " -ForegroundColor Yellow; `
write-host -nonewline $($VMName.Name)`n -ForegroundColor Green
write-host -nonewline "`n`tPassword: " -ForegroundColor Yellow; `
write-host -nonewline $($password)`n -ForegroundColor cyan 

$SharedSub= Set-AzureRmContext -SubscriptionId '86f9cb6f-fd84-45fb-a2fc-6636e4ed2e3f' 
$secret = Set-AzureKeyVaultSecret -VaultName 'CILADMINCREDS' -Name $VMName.Name -SecretValue $secpasswd
$ProdSub= Set-AzureRmContext -SubscriptionId $SubID
}

