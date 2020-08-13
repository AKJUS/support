. ($PSScriptRoot + '/' + 'Get-Config.ps1')
###########################################################################
Invoke-GitClone -Repo:($GitSourceRepoWiki)
$SupportRepoDocs = "$FolderPath_Module/Docs"
$SupportWiki = "$ScriptRoot/support.wiki"
If (!(Test-Path -Path:($SupportWiki))) { New-Item -Path:($SupportWiki) -ItemType:('Directory') }
Set-Location -Path:($SupportWiki)
$Docs = Get-ChildItem -Path:($SupportRepoDocs + '/*.md') -Recurse
ForEach ($Doc In $Docs)
{
    $DocName = $Doc.Name
    $DocFullName = $Doc.FullName
    $SupportWikiDocFullName = $SupportWiki + '/' + $DocName
    $DocContent = Get-Content -Path:($DocFullName)
    If (Test-Path -Path:($SupportWikiDocFullName))
    {
        $SupportWikiDocContent = Get-Content -Path:($SupportWikiDocFullName)
        $Diffs = Compare-Object -ReferenceObject:($DocContent) -DifferenceObject:($SupportWikiDocContent)
        If ($Diffs)
        {
            Write-Warning -Message:('Diffs found in: ' + $DocName)
        }
    }
    Else
    {
        Write-Warning -Message:('Creating new file: ' + $DocName)
    }
    $NewDocContent = If (($DocContent | Select-Object -First 1) -eq '---')
    {
        $DocContent | Select-Object -Skip:(7)
    }
    Else
    {
        $DocContent
    }
    Set-Content -Path:($SupportWikiDocFullName) -Value:($NewDocContent) -Force
}
# Check in changes to support wiki
Invoke-GitCommit -BranchName:($GitSourceRepoWiki)
