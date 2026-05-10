Write-Host "📊 Azure Delivery App Rapport" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "📅 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# ✅ Container Apps
Write-Host "🐳 Container Apps:" -ForegroundColor Yellow
$apps = @("order-service-app", "driver-service-app")
foreach ($app in $apps) {
  $status = az containerapp show `
    --name $app `
    --resource-group vijaya-rg-container-apps `
    --query "properties.runningStatus" -o tsv
  Write-Host "  ✅ $app → $status" -ForegroundColor Green
}

Write-Host ""

# 📨 Event Hubs
Write-Host "📨 Event Hubs:" -ForegroundColor Yellow
$ehStatus = az eventhubs namespace show `
  --name vijaya-eh12-namespace `
  --resource-group vijaya-rg-container-apps `
  --query "properties.status" -o tsv
Write-Host "  ✅ vijaya-eh12-namespace → $ehStatus" -ForegroundColor Green

Write-Host ""

# 🗄️ PostgreSQL
Write-Host "🗄️ PostgreSQL:" -ForegroundColor Yellow
$dbStatus = az postgres flexible-server show `
  --name vijaya-postgresql `
  --resource-group vijaya-rg-container-apps `
  --query "state" -o tsv
Write-Host "  ✅ vijaya-postgresql → $dbStatus" -ForegroundColor Green

Write-Host ""

# 📍 Drivers in database
Write-Host "📍 Drivers in database:" -ForegroundColor Yellow
$drivers = Invoke-RestMethod `
  -Uri "https://driver-service-app.greenrock-aca3581c.westus.azurecontainerapps.io/drivers" `
  -Method Get
Write-Host "  🚗 Active drivers: $($drivers.drivers.Count)" -ForegroundColor Green
foreach ($driver in $drivers.drivers) {
  Write-Host "    → $($driver.driver_name) | lat: $($driver.lat) | lng: $($driver.lng)" -ForegroundColor Gray
}

Write-Host ""

# 🔐 Key Vault
Write-Host "🔐 Key Vault:" -ForegroundColor Yellow
$secrets = az keyvault secret list `
  --vault-name vijaya-keyvault `
  --query "length(@)" -o tsv
Write-Host "  ✅ vijaya-keyvault → $secrets secrets" -ForegroundColor Green

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Rapport klaar!" -ForegroundColor Green