#!/usr/bin/env pwsh
param(
    [switch]$Validate
)

$repoRoot = (Get-Item "$PSScriptRoot").Parent.Parent.FullName

$onDockerfilesGenerated = {
    param($ContainerName)

    if (-Not $Validate) {
        Exec docker cp "${ContainerName}:/repo/src" $repoRoot
    }
}

$imageBuilderArgs = @(
    'generateDockerFiles'
    '--architecture', '*'
    '--os-type', '*'
    if ($Validate) { '--validate' }
)

& $PSScriptRoot/../common/Invoke-ImageBuilder.ps1 `
    -ImageBuilderArgs $imageBuilderArgs
    -OnCommandExecuted $onDockerfilesGenerated
