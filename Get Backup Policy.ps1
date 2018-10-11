$rsv = Get-AzureRmRecoveryServicesVault -ResourceGroupName "NEU-RSG-ALL-PRD" -Name "NEU-RSV01"

$rsv | Set-AzureRmRecoveryServicesVaultContext

$vmlist = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM | select-object -Property friendlyname


foreach ($VM in $vmlist)

{
        ##Replace Recovery service vault name
        Get-AzureRmRecoveryServicesVault -Name "EU2-PRD-ASR" | Set-AzureRmRecoveryServicesVaultContext

        ##FriendlyName is your Azure VM name
        $namedContainer=Get-AzureRmRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -FriendlyName $VM.FriendlyName

        $item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"

        $FinalDetails = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM" |select-object -Property VirtualMachineID,ProtectionPolicyName 
        $VMNAmeFinal  = $FinalDetails.VirtualMachineId | Split-Path -Leaf
        $RSVpolicyName = $FinalDetails.ProtectionPolicyName 

        $VMNameFinal
        $RSVPolicyName
        }


