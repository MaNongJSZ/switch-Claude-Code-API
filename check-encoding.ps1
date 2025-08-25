# Encoding Issues Check and Fix Script
# Check and fix encoding issues

Write-Host "=== Claude Code API Encoding Check ===" -ForegroundColor Cyan
Write-Host ""

# Check config file
Write-Host "1. Checking config file encoding..." -ForegroundColor Yellow
try {
    $config = Get-Content "models.json" -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-Host "✅ models.json config file encoding is OK" -ForegroundColor Green
    Write-Host "   Number of models: $($config.models.PSObject.Properties.Count)" -ForegroundColor Gray
} catch {
    Write-Host "❌ models.json config file has encoding issues: $($_.Exception.Message)" -ForegroundColor Red
}

# Check Web files
Write-Host ""
Write-Host "2. Checking Web files..." -ForegroundColor Yellow

if (Test-Path "web\index.html") {
    try {
        $htmlContent = Get-Content "web\index.html" -Raw
        if ($htmlContent -match 'charset="UTF-8"') {
            Write-Host "✅ index.html UTF-8 encoding setting is correct" -ForegroundColor Green
        } else {
            Write-Host "⚠️  index.html may be missing UTF-8 encoding declaration" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Cannot read index.html" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Cannot find web\index.html file" -ForegroundColor Red
}

if (Test-Path "web\app.js") {
    Write-Host "✅ app.js file exists" -ForegroundColor Green
} else {
    Write-Host "❌ Cannot find web\app.js file" -ForegroundColor Red
}

# Check server status
Write-Host ""
Write-Host "3. Checking Web server status..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/status" -Method GET -ErrorAction Stop
    Write-Host "✅ Web server is running normally" -ForegroundColor Green
    Write-Host "   Current provider: $($response.provider)" -ForegroundColor Gray
    Write-Host "   Configuration status: $($response.configured)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Web server is not running or inaccessible" -ForegroundColor Red
    Write-Host "   Please run: .\switch.ps1 -Web" -ForegroundColor Yellow
}

# Check API endpoints
Write-Host ""
Write-Host "4. Checking API response encoding..." -ForegroundColor Yellow
try {
    $models = Invoke-RestMethod -Uri "http://localhost:8080/api/models" -Method GET -ErrorAction Stop
    Write-Host "✅ API model list retrieved successfully" -ForegroundColor Green
    foreach ($model in $models) {
        Write-Host "   - $($model.id): $($model.name)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Cannot retrieve API model list" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "=== Check Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If encoding issues are found, recommended solutions:" -ForegroundColor Yellow
Write-Host "1. Ensure all files are saved with UTF-8 encoding" -ForegroundColor White
Write-Host "2. Restart Web server: .\switch.ps1 -Web" -ForegroundColor White
Write-Host "3. Clear browser cache and re-access" -ForegroundColor White
Write-Host "4. If issues persist, use English interface version" -ForegroundColor White
Write-Host ""