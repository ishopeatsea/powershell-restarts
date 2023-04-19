Write-Host "Retrieving data..."
$timesyncErrors = & $PSScriptRoot\getPcObjectsFromLabslogger.ps1 | where {($_.TimeSync -like "*error*") -and ($_.'Last Ping' -like "*Up")}
$total = $timesyncErrors.Count
Write-Host "Found $total timesync errors."
$count = 0

foreach ($Pc in $timesyncErrors)
{
    if (($Pc.'IP Address' -like "Expected:*") -or ($Pc.'IP Address' -like "*not match*")) { $Pc.'IP Address' = @($Pc.'IP Address' -split ':')[2].Trim() }

    # Attempt restart
    Restart-Computer -ComputerName $Pc.'IP Address' -ErrorVariable errmsg -ErrorAction SilentlyContinue

    if ($errmsg -ne $null) {
        # Error log: Restart failed
        if ($errmsg -like "*other users logged on*")
        {
            Write-Host "$($Pc.'Computer Name') failed: $(@($errmsg -split ':')[1].Trim())" -ForegroundColor yellow
        } else {
            Write-Host "$($Pc.'Computer Name') failed: $(@($errmsg -split ':')[1].Trim())" -ForegroundColor red
        }
    }
    else {
        # Success
        Write-Host "$($Pc.'Computer Name') restarted." -ForegroundColor green
        $count++
    }
}
Write-Host "Restarted $count/$total computers."