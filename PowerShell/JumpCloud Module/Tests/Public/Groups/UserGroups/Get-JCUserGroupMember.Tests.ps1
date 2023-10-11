Describe -Tag:('JCUserGroupMember') 'Get-JCUserGroupMember 1.0' {
    BeforeAll {

        If (-not (Get-JCUserGroupMember -GroupName:($PesterParams_UserGroup.Name))) {
            Add-JCUserGroupMember -GroupName:($PesterParams_UserGroup.Name) -Username:($PesterParams_User1.username)
        }
    }
    It 'Gets a User Groups membership by Groupname' {
        $UserGroupMembers = Get-JCUserGroupMember -GroupName:($PesterParams_UserGroup.Name)
        $UserGroupMembers.UserID.Count | Should -BeGreaterThan 0
    }
    It 'Gets a User Groups membership -ByID' {
        $UserGroupMembers = Get-JCUserGroupMember -ByID $PesterParams_UserGroup.Id
        $UserGroupMembers.UserID.Count | Should -BeGreaterThan 0
    }
}
