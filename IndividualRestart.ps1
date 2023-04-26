# Written by daniel angeloni

while(1) {

    $ComputerName = Read-Host -Prompt 'Computer Name or IP Address'

    if ($ComputerName -like "exit")
    {
        break
    }

    Restart-Computer -ComputerName $ComputerName -ErrorVariable errmsg -ErrorAction SilentlyContinue

    if ($errmsg -ne $null)
    {
        if ($errmsg -like "*other users logged on*")
        {
            Write-Host "$($Pc.'Computer Name') failed: $(@($errmsg -split ':')[1].Trim())" -ForegroundColor yellow
        }
        else {
            Write-Host "$($Pc.'Computer Name') failed: $(@($errmsg -split ':')[1].Trim())" -ForegroundColor red
        }
    }
    else {
        Write-Host "$ComputerName restarted." -ForegroundColor green
    }
}