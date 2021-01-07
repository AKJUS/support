<#
.Synopsis
Backup your JumpCloud organization to local json files

.Description
This function exports objects and associations from your JumpCloud organization to local json files

.Example
Backup all available JumpCloud objects and their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -All

.Example
Backup UserGroups and SystemUsers with their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers') -Association

.Example
Backup UserGroups and SystemUsers without their associations
PS C:\> Backup-JCOrganization -Path:('C:\Temp') -Type:('UserGroup','SystemUsers')

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
        # Specify to backup all available types and associations
        ${All},

        [Parameter(ParameterSetName = 'Type')]
        [ValidateSet('ActiveDirectory', 'Application', 'Command', 'Directory', 'GSuite', 'LdapServer', 'Office365', 'Organization', 'Policy', 'RadiusServer', 'SoftwareApp', 'System', 'SystemGroup', 'SystemUser', 'UserGroup')]
        [System.String[]]
        # Specify the type of JumpCloud objects you want to backup
        ${Type},

        [Parameter(ParameterSetName = 'Type')]
        [switch]
        # Specify to backup association data
        ${Association}
    )
    Begin
    {
        $TimerTotal = [Diagnostics.Stopwatch]::StartNew()
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
        # If the backup directory does not exist, create it
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
            ActiveDirectory = [PSCustomObject]@{Name = 'active_directory'; AssociationTargets = @('user', 'user_group'); };
            Application     = [PSCustomObject]@{Name = 'application'; AssociationTargets = @('user', 'user_group'); };
            Command         = [PSCustomObject]@{Name = 'command'; AssociationTargets = @('system', 'system_group'); };
            Directory       = [PSCustomObject]@{Name = 'directory'; AssociationTargets = @(); };
            GSuite          = [PSCustomObject]@{Name = 'g_suite'; AssociationTargets = @( 'user', 'user_group'); };
            LdapServer      = [PSCustomObject]@{Name = 'ldap_server'; AssociationTargets = @('user', 'user_group'); };
            Office365       = [PSCustomObject]@{Name = 'office_365'; AssociationTargets = @('user', 'user_group'); };
            Organization    = [PSCustomObject]@{Name = 'organization'; AssociationTargets = @(); };
            Policy          = [PSCustomObject]@{Name = 'policy'; AssociationTargets = @( 'system', 'system_group'); };
            RadiusServer    = [PSCustomObject]@{Name = 'radius_server'; AssociationTargets = @('user', 'user_group'); };
            SoftwareApp     = [PSCustomObject]@{Name = 'software_app'; AssociationTargets = @( 'system', 'system_group'); };
            System          = [PSCustomObject]@{Name = 'system'; AssociationTargets = @( 'command', 'policy', 'user', 'user_group'); };
            SystemGroup     = [PSCustomObject]@{Name = 'system_group'; AssociationTargets = @( 'command', 'policy', 'user', 'user_group'); };
            SystemUser      = [PSCustomObject]@{Name = 'user'; AssociationTargets = @('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system', 'system_group'); };
            UserGroup       = [PSCustomObject]@{Name = 'user_group'; AssociationTargets = @('active_directory', 'application', 'g_suite', 'ldap_server', 'office_365', 'radius_server', 'system', 'system_group'); };
        }
    }
    Process
    {
        $TimerObject = [Diagnostics.Stopwatch]::StartNew()
        # Foreach type start a new job and retrieve object records
        $ObjectJobs = @()
        ForEach ($JumpCloudType In $Types)
        {
            $SourceTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Key -eq $JumpCloudType }
            $ObjectJobs += Start-Job -ScriptBlock:( { Param ($TempPath, $SourceTypeMap);
                    # Logic to handle directories
                    $Command = If ($SourceTypeMap.Key -eq 'GSuite')
                    {
                        $DirectoryCommand = "Get-JcSdkDirectory | Where-Object { `$_.Type -eq '$($SourceTypeMap.Value.Name)' }"
                        Write-Debug ("Running: $DirectoryCommand")
                        $Directory = Invoke-Expression -Command:($DirectoryCommand)
                        "Get-JcSdk{0} -Id:('{1}')" -f $SourceTypeMap.Key, $Directory.Id
                    }
                    ElseIf ($SourceTypeMap.Key -eq 'Office365')
                    {
                        $DirectoryCommand = "Get-JcSdkDirectory | Where-Object { `$_.Type -eq '$($SourceTypeMap.Value.Name)' }"
                        Write-Debug ("Running: $DirectoryCommand")
                        $Directory = Invoke-Expression -Command:($DirectoryCommand)
                        "Get-JcSdk{0} -{0}Id:('{1}')" -f $SourceTypeMap.Key, $Directory.Id
                    }
                    ElseIf ($SourceTypeMap.Key -eq 'Organization')
                    {
                        "Get-JcSdk{0} -Id:('{1}')" -f $SourceTypeMap.Key, $env:JCOrgId
                    }
                    Else
                    {
                        "Get-JcSdk{0}" -f $SourceTypeMap.Key
                    }
                    Write-Debug ("Running: $Command")
                    $Result = Invoke-Expression -Command:($Command)
                    If (-not [System.String]::IsNullOrEmpty($Result))
                    {
                        # Write output to file
                        $Result `
                        | ConvertTo-Json -Depth:(100) `
                        | Out-File -FilePath:("{0}/{1}.json" -f $TempPath, $SourceTypeMap.Key) -Force
                        # TODO: Potential use for restore function
                        #| ForEach-Object { $_ | Select-Object *, @{Name = 'JcSdkModel'; Expression = { $_.GetType().FullName } } } `
                        # Build object to return data
                        $OutputObject = @{
                            Results        = $Result
                            Type           = $SourceTypeMap.Key
                            backupLocation = "./$($SourceTypeMap.Key).json"
                        }
                        Return $OutputObject
                    }
                }) -ArgumentList:($TempPath, $SourceTypeMap)
        }
        $ObjectJobStatus = Wait-Job -Id:($ObjectJobs.Id)
        $ObjectJobResults = $ObjectJobStatus | Receive-Job
        $manifest.backupFiles += $ObjectJobResults | Select-Object -ExcludeProperty:('Results')
        $TimerObject.Stop()
        # Foreach type start a new job and retreive object association records
        If ($PSBoundParameters.Association)
        {
            $AssociationJobs = @()
            $TimerAssociations = [Diagnostics.Stopwatch]::StartNew()
            # Get the backup files we created earlier
            $BackupFiles = Get-ChildItem -Path:($TempPath) | Where-Object { $_.BaseName -in $Types }
            ForEach ($BackupFile In $BackupFiles)
            {
                # Type mapping lookup
                $SourceTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Key -eq $BackupFile.BaseName }
                # TODO: Figure out how to make this work with x-ms-enum.
                # $ValidTargetTypes = (Get-Command Get-JcSdk$($SourceTypeMap.Key)Association).Parameters.Targets.Attributes.ValidValues
                # Get list of valid target types from Get-JCAssociation
                $ValidTargetTypes = $SourceTypeMap.Value.AssociationTargets
                # Lookup file names in $JcTypesMap
                ForEach ($ValidTargetType In $ValidTargetTypes)
                {
                    $TargetTypeMap = $JcTypesMap.GetEnumerator() | Where-Object { $_.Value.Name -eq $ValidTargetType }
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
                                    $Command = If (($SourceTypeMap.Value.Name -eq 'system' -and $TargetTypeMap.Value.Name -eq 'system_group') -or ($SourceTypeMap.Value.Name -eq 'user' -and $TargetTypeMap.Value.Name -eq 'user_group'))
                                    {
                                        'Get-JcSdk{0}Member -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id
                                    }
                                    ElseIf (($SourceTypeMap.Value.Name -eq 'system_group' -and $TargetTypeMap.Value.Name -eq 'system') -or ($SourceTypeMap.Value.Name -eq 'user_group' -and $TargetTypeMap.Value.Name -eq 'user'))
                                    {
                                        'Get-JcSdk{0}Membership -{0}Id:("{1}")' -f $SourceTypeMap.Key, $BackupRecord.id
                                    }
                                    Else
                                    {
                                        'Get-JcSdk{0}Association -{0}Id:("{1}") -Targets:("{2}")' -f $SourceTypeMap.Key, $BackupRecord.id, $TargetTypeMap.Value.Name
                                    }
                                    # *Group commands take "GroupId" as a parameter vs "{Type}Id"
                                    $Command = $Command.Replace('UserGroupId', 'GroupId').Replace('SystemGroupId', 'GroupId').Replace('SystemUser', 'User')
                                    Write-Debug ("Running: $Command")
                                    $AssociationResults += Invoke-Expression -Command:($Command) | ConvertTo-Json -Depth:(100)
                                }
                                If (-not [System.String]::IsNullOrEmpty($AssociationResults))
                                {
                                    $AssociationFileName = "Association-{0}To{1}" -f $SourceTypeMap.Key, $TargetTypeMap.Key
                                    $AssociationResults | Out-File -FilePath:("{0}/{1}.json" -f $TempPath, $AssociationFileName) -Force
                                    # Build object to return data
                                    $OutputObject = @{
                                        Results        = $AssociationResults
                                        Type           = $AssociationFileName
                                        backupLocation = "./$($AssociationFileName).json"
                                    }
                                    Return $OutputObject
                                }
                            }) -ArgumentList:($SourceTypeMap, $TargetTypeMap, $TempPath, $BackupFile)
                    }
                }
            }
            $AssociationJobsStatus = Wait-Job -Id:($AssociationJobs.Id)
            $AssociationResults = $AssociationJobsStatus | Receive-Job
            $manifest.associationFiles += $AssociationResults | Select-Object -ExcludeProperty:('Results')
            $TimerAssociations.Stop()
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
            Write-Host("Backup-JCOrganization Results:") -ForegroundColor:('Green')
            $ObjectJobResults | ForEach-Object {
                Write-Host ("$($_.Type): $($_.Results.Count)") -ForegroundColor:('Magenta')
            }
            $AssociationResults | ForEach-Object {
                Write-Host ("$($_.Type): $($_.Results.Count)") -ForegroundColor:('Magenta')
            }
        }
        $TimerTotal.Stop()
        If ($TimerObject) { Write-Debug ("Object Run Time: $($TimerObject.Elapsed)") }
        If ($TimerAssociations) { Write-Debug ("Association Run Time: $($TimerAssociations.Elapsed)") }
        If ($TimerTotal) { Write-Debug ("Total Run Time: $($TimerTotal.Elapsed)") }
    }
}