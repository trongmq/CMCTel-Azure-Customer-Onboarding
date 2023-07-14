# Chạy powershell với quyền administrator
Param([switch]$Elevated)
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false)  {
    if ($elevated) {
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}
'Powershell dang chay voi quyen Administrator'
'
Dang cai dat cac module can thiet
'
# Cài đặt Powershell 7.3 và cài đặt Az Module
winget install --id Microsoft.Powershell --source winget
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module -Name Az -Repository PSGallery -Force
# Import Azure PowerShell module
Import-Module Az
# Update Azure PowerShell module
Update-Module Az.Resources
$azureContext = Disable-AzContextAutosave -Scope Process
Clear-AzContext
$azureAccount = Connect-AzAccount
Get-AzSubscription
'
'
$azureSubscriptions = Get-AzSubscription
Start-Sleep -Seconds 1
$azureSubscriptionCounter = 1
Start-Sleep -Seconds 1
foreach ($azureSubscription in $azureSubscriptions) {
    Write-Output "($azureSubscriptionCounter) $($azureSubscription.Name)"
    $azureSubscriptionCounter++;
}
Start-Sleep -Seconds 1
$subscriptionNumber = Read-Host 'Chon Subscription'
$subscription = Select-AzSubscription -SubscriptionId $azureSubscriptions[$subscriptionNumber - 1].Id
Start-Sleep -Seconds 1
'
Subscription da chon
'
Get-AzContext
Start-Sleep -Seconds 1
'
Dang ky quyen cho CMC Telecom
'
New-AzSubscriptionDeployment -Name CMCTelRoleAssignment `
                 -Location southeastasia `
                 -TemplateUri "https://raw.githubusercontent.com/trongmq/CMCTel-Azure-Customer-Onboarding/main/CMCTel-managed-service-delegated-role-assignment.json" `
                 -TemplateParameterUri "https://raw.githubusercontent.com/trongmq/CMCTel-Azure-Customer-Onboarding/main/CMCTel-managed-service-delegated-role-assignment.parameters.json?token=GHSAT0AAAAAACEF7FTDPMTDWDPKXLETULESZFNBHWQ" `
                 -Verbose
Start-Sleep -Seconds 1
'
Tao cac tai nguyen can thiet
'
New-AzResourceGroup `
    -Name CMCTel_CostAlert `
    -Location "Southeast Asia" `
    -Tag @{Empty=$null; CreatedBy="trong.mq@cmctelecom"}
'
Da tao resource group: CMCTel_CostAlert
'
Start-Sleep -Seconds 1
$resourceGroupName="CMCTel_CostAlert"
$actionGroupName="cmctel-actiongroup"
$actionshortName="cmctel-ag"
$tag = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.String]" 
$tag.Add('CreatedBy', 'trong.mq@cmctelecom')
$webhookReceiver = New-AzActionGroupReceiver `
    -Name 'cmctel-webook' `
    -WebhookReceiver `
    -ServiceUri 'https://okzpg7ajkqvlwg3ftxqfvx73vm0iqaqb.lambda-url.us-east-1.on.aws/'
Start-Sleep -Seconds 1
Set-AzActionGroup `
    -Name $actionGroupName `
    -ResourceGroup $resourceGroupName `
    -ShortName $actionshortName `
    -Receiver $webhookReceiver
'
Da tao action group: cmctel-actiongroup
'
Start-Sleep -Seconds 1
New-AzSubscriptionDeployment -Name CMCTelRoleAssignment `
                 -Location southeastasia `
                 -TemplateUri "https://raw.githubusercontent.com/trongmq/CMCTel-Azure-Customer-Onboarding/main/CMCTel-managed-service-billing-resources.json"
Start-Sleep -Seconds 1
'
Da tao budget: CMCTelBillingService_Monthly_Budget
'
'
Successfully onboarding!
'