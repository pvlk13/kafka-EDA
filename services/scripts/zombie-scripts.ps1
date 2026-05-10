Write-Host "🔍 Checking for zombie resources..." -ForegroundColor Cyan

#Stopped containers
$stopped = docker ps -a --filter "status=exited" --format "{{.Names}}"

#Dangling images
$images = docker images -f "dangling=true" -q

#Unused volumes
$volumes = docker volume ls -f "dangling=true" -q

#Output
Write-Host "`n🧟 Stopped Containers:"
$stopped

Write-Host "`n🧟 Dangling Images:"
$images

Write-Host "`n🧟 Unused Volumes:"
$volumes

$results = @()

foreach ($container in $stopped) {
    $results += [PSCustomObject]@{
        Type = "Container"
        Name = $container
        Status = "Stopped"
    }
}

foreach ($image in $images) {
    $results += [PSCustomObject]@{
        Type = "Image"
        Name = $image
        Status = "Dangling"
    }
}

foreach ($volume in $volumes) {
    $results += [PSCustomObject]@{
        Type = "Volume"
        Name = $volume
        Status = "Unused"
    }
}

#Ensure logs directory exists
if (!(Test-Path "./logs")){
    New-Item -ItemType Directory -Path "./logs" | Out-Null
}

#Save reports 
$results | ConvertTo-Json | Set-Content "./logs/zombie_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$results | Export-Csv "./logs/zombie_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
$results | Format-Table -AutoSize | Out-File "./logs/zombie_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"   