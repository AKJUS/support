Function Get-JCRadiusServer ()
{
    # This endpoint allows you to get a list of all RADIUS servers in your organization.
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ById', Position = 0)][ValidateNotNullOrEmpty()][Alias('_id', 'id')][string]$RadiusServerId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByName', Position = 0)][ValidateNotNullOrEmpty()][Alias('Name')][string]$RadiusServerName
    )
    Begin
    {
        $Type = 'radiusservers'
    }
    Process
    {
        # Create $FunctionParameters hashtable for splatting
        $FunctionParameters = [ordered]@{}
        # Get function parameters and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
        # Add parameters from the script to the FunctionParameters hashtable
        $FunctionParameters.Add('Type', $Type) | Out-Null
        If ($PSCmdlet.ParameterSetName -ne 'ReturnAll')
        {
            $FunctionParameters.Add('SearchBy', $PSCmdlet.ParameterSetName) | Out-Null
            # Rename parameters in the FunctionParameters hashtable
            If ($FunctionParameters.Contains('RadiusServerId'))
            {
                $FunctionParameters.Add('SearchByValue', $FunctionParameters['RadiusServerId']) | Out-Null
                $FunctionParameters.Remove('RadiusServerId') | Out-Null
            }
            If ($FunctionParameters.Contains('RadiusServerName'))
            {
                $FunctionParameters.Add('SearchByValue', $FunctionParameters['RadiusServerName']) | Out-Null
                $FunctionParameters.Remove('RadiusServerName') | Out-Null
            }
        }
        Write-Verbose ('Get-JCObject ' + ($FunctionParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        $Results = Get-JCObject @FunctionParameters
    }
    End
    {
        Return $Results
    }
}
# Get-JCRadiusServer -Verbose
# Get-JCRadiusServer -RadiusServerId:('5c5c371704c4b477964ab4fa') -Verbose
# Get-JCRadiusServer -RadiusServerName:('Test Me') -Verbose