Function Get-JCCommandTarget {
    [CmdletBinding(DefaultParameterSetName = 'Systems')]
    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Systems', Position = 0, HelpMessage = 'The id value of the JumpCloud command. Use the command ''Get-JCCommand | Select-Object _id, name'' to find the "_id" value for all the JumpCloud commands in your tenant.')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Groups', Position = 0, HelpMessage = 'The id value of the JumpCloud command. Use the command ''Get-JCCommand | Select-Object _id, name'' to find the "_id" value for all the JumpCloud commands in your tenant.')]
        [Alias('_id', 'id')]
        [String]$CommandID,

        [Parameter(ParameterSetName = 'Groups', HelpMessage = 'A switch parameter to display any System Groups associated with a command.')]
        [switch]$Groups

    )

    begin {

        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {
            Connect-JConline
        }

        $Parallel = $JCParallel

        if ($Parallel) {
            Write-Debug 'Initilizing resultsArray'
            $resultsArrayList = [System.Collections.Concurrent.ConcurrentBag[object]]::new()
            Write-Debug 'Initilizing errorResults for Parallel error catching'
            $errorResults = [System.Collections.Concurrent.ConcurrentQueue[Exception]]::new()
        } else {
            Write-Debug 'Initilizing resultsArray'
            $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
        }

        if ($PSCmdlet.ParameterSetName -eq 'Groups') {
            Write-Debug 'Populating SystemGroupNameHash'
            $SystemGroupNameHash = Get-Hash_ID_SystemGroupName
        }

        if ($PSCmdlet.ParameterSetName -eq 'Systems') {
            Write-Debug 'Populating SystemDisplayNameHash'
            $SystemDisplayNameHash = Get-Hash_SystemID_DisplayName

            Write-Debug 'Populating SystemIDHash'
            $SystemHostNameHash = Get-Hash_SystemID_HostName
        }

        Write-Debug 'Populating CommandNameHash'
        $CommandNameHash = Get-Hash_CommandID_Name

        Write-Debug 'Populating CommandTriggerHash'
        $CommandTriggerHash = Get-Hash_CommandID_Trigger

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing RawResults'
        $RawResults = @()

        Write-Debug "parameter set: $($PSCmdlet.ParameterSetName)"
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            Systems {
                $SystemURL = "$JCUrlBasePath/api/v2/commands/$CommandID/systems"
                Write-Debug $SystemURL
                if ($Parallel) {
                    # Parallel API call and resultsArrayList generation
                    $rawResults = Get-JCResults -Url $SystemURL -Method "GET" -limit $limit -parallel $true
                    $rawResults | ForEach-Object -Parallel {
                        $errorResults = $using:errorResults
                        $resultsArrayList = $using:resultsArrayList
                        try {
                            # Get stored hash in each parallel thread
                            $CommandNameHash = $using:CommandNameHash
                            $CommandTriggerHash = $using:CommandTriggerHash
                            $SystemHostNameHash = $using:SystemHostNameHash
                            $SystemDisplayNameHash = $using:SystemDisplayNameHash

                            # resultsArrayList generation
                            $CommandName = $CommandNameHash.($using:CommandID)
                            $Trigger = $CommandTriggerHash.($using:CommandID)
                            $SystemID = $_.id
                            $Hostname = $SystemHostNameHash.($SystemID)
                            $Displyname = $SystemDisplayNameHash.($SystemID)

                            $CommandTargetSystem = [pscustomobject]@{
                                'CommandID'   = $using:CommandID
                                'CommandName' = $CommandName
                                'trigger'     = $Trigger
                                'SystemID'    = $SystemID
                                'DisplayName' = $Displyname
                                'HostName'    = $Hostname
                            }

                            $resultsArrayList.Add($CommandTargetSystem) | Out-Null
                        } catch {
                            $errorResults.Enqueue($_.ToString())
                        } # End try/catch
                        # if parallel threads encountered error - throw
                        if (!$errorResults.IsEmpty) {
                            throw [AggregateException]::new($errorResults)
                        }
                    } # End Parallel
                } else {
                    # Sequential API call and resultsArrayList generation
                    $rawResults = Get-JCResults -Url $SystemURL -Method "GET" -limit $limit
                    foreach ($result in $RawResults) {
                        # resultsArrayList generation
                        $CommandName = $CommandNameHash.($CommandID)
                        $Trigger = $CommandTriggerHash.($CommandID)
                        $SystemID = $result.id
                        $Hostname = $SystemHostNameHash.($SystemID)
                        $Displyname = $SystemDisplayNameHash.($SystemID)

                        $CommandTargetSystem = [pscustomobject]@{
                            'CommandID'   = $CommandID
                            'CommandName' = $CommandName
                            'trigger'     = $Trigger
                            'SystemID'    = $SystemID
                            'DisplayName' = $Displyname
                            'HostName'    = $Hostname
                        }

                        $resultsArrayList.Add($CommandTargetSystem) | Out-Null
                    } # end parallel foreach
                } # End if else parallel
            } # end Systems switch
            Groups {
                $SystemGroupsURL = "$JCUrlBasePath/api/v2/commands/$CommandID/systemgroups"
                Write-Debug $SystemGroupsURL
                if ($Parallel) {
                    $rawResults = Get-JCResults -Url $SystemGroupsURL -Method "GET" -limit $limit -parallel $true
                    $rawResults | ForEach-Object -Parallel {
                        $errorResults = $using:errorResults
                        $resultsArrayList = $using:resultsArrayList
                        try {
                            # Get stored hash in each parallel thread
                            $CommandNameHash = $using:CommandNameHash
                            $SystemGroupNameHash = $using:SystemGroupNameHash

                            # resultsArrayList generation
                            $CommandName = $CommandNameHash.($using:CommandID)
                            $GroupID = $_.id
                            $GroupName = $SystemGroupNameHash.($GroupID)

                            $Group = [pscustomobject]@{
                                'CommandID'   = $using:CommandID
                                'CommandName' = $CommandName
                                'GroupID'     = $GroupID
                                'GroupName'   = $GroupName
                            }

                            $resultsArrayList.Add($Group) | Out-Null
                        } catch {
                            $errorResults.Enqueue($_.ToString())
                        } # End try/catch
                    } # end parallel foreach
                    # if parallel threads encountered error - throw
                    if (!$errorResults.IsEmpty) {
                        throw [AggregateException]::new($errorResults)
                    }
                } else {
                    # Sequential API call and resultsArrayList generation
                    $rawResults = Get-JCResults -Url $SystemGroupsURL -Method "GET" -limit $limit
                    foreach ($result in $RawResults) {
                        # resultsArrayList generation
                        $CommandName = $CommandNameHash.($CommandID)
                        $GroupID = $result.id
                        $GroupName = $SystemGroupNameHash.($GroupID)

                        $Group = [pscustomobject]@{

                            'CommandID'   = $CommandID
                            'CommandName' = $CommandName
                            'GroupID'     = $GroupID
                            'GroupName'   = $GroupName

                        }

                        $resultsArrayList.Add($Group) | Out-Null
                    } # end foreach
                } # end if/else parallel
            } # end Groups switch
        } # end switch
    } # end process

    end {
        switch ($PSCmdlet.ParameterSetName) {
            Systems {
                return $resultsArrayList | Sort-Object Displayname
            }
            Groups {
                return $resultsArrayList | Sort-Object GroupName
            }
        } # end switch
    } # end
}