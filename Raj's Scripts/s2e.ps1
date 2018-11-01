$NewDrvLetter = 'X'

# Get Available CD/DVD Drive - Drive Type 5
$DvdDrv = Get-WmiObject -Class Win32_Volume -Filter "DriveType=5"
 
# Get Current Drive Letter for CD/DVD Drive
$DvdDrvLetter = $DvdDrv | Select-Object -ExpandProperty DriveLetter
Write-Output "Current CD/DVD Drive Letter is $DvdDrvLetter"
 
# Confirm New Drive Letter is NOT used
if (-not (Test-Path -Path $NewDrvLetter))
{
 
# Change CD/DVD Drive Letter
$DvdDrv | Set-WmiInstance -Arguments @{DriveLetter="$NewDrvLetter"}
Write-Output "Updated CD/DVD Drive Letter as $NewDrvLetter"

# Change S Drive to E
Get-Partition -DriveLetter S | Set-Partition -NewDriveLetter E
Write-Output "Updated S Drive Letter as E"
}
else
{
Write-Output "Error: Drive Letter $NewDrvLetter Already In Use"
}


