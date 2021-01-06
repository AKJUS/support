<#
TODO
    . Should association back up all Association for item or just the Association possible within the type parameter?
    . Make this a class in psm1 file: [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
    . Roll back x-ms-enum
    . Change `-direct` switch to where filter
#>
<#
.Synopsis
The function exports objects from your JumpCloud organization to local json files

.Description
The function exports objects from your JumpCloud organization to local json files

.Example
Backup UserGroups and SystemUsers with their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers') -Association

.Example
Backup UserGroups and SystemUsers without their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers')

.Example
Backup all avalible JumpCloud objects and their Association
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -All

.Link
https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Backup-JCOrganization.md
#>

Function Backup-JCOrganization
{
    [CmdletBinding(DefaultParameterSetName = 'All', PositionalBinding = $false)]
    Param(
        [Parameter(Mandatory)]
        [System.String]
        # Specify output file path for backup files
        ${Path},

        [Parameter(ParameterSetName = 'All')]
        [switch]
        # The Username of the JumpCloud user you wish to search for
        ${All},

        [Parameter(ParameterSetName = 'Type')]
        [ValidateSet('SystemGroup', 'UserGroup', 'System', 'SystemUser')]
        [System.String[]]
        # Specify the type of JumpCloud objects you want to backup
        ${Type},

        [Parameter(ParameterSetName = 'Type')]
        [switch]
        # Include to backup object type Association
        ${Association}
    )
    Begin
    {
        $Date = Get-Date -Format:("yyyyMMddTHHmmssffff")
        $ChildPath = "JumpCloud_$($Date)"
        $TempPath = Join-Path -Path:($PSBoundParameters.Path) -ChildPath:($ChildPath)
        $ArchivePath = Join-Path -Path:($PSBoundParameters.Path) -ChildPath:("$($ChildPath).zip")
        $Manifest = @{
            name             = "JumpCloudBackup";
            date             = "$Date";
            organizationID   = "$env:JCOrgId"
            backupFiles      = @()
            associationFiles = @()
        }
        # If the path does not exist, create it
        If (-not (Test-Path $TempPath))
        {
            New-Item -Path:($TempPath) -Name:$($TempPath.BaseName) -ItemType:('directory')
        }
        # When -All is provided use all type options and Association
        $Types = If ($PSCmdlet.ParameterSetName -eq 'All')
        {
            $PSBoundParameters.Add('Association', $true)
            (Get-Command $MyInvocation.MyCommand).Parameters.Type.Attributes.ValidValues
        }
        Else
        {
            $PSBoundParameters.Type
        }
        # Map to define how JCAssociation & JcSdk types relate
        $JcTypesMap = @{
            Application  = 'application';
            Command      = 'command';
            GSuite       = 'g_suite';
            LdapServer   = 'ldap_server';
            Office365    = 'office_365';
            Policy       = 'policy';
            RadiusServer = 'radius_server';
            System       = 'system';
            SystemGroup  = 'system_group';
            SystemUser   = 'user';
            UserGroup    = 'user_group';
        }
    }
    Process
    {
        $sw = [Diagnostics.Stopwatch]::StartNew()
        # Foreach type start a new job and retrieve object records
        $ObjectJobs = $Types | ForEach-Object {
            $JumpCloudType = $_
            Start-Job -ScriptBlock:( { Param ($TempPath, $JumpCloudType);
                    $CommandTemplate = "Get-JcSdk{0}"
                    $Result = Invoke-Expression -Command:($CommandTemplate -f $JumpCloudType)
                    # Write output to file
                    $Result `
                    | ForEach-Object { $_ | Select-Object *, @{Name = 'JcSdkModel'; Expression = { $_.GetType().FullName } } } `
                    | ConvertTo-Json -Depth:(100) `
                    | Out-File -FilePath:("$($TempPath)/$($JumpCloudType).json") -Force
                    # Manifest: Populate backupFiles value
                    $backupFiles = @{
                        backupType     = $JumpCloudType
                        backupLocation = "./$($JumpCloudType).json"
                    }
                    return $backupFiles
                }) -ArgumentList:($TempPath, $JumpCloudType)
        }
        $ObjectJobStatus = Wait-Job -Id:($ObjectJobs.Id)
        # Manifest: Populate backupFiles value
        $manifest.backupFiles += $ObjectJobStatus | Receive-Job
        $sw.Stop()
        Write-Host ("Object Run Time: $($sw.Elapsed)") -BackgroundColor Cyan

        # Foreach type start a new job and retreive object association records
        If ($PSBoundParameters.Association)
        {
            $AssociationJobs = @()
            $sw = [Diagnostics.Stopwatch]::StartNew()
            # Get the backup files we created earlier
            $BackupFiles = Get-ChildItem -Path:($TempPath) | Where-Object { $_.BaseName -in $Types }
            ForEach ($BackupFile In $BackupFiles)
            {
                # Type mapping lookup
                $SourceTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Key -eq $BackupFile.BaseName }
                # Get list of valid target types from Get-JCAssociation
                $ValidTargetTypes = (Get-Command Get-JCAssociation -ArgumentList:($SourceTypeMap.Value)).Parameters.TargetType.Attributes.ValidValues
                # Lookup file names in $JcTypesMap
                ForEach ($ValidTargetType In $ValidTargetTypes)
                {
                    $TargetTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Value -eq $ValidTargetType }
                    # If the valid target type matches a file name look up the associations for the SourceType and TargetType
                    If ($TargetTypeMap.Key -in $BackupFiles.BaseName)
                    {
                        $AssociationJobs += Start-Job -ScriptBlock:( { Param ($SourceTypeMap, $TargetTypeMap, $TempPath, $BackupFile);
                                $AssociationResults = @()
                                # Get content from the file
                                $BackupRecords = Get-Content -Path:($BackupFile.FullName) | ConvertFrom-Json
                                ForEach ($BackupRecord In $BackupRecords)
                                {
                                    # Build Command based upon source and target combinations
                                    $Command = If (($SourceTypeMap.Value -eq 'system' -and $TargetTypeMap.Value -eq 'system_group') -or ($SourceTypeMap.Value -eq 'user' -and $TargetTypeMap.Value -eq 'user_group'))
                                    {
                                        'Get-JcSdk{0}Member -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id
                                    }
                                    ElseIf (($SourceTypeMap.Value -eq 'system_group' -and $TargetTypeMap.Value -eq 'system') -or ($SourceTypeMap.Value -eq 'user_group' -and $TargetTypeMap.Value -eq 'user'))
                                    {
                                        'Get-JcSdk{0}Membership -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id
                                    }
                                    Else
                                    {
                                        'Get-JcSdk{0}Association -{0}Id:("{1}") -Targets:("{2}")' -f $SourceTypeMap.Key, $BackupRecord.id, $TargetTypeMap.Value
                                    }
                                    # *Group commands take "GroupId" as a parameter vs "{Type}Id"
                                    $Command = $Command.Replace('UserGroupId', 'GroupId').Replace('SystemGroupId', 'GroupId').Replace('SystemUser', 'User')
                                    Write-Debug ("Running: $Command")
                                    $AssociationResults += Invoke-Expression -Command:($Command) | ConvertTo-Json -Depth:(100)
                                }
                                $AssociationResults | Out-File -FilePath:("$($TempPath)/$($SourceTypeMap.Key)-$($TargetTypeMap.Key)-Association.json") -Force
                            }) -ArgumentList:($SourceTypeMap, $TargetTypeMap, $TempPath, $BackupFile)
                    }
                }
                # # Write out the results
                # If (-not [System.String]::IsNullOrEmpty($AssociationResults))
                # {
                #     # Manifest: Populate backupFiles value
                #     $backupFiles = @{
                #         backupType     = "$($BackupFile.BaseName)"
                #         backupLocation = "./$($BackupFile.BaseName)-Association.json"
                #     }
                #     Return $backupFiles
                # }
            }
            $AssociationJobsStatus = Wait-Job -Id:($AssociationJobs.Id)
            $AssociationResults = $AssociationJobsStatus | Receive-Job
            # Manifest: Populate backupFiles value
            $manifest.associationFiles += $AssociationResults
            $sw.Stop()
            Write-Host ("Association Run Time: $($sw.Elapsed)") -BackgroundColor Cyan
        }
    }
    End
    {
        # Write Out Manifest
        $Manifest | ConvertTo-Json -Depth:(100) | Out-File -FilePath:("$($TempPath)/BackupManifest.json") -Force
        # Zip results
        Compress-Archive -Path:($TempPath) -CompressionLevel:('Fastest') -Destination:($ArchivePath)
        # Clean up temp directory
        If (Test-Path -Path:($ArchivePath))
        {
            Remove-Item -Path:($TempPath) -Force -Recurse
            Write-Host ("Backup Success: $($ArchivePath)") -ForegroundColor:('Green')
        }
    }
}
