function New-JCSettingsFile {
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = 'To Force Re-Creation of the Config file, set the $force parameter to $tru'
        )]
        [switch]
        $force
    )

    begin {
        # Config should be in /PowerShell/JumpCloudModule/Config.json
        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName
        $configFilePath = join-path -path $ModuleRoot -childpath 'Config.json'

        # Define Default Settings for the Config file
        $config = @{
            'parallel' = @{
                'Eligible'         = Get-JCParallelValidation
                'Override'         = $false;
                'MessageDismissed' = $false;
            }
            # TODO: implement update frequency checks
            # 'updates'  = @{
            #     'Frequency'           = 'week';
            #     'FrequencyValidation' = 'day week month';
            #     'LastCheck'           = (Get-Date);
            #     'NextCheck'           = '';
            # }
        }
    }

    process {
        # TODO: implement update frequency checks
        # $next = if ($config.updates.Frequency -eq 'day') {
        #     $config.updates.lastCheck.addDays(1)
        # } elseif ($config.updates.Frequency -eq 'week') {
        #     $config.updates.lastCheck.addDays(7)

        # } elseif ($config.updates.Frequency -eq 'month') {
        #     $config.updates.lastCheck.addMonths(1)
        # }
        # $config.updates.NextCheck = $next
    }

    end {
        if ((test-path -path $configFilePath) -And ($force)) {
            $config | ConvertTo-Json | Out-FIle -path $configFilePath
        } else {
            $config | ConvertTo-Json | Out-FIle -path $configFilePath
        }
    }
}