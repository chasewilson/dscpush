﻿#Requires -Version 5.1 -RunAsAdministrator

param
(
    [Parameter()]
    [string]
    $BranchName = "AddFeatures",

    [Parameter()]
    [string]
    $GithubDownloadUrl = "http://github.com/devopsjesus/dscpush/archive/$BranchName.zip",

    [Parameter()]
    [string]
    $DscPushModulePath = "$env:USERPROFILE\Documents\dscpush-$BranchName.zip",

    [Parameter()]
    [string]
    $WorkshopPath = "C:\DscPushWorkshop",

    [Parameter()]
    [array]
    $RequiredDscResources = @(
        "xActiveDirectory"
        "xComputerManagement"
        "xDnsServer"
        "xNetworking"
    )
)

$ProgressPreference = "SilentlyContinue"

Write-Verbose "Creating root workshop directory"
$null = New-Item -Path $WorkshopPath -ItemType Directory -Force -ErrorAction Stop

$currentDir = (Get-Item .).FullName

#Download DscPush from GitHub and copy to $WorkshopPath
Write-Verbose "Downloading repo from GitHub and extracting to C:\DscPushWorkshop"

#Requires -module BitsTransfer
Start-BitsTransfer -Source $GithubDownloadUrl -Destination $DscPushModulePath

#$wc = New-Object System.Net.WebClient
#$wc.DownloadFile($GithubDownloadUrl, $DscPushModulePath)
#$null = Invoke-WebRequest -Uri $GithubDownloadUrl -OutFile $DscPushModulePath
Expand-Archive $DscPushModulePath -DestinationPath $WorkshopPath -Force
Copy-Item -Path "$WorkshopPath\dscpush-$BranchName\DSCPushSetup" -Destination $WorkshopPath -Recurse -Force -ErrorAction Stop

#Copy DscPush module to Modules folder
Write-Verbose "Copying module to workshop Modules folder"
$null = New-Item -Path "$WorkshopPath\Modules" -ItemType Directory -Force
Copy-Item -Path "$WorkshopPath\dscpush-$BranchName\DSCPush" -Destination "$WorkshopPath\Modules" -Force -Recurse -ErrorAction Stop

#Copy SamplePartials to Partials folder
Write-Verbose "Copying partials to Partials folder"
$null = New-Item -Path "$WorkshopPath\Partials" -ItemType Directory -Force
Copy-Item -Path "$WorkshopPath\dscpush-$BranchName\SamplePartials\*" -Destination "$WorkshopPath\Partials" -Force -Recurse -ErrorAction Stop

#Remove GitHub source directory
Write-Verbose "Deleting extracted repo directory"
Remove-Item -Path "$workshopPath\dscpush-$BranchName" -Recurse -Force

#Install and configure required DSC Resources
Write-Verbose "Downloading and installing required DSC Resources"
$null = New-Item -Path "$WorkshopPath\Resources" -ItemType Directory -Force -ErrorAction Stop
$RequiredDscResources.ForEach({
    Write-Verbose "Installing Module $_"
    Install-Module $_ -Force
    $null = New-Item -Path "$WorkshopPath\Resources\$_" -ItemType Directory -Force
    Copy-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$_\*" -Destination "$WorkshopPath\Resources\$_" -Recurse -Force -ErrorAction Stop
})
