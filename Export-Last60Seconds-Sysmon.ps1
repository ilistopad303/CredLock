# Output file
$OutCsv = "C:\Tools\RanLogCol\sysmon_last60seconds.csv"

# Ensure output directory exists
New-Item -ItemType Directory -Path (Split-Path $OutCsv) -Force | Out-Null

# Calculate time window (last 60 seconds)
$StartTime = (Get-Date).AddSeconds(-60)

# Get Sysmon events from last 60 seconds
$events = Get-WinEvent -FilterHashtable @{
    LogName   = "Microsoft-Windows-Sysmon/Operational"
    StartTime = $StartTime
}

# Convert events to structured objects
$rows = foreach ($e in $events) {

    [xml]$xml = $e.ToXml()
    $data = @{}
    foreach ($item in $xml.Event.EventData.Data) {
        $data[$item.Name] = $item.'#text'
    }

    [PSCustomObject]@{
        TimeCreated     = $e.TimeCreated
        EventId         = $e.Id
        RecordId        = $e.RecordId
        Computer        = $e.MachineName
        Image           = $data["Image"]
        CommandLine     = $data["CommandLine"]
        ParentImage     = $data["ParentImage"]
        User            = $data["User"]
        ProcessGuid     = $data["ProcessGuid"]
        ProcessId       = $data["ProcessId"]
        TargetFilename  = $data["TargetFilename"]
        DestinationIp   = $data["DestinationIp"]
        DestinationPort = $data["DestinationPort"]
    }
}

# Export to CSV (overwrite each run)
$rows | Export-Csv $OutCsv -NoTypeInformation -Encoding UTF8

Write-Host "Exported Sysmon events from last 60 seconds to $OutCsv"
