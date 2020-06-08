Describe -Tag:('JCOnline') 'Connect-JCOnline Tests' {
    BeforeAll {
        $StartingApiKey = If (-not [System.String]::IsNullOrEmpty($env:JCApiKey)) { $env:JCApiKey }
        $StartingOrgId = If (-not [System.String]::IsNullOrEmpty($env:JCOrgId)) { $env:JCOrgId }
    }
    AfterAll {
        If (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -JumpCloudOrgId:($StartingOrgId) -force | Out-Null }
        ElseIf (-not [System.String]::IsNullOrEmpty($StartingApiKey) -and [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudApiKey:($StartingApiKey) -force | Out-Null }
        ElseIf ([System.String]::IsNullOrEmpty($StartingApiKey) -and -not [System.String]::IsNullOrEmpty($StartingOrgId)) { Connect-JCOnline -JumpCloudOrgId:($StartingOrgId) -force | Out-Null }
        Else { Write-Error ('Unknown scenario encountered') }
    }
    Context 'Single Org Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -JumpCloudOrgId:($PesterParams_SingleTernateOrgId) -force
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $PesterParams_SingleTernateOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_SingleTernateOrgId
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $PesterParams_SingleTernateOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_SingleTernateOrgId
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($TestOrgAPIKey) -force
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $PesterParams_SingleTernateOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $env:JCOrgId
            # $Connect.JCOrgId | Should -Be $PesterParams_SingleTernateOrgId
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $TestOrgAPIKey | Should -Be $env:JCApiKey
            $PesterParams_SingleTernateOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_SingleTernateOrgId
        }
    }
    Context 'MSP OrgId 1 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams_MultiTernateOrgId1) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $PesterParams_MultiTernateOrgId1 | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId1
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $PesterParams_MultiTernateOrgId1 | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId1
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams_MultiTernateOrgId1) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $PesterParams_MultiTernateOrgId1 | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId1
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $PesterParams_MultiTernateOrgId1 | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
        }
    }
    Context 'MSP OrgId 2 Tests' {
        It ('Should connect using the JumpCloudApiKey and JumpCloudOrgId parameters.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -JumpCloudOrgId:($PesterParams_MultiTernateOrgId2) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $PesterParams_MultiTernateOrgId2 | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId2
        }
        It ('Should connect using the JumpCloudApiKey parameter.') {
            $Connect = Connect-JCOnline -JumpCloudApiKey:($MultiTenantAPIKey) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $PesterParams_MultiTernateOrgId2 | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId2
        }
        It ('Should connect using the JumpCloudOrgId parameter.') {
            $Connect = Connect-JCOnline -JumpCloudOrgId:($PesterParams_MultiTernateOrgId2) -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $PesterParams_MultiTernateOrgId2 | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $PesterParams_MultiTernateOrgId2
        }
        It('Should connect without parameters using the previously set env:jc* parameters.') {
            $Connect = Connect-JCOnline -force
            $MultiTenantAPIKey | Should -Be $env:JCApiKey
            $PesterParams_MultiTernateOrgId2 | Should -Be $env:JCOrgId
            #  $Connect.JCOrgId | Should -Be $env:JCOrgId
        }
    }
}