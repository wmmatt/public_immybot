<#
    .DESCRIPTION
    This task is intended to ensure Lenovo update prompts do not go out to the users. We're accomplishing this by disabling the Lenovo scheduled tasks that are associated to those popups. Below is a full list of scheduled tasks that this task disables:

    -TVT\TVSUUpdateTask
    -TVT\TVSUUpdateTask_UserLogOn
    -Lenovo\Vantage\Schedule\GenericMessagingAddin
    -Lenovo\Vantage\Schedule\LenovoSystemUpdateAddin_WeeklyTask
    -Lenovo\Vantage\Schedule\DailyTelemetryTransmission
    -Lenovo\Vantage\Schedule\HeartbeatAddinDailyScheduleTask
    -Lenovo\Vantage\Schedule\Lenovo.Vantage.SmartPerformance.MonthlyReport
    -Lenovo\Vantage\Schedule\LenovoCompanionAppAddinDailyScheduleTask
#>


switch ($method) {
    'test'{
        $taskNames = @()
        $taskNames = 'TVSUUpdateTask','TVSUUpdateTask_UserLogOn','GenericMessagingAddin','LenovoSystemUpdateAddin_WeeklyTask','DailyTelemetryTransmission','HeartbeatAddinDailyScheduleTask','Lenovo.Vantage.SmartPerformance.MonthlyReport','LenovoCompanionAppAddinDailyScheduleTask'

        $taskNames | ForEach-Object {
            $test = (Get-ScheduledTask -TaskName $_ -EA 0).state
                If ($test -eq '3') {
                    $status = 'failed'
                }
            }
        
        If ($status) {
            Return $false
        } Else {
            Return $true
        }

    }
    'set' {
        $taskNames = @()
        $taskNames = 'TVT\TVSUUpdateTask','TVT\TVSUUpdateTask_UserLogOn','Lenovo\Vantage\Schedule\GenericMessagingAddin','Lenovo\Vantage\Schedule\LenovoSystemUpdateAddin_WeeklyTask','Lenovo\Vantage\Schedule\DailyTelemetryTransmission','Lenovo\Vantage\Schedule\HeartbeatAddinDailyScheduleTask','Lenovo\Vantage\Schedule\Lenovo.Vantage.SmartPerformance.MonthlyReport','Lenovo\Vantage\Schedule\LenovoCompanionAppAddinDailyScheduleTask'

        $taskNames | ForEach-Object {
            Disable-ScheduledTask -TaskName $_
        }
    }
}
