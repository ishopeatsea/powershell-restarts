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