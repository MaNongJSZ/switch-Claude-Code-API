# Claude Code API 供应商切换脚本（优化版）
# 功能：
# - 状态显示 + 清空配置
# - 兼容 PowerShell 5.1 和 7
# - 支持Web界面

param(
    [switch]$Web,
    [switch]$Help,
    [int]$Port = 8080
)

# 如果是Web模式，启动Web服务器
if ($Web) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $webServerScript = Join-Path $scriptDir "web-server.ps1"
    
    if (Test-Path $webServerScript) {
        Write-Host "启动 Claude Code API Web 界面..." -ForegroundColor Cyan
        & $webServerScript -Port $Port
    } else {
        Write-Host "错误：找不到 web-server.ps1 文件" -ForegroundColor Red
    }
    exit
}

# 显示帮助
if ($Help) {
    Write-Host "Claude Code API 供应商切换脚本" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "用法：" -ForegroundColor Yellow
    Write-Host "  .\switch.ps1                # 交互式菜单"
    Write-Host "  .\switch.ps1 -Web           # 启动Web界面"
    Write-Host "  .\switch.ps1 -Web -Port 3000 # 在指定端口启动Web界面"
    Write-Host "  .\switch.ps1 -Help          # 显示此帮助"
    Write-Host ""
    exit
}

function Show-CurrentProvider {
    # 强制从用户环境变量刷新到当前会话
    $env:ANTHROPIC_BASE_URL = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", "User")
    $env:ANTHROPIC_MODEL = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_MODEL", "User")
    $env:ANTHROPIC_SMALL_FAST_MODEL = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", "User")

    # 显示当前会话中的环境变量 (现在是最新的)
    $baseUrl = $env:ANTHROPIC_BASE_URL
    $model   = $env:ANTHROPIC_MODEL
    $fast    = $env:ANTHROPIC_SMALL_FAST_MODEL

    if ($baseUrl) {
        Write-Host "[状态] 当前供应商环境变量：" -ForegroundColor Yellow
        Write-Host "  BASE_URL   = $baseUrl"
        Write-Host "  MODEL      = $model"
        Write-Host "  FAST_MODEL = $fast"
        Write-Host ""
    } else {
        Write-Host "[警告] 尚未配置 Claude Code API 环境变量" -ForegroundColor Red
        Write-Host ""
    }
}

# 同步写入用户环境变量（异步优化版）
function Persist-Env {
    param($key, $value)
    # 当前会话立即生效
    [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
    
    # 异步持久化到用户环境变量
    Start-Job -ScriptBlock {
        param($envKey, $envValue)
        [System.Environment]::SetEnvironmentVariable($envKey, $envValue, "User")
    } -ArgumentList $key, $value | Out-Null
}

# 切换 DeepSeek
function Set-DeepSeek {
    Write-Host "正在切换到 DeepSeek API..." -ForegroundColor Yellow
    
    # 当前会话立即生效
    $env:ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:DEEPSEEK_API_KEY
    $env:ANTHROPIC_MODEL = "deepseek-chat"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "deepseek-chat"

    # 异步持久化（不阻塞主线程）
    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:DEEPSEEK_API_KEY
    Persist-Env "ANTHROPIC_MODEL" $env:ANTHROPIC_MODEL
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $env:ANTHROPIC_SMALL_FAST_MODEL
    
    Write-Host "[成功] 当前会话已立即切换到 DeepSeek API" -ForegroundColor Green
    Write-Host "[提示] 新的终端窗口将在几秒钟后自动使用此配置" -ForegroundColor Cyan
}

# 切换 GLM
function Set-GLM {
    Write-Host "正在切换到 GLM-4.5 API..." -ForegroundColor Yellow
    
    $env:ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:GLM_API_KEY
    $env:ANTHROPIC_MODEL = "glm-4.5"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "glm-4.5-air"

    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:GLM_API_KEY
    Persist-Env "ANTHROPIC_MODEL" $env:ANTHROPIC_MODEL
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $env:ANTHROPIC_SMALL_FAST_MODEL
    
    Write-Host "[成功] 当前会话已立即切换到 GLM-4.5 API" -ForegroundColor Green
    Write-Host "[提示] 新的终端窗口将在几秒钟后自动使用此配置" -ForegroundColor Cyan
}

# 切换 Kimi
function Set-Kimi {
    Write-Host "正在切换到 Kimi API..." -ForegroundColor Yellow
    
    $env:ANTHROPIC_BASE_URL = "https://api.moonshot.cn/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:KIMI_API_KEY
    $env:ANTHROPIC_MODEL = "kimi-k2-0711-preview"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "kimi-k2-0711-preview"

    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:KIMI_API_KEY
    Persist-Env "ANTHROPIC_MODEL" $env:ANTHROPIC_MODEL
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $env:ANTHROPIC_SMALL_FAST_MODEL
    
    Write-Host "[成功] 当前会话已立即切换到 Kimi API" -ForegroundColor Green
    Write-Host "[提示] 新的终端窗口将在几秒钟后自动使用此配置" -ForegroundColor Cyan
}

# 清空
function Clear-Env {
    Write-Host "正在清空配置..." -ForegroundColor Yellow
    
    $env:ANTHROPIC_BASE_URL = $null
    $env:ANTHROPIC_AUTH_TOKEN = $null
    $env:ANTHROPIC_MODEL = $null
    $env:ANTHROPIC_SMALL_FAST_MODEL = $null

    Persist-Env "ANTHROPIC_BASE_URL" $null
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $null
    Persist-Env "ANTHROPIC_MODEL" $null
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $null

    Write-Host "[成功] 已清空 Claude Code API 环境变量" -ForegroundColor Green
    Write-Host "[提示] 新的终端窗口将在几秒钟后自动使用此配置" -ForegroundColor Cyan
}

# 主菜单
Show-CurrentProvider

Write-Host "请选择 Claude Code API 供应商：" -ForegroundColor Cyan
Write-Host "1. DeepSeek"
Write-Host "2. GLM-4.5"
Write-Host "3. Kimi"
Write-Host "4. 清空当前配置"
Write-Host "0. 退出"
Write-Host ""

$choice = Read-Host "请输入编号 (0~4)"

switch ($choice) {
    "1" { Set-DeepSeek }
    "2" { Set-GLM }
    "3" { Set-Kimi }
    "4" { Clear-Env }
    "0" { Write-Host "已退出"; exit }
    Default { Write-Host "[错误] 无效选择，请输入 0~4" -ForegroundColor Red }
}

# 再次显示当前状态
Show-CurrentProvider

# 提示用户当前会话已立即生效
Write-Host "[提示] 当前 PowerShell 窗口中的配置已立即生效。" -ForegroundColor Green
Write-Host "[提示] 新打开的终端/命令行窗口将在几秒钟后使用此配置。" -ForegroundColor Blue
Write-Host ""