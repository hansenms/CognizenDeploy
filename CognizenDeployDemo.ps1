param(
    [Parameter(Mandatory=$true,Position=1)]
    [String]$PayloadPath,

    [Parameter(Mandatory=$true,Position=2)]
    [string]$AdminUsername,

    [Parameter(Mandatory=$true,Position=3)]
    [string]$AdminPassword,

    [Parameter(Mandatory=$false,Position=4)]
    [ValidateSet("AzureCloud","AzureUsGovernment")]
    [String]$Environment = "AzureCloud"
)

$azcontext = Get-AzureRmContext
if ([string]::IsNullOrEmpty($azcontext.Account) -or
    !($azcontext.Environment.Name -eq $Environment)) 
{
    Login-AzureRmAccount -Environment $Environment        
}

$azcontext = Get-AzureRmContext

$timeStamp = get-date -uformat %Y%m%d%H%M%S

$ResourceGroupName = "Cognizen$timeStamp"
$StorageAccountName = "cognizensa$timeStamp"
$StorageContainerName = "cognizen"
$StorageBlobName = "cognizen.zip"
$DnsLabel = "cognizen$timestamp"

$Location = "eastus"
if ($Environment -eq "AzureUsGovernment") {
    $Location = "usgovvirginia"
}

$grp = New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location

$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS -Kind Storage -EnableEncryptionService Blob
$ctx = $storageAccount.Context

New-AzureStorageContainer -Name $StorageContainerName -Context $ctx -Permission blob

Set-AzureStorageBlobContent -File $PayloadPath -Container $StorageContainerName -Blob $StorageBlobName -Context $ctx
$deployBlob = "cognizen_deploy.sh"
Set-AzureStorageBlobContent -File ".\cognizen_deploy.sh" -Container $StorageContainerName -Blob $deployBlob -Context $ctx

$StartTime = Get-Date
$EndTime = $StartTime.AddHours(1.0)
$SASURI_payload = New-AzureStorageBlobSASToken -Container $StorageContainerName -Blob $StorageBlobName -Context $ctx -Permission "r" -StartTime $StartTime -ExpiryTime $EndTime -FullUri
$SASURI_setup = New-AzureStorageBlobSASToken -Container $StorageContainerName -Blob $deployBlob -Context $ctx -Permission "r" -StartTime $StartTime -ExpiryTime $EndTime -FullUri

$templateParameters = @{
    "adminUserName" = $AdminUsername
    "adminPassword" = $AdminPassword
    "dnsLabelPrefix" = $DnsLabel
    "vmSize" = "Standard_D4_v2"
    "setupScriptUri" = $SASURI_setup.ToString()
    "setupPayloadUri" = $SASURI_payload.ToString()
}

New-AzureRmResourceGroupDeployment -Name "cognizenDeploy" -ResourceGroupName $ResourceGroupName -TemplateFile .\azuredeploy.json -TemplateParameterObject $templateParameters