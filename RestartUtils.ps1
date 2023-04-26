function Get-LabsloggerObjects
{
    $PcList = @()


    ## Collect GAC computer objects

    $GACWebResponse = Invoke-WebRequest https://labslogger.feit.uts.edu.au/faclabs/reports/gachealth.html
    $table = $GACWebResponse.ParsedHtml.getElementsByTagName('table')[0]
    $titles = @()
    $rows = @($table.Rows)

    foreach($row in $rows) # source: https://www.leeholmes.com/extracting-tables-from-powershells-invoke-webrequest/
    {
        $cells = @($row.Cells)

        if ($cells[0].tagName -like "TH")
        {
            $titles = @($cells | % { ("" + $_.InnerText) })
            continue
        }

        $resultObject = [Ordered] @{}

        for ($counter = 0; $counter -lt $cells.Count; $counter++)
        {
            $title = $titles[$counter]
            $resultObject[$title] = ("" + $cells[$counter].InnerText)
        }

        $PcList += [PSCustomObject] $resultObject
    }


    ## Collect FEIT computer objects

    $FEITWebResponse = Invoke-WebRequest https://labslogger.feit.uts.edu.au/faclabs/reports/labhealth.html
    $table = $FEITWebResponse.ParsedHtml.getElementsByTagName('table')[0]
    $titles = @()
    $rows = @($table.Rows)

    foreach($row in $rows) # source: https://www.leeholmes.com/extracting-tables-from-powershells-invoke-webrequest/
    {
        $cells = @($row.Cells)

        if ($cells[0].tagName -like "TH")
        {
            $titles = @($cells | % { ("" + $_.InnerText) })
            continue
        }

        $resultObject = [Ordered] @{}

        for ($counter = 0; $counter -lt $cells.Count; $counter++)
        {
            $title = $titles[$counter]
            $resultObject[$title] = ("" + $cells[$counter].InnerText)
        }

        $PcList += [PSCustomObject] $resultObject
    }

    return $PcList
}


function Restart-Individual
{
    # [CmdletBinding()]
    param (
    [PSCustomObject] $ComputerObject
    )

    if (Test-Connection -ComputerName $ComputerObject.'IP Address' -Count 1 -Quiet)
    {
        Restart-Computer -ComputerName $ComputerObject.'IP Address' -ErrorVariable errmsg -ErrorAction SilentlyContinue

        if ($errmsg -ne $null) 
        {
            return "$($ComputerObject.'Computer Name') failed: $(@($errmsg -split ':')[1].Trim())"
        }
        else {
            return "$($ComputerObject.'Computer Name') restarted."
        }
    }
    else {
        return "$($ComputerObject.'Computer Name') failed: Offline."
    }
}


function Restart-Multiple
{
    param (
    [PSCustomObject[]] $ComputerList,
    [switch] $Print
    )

    $Status = "Restarting $($ComputerList.Count) computers."
    $count = 0
    
    if ($Print) { Write-Host $Status }

    foreach ($ComputerObject in $ComputerList)
    {
        $Result = Restart-Individual $ComputerObject
        
        if ($Print) { Write-Result $Result }
    }
    
    $Status = "Restarted $count/$($ComputerList.Count) computers."
    if ($Print) { Write-Host $Status }
}


function Write-Result
{
    param (
    [string] $Result
    )

    if ($Result -like "*Restarted.")
    {
        Write-Host $Result -ForegroundColor Green
    }
    elseif ($Result -like "*other users logged on*")
    {
        Write-Host $Result -ForegroundColor Yellow
    }
    else {
        Write-Host $Result -ForegroundColor Red
    }
}

function SRTesting
{
    Write-Host "Retrieving data..."
    $ComputerObject = Get-LabsloggerObjects | where {$_.'Computer Name' -like "LAB0105000*"}
    Restart-Multiple $ComputerObject -Print
}

SRTesting