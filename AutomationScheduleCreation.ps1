$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup01-Startup"
$StartTime = "20.09.2018.06:00"
$TimeZone = "GMT Standard Time"
$DaysOfWeek = @("Monday","Tuesday","Wednesday","Thursday","Friday")
$WeekInterval = "1"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -TimeZone $TimeZone -DaysOfWeek $DaysOfWeek -WeekInterval $WeekInterval

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup01-Shutdown"
$StartTime = "19.09.2018.18:00"
$TimeZone = "GMT Standard Time"
$DaysOfWeek = @("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
$WeekInterval = "1"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -TimeZone $TimeZone -DaysOfWeek $DaysOfWeek -WeekInterval $WeekInterval

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup01-Startup-3rdWednesday"
$StartTime = "26.09.2018.01:30"
$DayOfWeekOccurrance = "Third"
$DayOfWeek = "Wednesday"
$MonthInterval = "1"
$TimeZone = "GMT Standard Time"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -DayOfWeekOccurrence $DayOfWeekOccurrance -DayOfWeek $DayOfWeek -TimeZone $TimeZone -MonthInterval $MonthInterval

#==========================================================================================================================

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup02-Startup"
$StartTime = "20.09.2018.06:00"
$TimeZone = "GMT Standard Time"
$DaysOfWeek = @("Monday","Tuesday","Wednesday","Thursday","Friday")
$WeekInterval = "1"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -TimeZone $TimeZone -DaysOfWeek $DaysOfWeek -WeekInterval $WeekInterval

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup02-Shutdown"
$StartTime = "19.09.2018.20:00"
$TimeZone = "GMT Standard Time"
$DaysOfWeek = @("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
$WeekInterval = "1"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -TimeZone $TimeZone -DaysOfWeek $DaysOfWeek -WeekInterval $WeekInterval

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup02-Startup-3rdWednesday"
$StartTime = "26.09.2018.01:30"
$DayOfWeekOccurrance = "Third"
$DayOfWeek = "Wednesday"
$MonthInterval = "1"
$TimeZone = "GMT Standard Time"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -DayOfWeekOccurrence $DayOfWeekOccurrance -DayOfWeek $DayOfWeek -TimeZone $TimeZone -MonthInterval $MonthInterval

#==========================================================================================================================

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup03-Startup"
$StartTime = "20.09.2018.06:00"
$TimeZone = "GMT Standard Time"
$DaysOfWeek = @("Monday","Tuesday","Wednesday","Thursday","Friday")
$WeekInterval = "1"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -TimeZone $TimeZone -DaysOfWeek $DaysOfWeek -WeekInterval $WeekInterval

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup03-Shutdown"
$StartTime = "19.09.2018.20:00"
$TimeZone = "GMT Standard Time"
$DaysOfWeek = @("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
$WeekInterval = "1"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -TimeZone $TimeZone -DaysOfWeek $DaysOfWeek -WeekInterval $WeekInterval

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup03-Startup-2ndWednesday"
$StartTime = "26.09.2018.01:30"
$DayOfWeekOccurrance = "Second"
$DayOfWeek = "Wednesday"
$MonthInterval = "1"
$TimeZone = "GMT Standard Time"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -DayOfWeekOccurrence $DayOfWeekOccurrance -DayOfWeek $DayOfWeek -TimeZone $TimeZone -MonthInterval $MonthInterval

#==========================================================================================================================

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup04-Startup-3rdWednesday"
$StartTime = "26.09.2018.01:30"
$DayOfWeekOccurrance = "Third"
$DayOfWeek = "Wednesday"
$MonthInterval = "1"
$TimeZone = "GMT Standard Time"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -DayOfWeekOccurrence $DayOfWeekOccurrance -DayOfWeek $DayOfWeek -TimeZone $TimeZone -MonthInterval $MonthInterval

$RSG = "NEU-RSG-CLT-PRD"
$AutomationAccountName = "vm-shutdown-startup-automation"
$ScheduleName = "ShutdownStartupGroup04-Shutdown-3rdWednesday"
$StartTime = "26.09.2018.03:00"
$DayOfWeekOccurrance = "Third"
$DayOfWeek = "Wednesday"
$MonthInterval = "1"
$TimeZone = "GMT Standard Time"
    New-AzureRmAutomationSchedule -ResourceGroupName $RSG -AutomationAccountName $AutomationAccountName `
-Name $ScheduleName -StartTime $StartTime -DayOfWeekOccurrence $DayOfWeekOccurrance -DayOfWeek $DayOfWeek -TimeZone $TimeZone -MonthInterval $MonthInterval



Get-AzureRmAutomationRunbook -ResourceGroupName "NEU-RSG-CLT-PRD" -AutomationAccountName "vm-shutdown-startup-automation" -name "VMShutdownStartup"

Get-AzureRmAutomationSchedule -ResourceGroupName "NEU-RSG-CLT-PRD" -AutomationAccountName "vm-shutdown-startup-automation"

Get-AzureRmAutomationScheduledRunbook -ResourceGroupName "NEU-RSG-CLT-PRD" -AutomationAccountName "vm-shutdown-startup-automation" -RunbookName "VMShutdownStartup"

Get-AzureRmAutomationSchedule