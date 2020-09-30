#!/usr/bin/env pwsh
param (
    [string] $Repo,
    [string] $ReadmePath,
    [string] $Manifest,
    [string] $GitRepo,
    [string] $Branch = "master",
    [switch] $ReuseImageBuilderImage,
    [switch] $Validate
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Get-Item "$PSScriptRoot").Parent.Parent.FullName

Import-Module "$PSScriptRoot/ScriptTools.psm1"

$onTagsGenerated = {
    param($ContainerName)

    if (-Not $Validate) {
        Exec docker cp "${ContainerName}:/repo/$ReadmePath" "$repoRoot/$ReadmePath"
    }
}

$imageBuilderArgs = @(
    'generateTagsReadme'
    '--manifest', $Manifest
    '--repo', $Repo
    '--source-branch', $Branch
    if ($Validate) { $customImageBuilderArgs }
    $GitRepo
)

& $PSScriptRoot/Invoke-ImageBuilder.ps1 `
    -ImageBuilderArgs $imageBuilderArgs `
    -ReuseImageBuilderImage:$ReuseImageBuilderImage `
    -OnCommandExecuted $onTagsGenerated
