#!/usr/bin/env pwsh
param(
    [switch] $Validate,
    [string] $Branch
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Get-Item "$PSScriptRoot").Parent.Parent.FullName

$onDockerfilesGenerated = {
    param($ContainerName)

    if (-Not $Validate) {
        Import-Module "$PSScriptRoot/../common/ScriptTools.psm1"
        Exec docker cp "${ContainerName}:/repo/README.aspnet.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.aspnet.preview.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.monitor.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.runtime-deps.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.runtime-deps.preview.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.runtime.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.runtime.preview.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.samples.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.sdk.md" $repoRoot
        Exec docker cp "${ContainerName}:/repo/README.sdk.preview.md" $repoRoot
    }
}

function Invoke-GenerateReadme {
    param ([string] $Manifest, [string] $SourceBranch)

    $params = @{
        ImageBuilderArgs = @(
            'generateReadmes'
            '--manifest', $Manifest
            '--source-branch', $SourceBranch
            if ($Validate) { '--validate' }
            '--var', "branch=$SourceBranch"
            'https://github.com/dotnet/dotnet-docker'
        )
        OnCommandExecuted = $onDockerfilesGenerated
    }

    & $PSScriptRoot/../common/Invoke-ImageBuilder.ps1 @params
}

if (!$Branch) {
    $manifestJson = Get-Content ${repoRoot}/manifest.json | ConvertFrom-Json
    if ($manifestJson.Repos[0].Name.Contains("nightly")) {
        $Branch = "nightly"
    }
    else {
        $Branch = "master"
    }
}

Invoke-GenerateReadme "manifest.json" $Branch
Invoke-GenerateReadme "manifest.samples.json" "master"
