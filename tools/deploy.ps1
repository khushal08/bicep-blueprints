bicep build src/module/web-app/main.bicep --outdir build/module/web-app/

Connect-AzAccount
Get-AzContext
Get-AzSubscription
Set-AzContext -Subscription "XXXXXXXX"

Get-AzAppServicePlan -ResourceGroupName "webapp03" | Select-Object -Property Name, ResourceGroup, Id
Get-AzAppServiceEnvironment -ResourceGroupName "webapp03" -Name "webapp03ase" | Select-Object -Property Name, Id

# Linux based ASP for Nodejs app
New-AzAppServicePlan -ResourceGroupName "webapp03" `
    -Name "webapp03LinuxASP" `
    -Tier "Isolated" `
    -Location "AustraliaEast" `
    -AseName "webapp03ase" `
    -WorkerSize "Small" `
    -NumberOfWorkers "1" `
    -Linux

New-AzWebApp -ResourceGroupName "webapp03" `
    -Name "webapp03nodejs" `
    -Location "Australia East" `
    -AppServicePlan "webapp03LinuxASP" 
