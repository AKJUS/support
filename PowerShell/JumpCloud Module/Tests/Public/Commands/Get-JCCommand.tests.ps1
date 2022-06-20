Describe -Tag:('JCCommand') 'Get-JCCommand 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Gets all JumpCloud commands" {
        $AllCommands = Get-JCCommand
        $AllCommands._id.Count | Should -BeGreaterThan 1
    }

    It "Gets a single JumpCloud command  declaring -CommandID" {
        $SingleCommand = Get-JCCommand | Select-Object -Last 1
        $SingleResult = Get-JCCommand -CommandID $SingleCommand._id
        $SingleResult._id.Count | Should -Be 1

    }

    It "Gets a single JumpCloud command  without declaring -CommandID" {
        $SingleCommand = Get-JCCommand | Select-Object -Last 1
        $SingleResult = Get-JCCommand $SingleCommand._id
        $SingleResult._id.Count | Should -Be 1

    }

    It "Gets a single JumpCloud command using -ByID passed through the pipeline" {
        $SingleResult = Get-JCCommand | Select-Object -Last 1 | Get-JCCommand -ByID
        $SingleResult._id.Count | Should -Be 1
    }

    It "Gets a single JumpCloud command passed through the pipeline without declaring -ByID" {
        $SingleResult = Get-JCCommand | Select-Object -Last 1 | Get-JCCommand
        $SingleResult._id.Count | Should -Be 1
    }


    It "Gets all JumpCloud command passed through the pipeline declaring -ByID" {
        $MultiResult = Get-JCCommand | Get-JCCommand -ByID
        $MultiResult._id.Count | Should -BeGreaterThan 1
    }

    It "Gets all JumpCloud command triggers" {
        $Triggers = Get-JCCommand | Where-Object trigger -ne ''
        $Triggers._id.Count | Should -BeGreaterThan 1
    }
}

Describe -Tag('JCCommand') 'Get-JCCommand Search' {
    BeforeAll { 
        Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null
        $PesterParams_Command1 = Get-JCCommand -CommandID:($PesterParams_Command1.Id) 
    }
    It "Searches a JumpCloud command by name" {
        $Command = Get-JCCommand -name $PesterParams_Command1.name
        $Command.name | Should -Be $PesterParams_Command1.name
    }
    It "Searches a JumpCloud command by command" {
        $Command = Get-JCCommand -command $PesterParams_Command1.command
        $Command.command | Should -Be $PesterParams_Command1.command
    }
    It "Searches a JumpCloud command by commandType" {
        $Command = Get-JCCommand -commandType $PesterParams_Command1.commandType
        $Command.commandType | Should -Be $PesterParams_Command1.commandType
    }
    It "Searches a JumpCloud command by launchType" {
        $Command = Get-JCCommand -launchType $PesterParams_Command1.launchType
        $Command.launchType | Should -Be $PesterParams_Command1.launchType
    }
    It "Searches a JumpCloud command by listensTo" {
        $Command = Get-JCCommand -listensTo $PesterParams_Command1.listensTo
        $Command.listensTo | Should -Be $PesterParams_Command1.listensTo
    }
    It "Searches a JumpCloud command by schedule" {
        $Command = Get-JCCommand -schedule $PesterParams_Command1.schedule
        $Command.schedule | Should -Be $PesterParams_Command1.schedule
    }
    It "Searches a JumpCloud command by trigger" {
        $Command = Get-JCCommand -trigger $PesterParams_Command1.trigger
        $Command.trigger | Should -Be $PesterParams_Command1.trigger
    }
    It "Searches a JumpCloud command by scheduleRepeatType" {
        $Command = Get-JCCommand -scheduleRepeatType $PesterParams_Command1.scheduleRepeatType
        $Command.scheduleRepeatType | Should -Be $PesterParams_Command1.scheduleRepeatType
    }
    It "Searches a JumpCloud command by organization" {
        $Command = Get-JCCommand -organization $PesterParams_Command1.organization
        $Command.organization | Should -Be $PesterParams_Command1.organization
    }
}