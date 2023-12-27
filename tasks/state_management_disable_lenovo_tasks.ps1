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

# Set default method to 'test' if not specified
If (!$method) {
    $method = 'test'
}

# Switch statement to handle the method specified
switch ($method) {
    # 'test' mode: Checks the state of specified scheduled tasks
    'test' {
        # List of scheduled task names to check
        $taskNames = @()
        $taskNames = 
            'TVSUUpdateTask',
            'TVSUUpdateTask_UserLogOn',
            'GenericMessagingAddin',
            'LenovoSystemUpdateAddin_WeeklyTask',
            'DailyTelemetryTransmission',
            'HeartbeatAddinDailyScheduleTask',
            'Lenovo.Vantage.SmartPerformance.MonthlyReport',
            'LenovoCompanionAppAddinDailyScheduleTask'

        # Iterating over each task name to get their current state
        $taskStates = @()
        $taskNames | ForEach-Object {
            $taskStates += (Get-ScheduledTask -TaskName $_ -EA 0).state
        }
        
        # If any task state is '3' (Enabled), return $false, else $true
        If ($taskStates -contains 3) {
            Return $false
        } Else {
            Return $true
        }
    }

    # 'set' mode: Disables the specified scheduled tasks
    'set' {
        # List of scheduled task names to disable
        $taskNames = @()
        $taskNames = 
            'TVSUUpdateTask',
            'TVSUUpdateTask_UserLogOn',
            'GenericMessagingAddin',
            'LenovoSystemUpdateAddin_WeeklyTask',
            'DailyTelemetryTransmission',
            'HeartbeatAddinDailyScheduleTask',
            'Lenovo.Vantage.SmartPerformance.MonthlyReport',
            'LenovoCompanionAppAddinDailyScheduleTask'

        # Disabling each specified task
        $taskNames | ForEach-Object {
            Disable-ScheduledTask -TaskName $_
        }
    }
}
