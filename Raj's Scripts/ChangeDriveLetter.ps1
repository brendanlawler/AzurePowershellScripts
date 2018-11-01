param(
	[string]$RSG

)

$VMNames = Get-azurermvm -ResourceGroupName $RSG
foreach ($VMName in $VMNames) {
Invoke-AzureRmVMRunCommand -ResourceGroupName $VMName.ResourceGroupName -Name $VMName.Name -CommandId 'RunPowerShellScript' -ScriptPath '$(System.DefaultWorkingDirectory)/_rsukbuild-COFCO-RESOURCES-SA-Repo-Allegro/Scripts/s2e.ps1'}