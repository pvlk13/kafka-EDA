Write-Host "Performing health check for the application..." - ForegroundColor Cyan
$services = @{
    "order-service" = "https://order-service-app.greenrock-aca3581c.westus.azurecontainerapps.io/health"
    "driver-service" = "https://driver-service-app.greenrock-aca3581c.westus.azurecontainerapps.io/health"
}
foreach ($name in $services.Keys) {
    try {
        $response = Invoke-RestMethod -Uri $services[$name] -Method Get 
        Write-Host " ✅  $name -> $($response.status)" - ForegroundColor Green
        }
    catch {
        Write-Host " ❌  $name -> Health check failed: $($_.Exception.Message)" - ForegroundColor Red
    }
}

Write-Host "Health check completed." - ForegroundColor Cyan

Write-Host " 🔍 Invoking database health check..." - ForegroundColor Cyan
$drivers = Invoke-RestMethod -Uri "https://driver-service-app.greenrock-aca3581c.westus.azurecontainerapps.io/drivers" -Method Get
Write-Host " 🚗 Total drivers in database: $($drivers.drivers.Count)" - ForegroundColor Green

foreach($driver in $drivers.drivers) {
    Write-Host "  🚗 $($driver.driver_name) → lat: $($driver.lat), lng: $($driver.lng)" -ForegroundColor Yellow
}