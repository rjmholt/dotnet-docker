function Log
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromRemainingArguments)]
        $InputObject
    )

    # Write-Host does not pollute the pipeline
    $InputObject | Write-Host
}

function Exec
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Exe,

        [Parameter(ValueFromRemainingArguments)]
        [object[]]
        $Args
    )

    Log "Executing: '$Exe $Args'"

    & $Exe @Args

    if ($LASTEXITCODE -ne 0)
    {
        throw "Invocation '$Exe $Args' failed with exit code $LASTEXITCODE. Check previous errors for details"
    }
}
