# 测试脚本功能
Write-Host "开始测试 switch.ps1 脚本功能..." -ForegroundColor Cyan
Write-Host ""

$scriptPath = "d:\scripts\switch-Claude-Code-API\switch.ps1"
$configPath = "d:\scripts\switch-Claude-Code-API\models.json"

# 测试1: 检查文件是否存在
Write-Host "测试1: 检查文件是否存在" -ForegroundColor Yellow
if (Test-Path $scriptPath) {
    Write-Host "✅ switch.ps1 存在" -ForegroundColor Green
} else {
    Write-Host "❌ switch.ps1 不存在" -ForegroundColor Red
}

if (Test-Path $configPath) {
    Write-Host "✅ models.json 存在" -ForegroundColor Green
} else {
    Write-Host "❌ models.json 不存在" -ForegroundColor Red
}
Write-Host ""

# 测试2: 检查配置文件格式
Write-Host "测试2: 检查配置文件格式" -ForegroundColor Yellow
try {
    $config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-Host "✅ 配置文件格式正确" -ForegroundColor Green
    Write-Host "   包含模型数量: $($config.models.PSObject.Properties.Count)" -ForegroundColor Gray
    foreach ($modelId in $config.models.PSObject.Properties.Name) {
        Write-Host "   - $modelId ($($config.models.$modelId.name))" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ 配置文件格式错误: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 测试3: 检查脚本语法（简单方式）
Write-Host "测试3: 检查脚本基本语法" -ForegroundColor Yellow
$scriptContent = Get-Content $scriptPath -Raw
$openBraces = ($scriptContent.ToCharArray() | Where-Object {$_ -eq '{'}).Count
$closeBraces = ($scriptContent.ToCharArray() | Where-Object {$_ -eq '}'}).Count

Write-Host "   开括号数量: $openBraces" -ForegroundColor Gray
Write-Host "   闭括号数量: $closeBraces" -ForegroundColor Gray

if ($openBraces -eq $closeBraces) {
    Write-Host "✅ 括号匹配正确" -ForegroundColor Green
} else {
    Write-Host "❌ 括号数量不匹配" -ForegroundColor Red
}
Write-Host ""

# 测试4: 尝试运行帮助命令
Write-Host "测试4: 尝试运行帮助功能" -ForegroundColor Yellow
try {
    $helpOutput = & powershell -ExecutionPolicy Bypass -File $scriptPath -Help 2>&1
    if ($helpOutput -match "Claude Code API 供应商切换工具") {
        Write-Host "✅ 帮助功能正常" -ForegroundColor Green
    } else {
        Write-Host "❌ 帮助功能异常" -ForegroundColor Red
        Write-Host "   输出: $helpOutput" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ 运行帮助命令失败: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 测试5: 尝试运行列表命令
Write-Host "测试5: 尝试运行列表功能" -ForegroundColor Yellow
try {
    $listOutput = & powershell -ExecutionPolicy Bypass -File $scriptPath -List 2>&1
    if ($listOutput -match "可用的模型配置") {
        Write-Host "✅ 列表功能正常" -ForegroundColor Green
    } else {
        Write-Host "❌ 列表功能异常" -ForegroundColor Red
        Write-Host "   输出: $listOutput" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ 运行列表命令失败: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "测试完成！" -ForegroundColor Cyan