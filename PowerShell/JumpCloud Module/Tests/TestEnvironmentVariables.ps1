# Install Pester
Install-Module -Name:('Pester') -Force -Scope:('CurrentUser') -SkipPublisherCheck
# Import the module
Import-Module -Name:($ModuleManifestPath) -Force
#Load private functions
Get-ChildItem -Path:("$PSScriptRoot/../Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
# Set test parameters
# $PesterParams = @{
#     # Specific to MTP portal
#     'SingleTernateOrgId' = '5a4bff7ab17d0c9f63bcd277'
#     'MultiTernateOrgId1' = "5b5a13f06fefdb0a29b0d306"
#     'MultiTernateOrgId2' = "5b5a14d13f852310b1d689b1"
#     'SystemID'           = '5e4c67d7933afe1cd17a6583' # Enter the System ID for a linux system
#     'SystemId_Windows'   = '5d24be43c9448f245effa736'
#     'SystemId_Mac'       = '5d24af30e72dab44aee39426'
#     'Username'           = 'pester.tester' # Create a user with username 'pester.tester'
#     'UserID'             = '5a4c0216fbd238d531f253a6' # Paste the UserID for the user with username pester.tester
#     'UserGroupName'      = 'PesterTest_UserGroup'  #Create a user group named PesterTest_UserGroup within your environment
#     'UserGroupID'        = '5a4f72bcc911807e553dfa1b'  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup
#     'SystemGroupName'    = 'PesterTest_SystemGroup' # Create a sytem group named PesterTest_SystemGroup within your environment
#     'SystemGroupID'      = '5a4fe3df45886d6c62ee188f'  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup
#     'CommandID'          = '5a4fe5c149812520079d1e7a'
#     'RadiusServerName'   = 'PesterTest_RadiusServer';
#     # Specific to pester environment
#     'OneTrigger'         = 'onetrigger'
#     'TwoTrigger'         = 'twotrigger'
#     'ThreeTrigger'       = 'threetrigger'
#     # Command Deployments
#     'SetCommandID'       = "5b7194548781bb466496fe2f"
#     'DeployCommandID'    = "5b719043bc43db696b4dbd90"
# }
$PesterParams = @{
    # Specific to MTP portal
    'SingleTernateOrgId' = '5eb2ebea87b5ba160c16857a'
    'MultiTernateOrgId1' = "5b5a13f06fefdb0a29b0d306" #CURRENTLY NOT UNIQUE
    'MultiTernateOrgId2' = "5b5a14d13f852310b1d689b1" #CURRENTLY NOT UNIQUE
    'SystemID'           = '5ec40d537b7ff91360386bc4' # Enter the System ID for a linux system
    'SystemId_Windows'   = '5ec300ed58c6c807bbde5712'
    'SystemId_Mac'       = '5ec3f0ad518f1814e2b1aee5'
    'Username'           = 'pester.tester' # Create a user with username 'pester.tester'
    'UserID'             = '5ec30ef936119c0892d550e1' # Paste the UserID for the user with username pester.tester
    'UserGroupName'      = 'PesterTest_UserGroup'  #Create a user group named PesterTest_UserGroup within your environment
    'UserGroupID'        = '5ec30f201f247540bf7e2159'  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup
    'SystemGroupName'    = 'PesterTest_SystemGroup' # Create a sytem group named PesterTest_SystemGroup within your environment
    'SystemGroupID'      = '5ec30f77232e1156647f2ff3'  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup
    'CommandID'          = '5ec44422bb57ae79a5d0ef1a'
    'RadiusServerName'   = 'PesterTest_RadiusServer';
    # Specific to pester environment
    'OneTrigger'         = 'onetrigger'
    'TwoTrigger'         = 'twotrigger'
    'ThreeTrigger'       = 'threetrigger'
    # Command Deployments
    'SetCommandID'       = "5ec32eafe5d32c2970a483fc"
    'DeployCommandID'    = "5ec32efb5a797e17deda0551"
}

$Random = New-RandomString '8'
$RandomEmail = "$Random@$Random.com"
# CSV Files
$Import_JCUsersFromCSV_1_1_Tests = "$PSScriptRoot/Csv_Files/import/ImportExample_Pester_Tests_1.1.0.csv" # This CSV file is specific to pester environment (SystemID's and Group Names)
$JCDeployment_2_CSV = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_2.csv"
$JCDeployment_10_CSV = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_10.csv"
$ImportPath = "$PSScriptRoot/Csv_Files/import"
$UpdatePath = "$PSScriptRoot/Csv_Files/update"
# Authenticate to JumpCloud
Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
# Policy Info
$MultiplePolicyList = @('1 Linux', 'Disable USB Storage - Linux') #Populate with multiple policy names.
$SinglePolicyList = @('Disable USB Storage - Linux') #Populate with single policy name.
$SystemIDWithPolicyResult = Get-JCSystem -SystemID '5a4c05ccaad9ac5f68b31022'
$Policies = Get-JCPolicy
$SinglePolicy = $Policies | Where-Object { $_.Name -eq $SinglePolicyList }
$MultiplePolicy = $Policies | Where-Object { $_.Name -in $MultiplePolicyList }