Write-Host "🚀 Starting monitoring..." - ForegroundColor DarkCyan
while($true){
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] Monitoring..." -ForegroundColor Green

    $services = @{
        "order-service" = "https://order-service-app.greenrock-aca3581c.westus.azurecontainerapps.io/health"
        "driver-service" = "https://driver-service-app.greenrock-aca3581c.westus.azurecontainerapps.io/health"
    }
    foreach ($name in $services.Keys){
        try {
            $response = Invoke-RestMethod -Uri $services[$name] -Method Get 
            Write-Host " ✅  $name -> $($response.status)" - ForegroundColor Green
        }
        catch {
            Write-Host " ❌  $name -> Unhealthy" -ForegroundColor Red
        }

    }

    Write-Host "⏳ Next check in 5 minutes..." -ForegroundColor Yellow
    Start-Sleep -Seconds 300
    
}