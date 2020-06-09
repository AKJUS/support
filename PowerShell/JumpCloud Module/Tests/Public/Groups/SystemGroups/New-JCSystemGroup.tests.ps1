Describe -Tag:('JCSystemGroup') 'New-JCSystemGroup 1.0' {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Creates a new system group" {
        $NewG = New-JCSystemGroup -GroupName $(New-RandomString 8)
        $NewG.Result | Should -Be 'Created'
        $DeletedG = Remove-JCSystemGroup -GroupName $NewG.name  -force
    }

}
