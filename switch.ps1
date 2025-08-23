# Claude Code API 供应商切换脚本（优化版）
# 功能：
# - 当前会话立即生效（瞬时）
# - 异步持久化写入用户环境变量（不阻塞）
# - 状态显示 + 清空配置
# - 兼容 PowerShell 5.1 和 7

function Show-CurrentProvider {
    $baseUrl = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", "User")
    $model   = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_MODEL", "User")
    $fast    = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", "User")

    if ($baseUrl) {
        Write-Host "🔎 当前供应商环境变量：" -ForegroundColor Yellow
        Write-Host "  BASE_URL   = $baseUrl"
        Write-Host "  MODEL      = $model"
        Write-Host "  FAST_MODEL = $fast"
        Write-Host ""
    } else {
        Write-Host "⚠️ 尚未配置 Claude Code API 环境变量" -ForegroundColor Red
        Write-Host ""
    }
}

# 异步写入用户环境变量
function Persist-Env {
    param($key, $value)
    Start-Job -ScriptBlock {
        param($k, $v)
        [System.Environment]::SetEnvironmentVariable($k, $v, "User")
    } -ArgumentList $key, $value | Out-Null
}

# 切换 DeepSeek
function Set-DeepSeek {
    # 当前会话立即生效
    $env:ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:DEEPSEEK_API_KEY
    $env:ANTHROPIC_MODEL = "deepseek-chat"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "deepseek-chat"

    # 异步持久化
    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:DEEPSEEK_API_KEY
    Persist-Env "ANTHROPIC_MODEL" "deepseek-chat"
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" "deepseek-chat"
}

# 切换 GLM
function Set-GLM {
    $env:ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:GLM_API_KEY
    $env:ANTHROPIC_MODEL = "glm-4.5"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "glm-4.5-air"

    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:GLM_API_KEY
    Persist-Env "ANTHROPIC_MODEL" "glm-4.5"
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" "glm-4.5-air"
}

# 切换 Kimi
function Set-Kimi {
    $env:ANTHROPIC_BASE_URL = "https://api.moonshot.cn/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:KIMI_API_KEY
    $env:ANTHROPIC_MODEL = "kimi-k2-0711-preview"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "kimi-k2-0711-preview"

    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:KIMI_API_KEY
    Persist-Env "ANTHROPIC_MODEL" "kimi-k2-0711-preview"
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" "kimi-k2-0711-preview"
}

# 清空
function Clear-Env {
    $env:ANTHROPIC_BASE_URL = $null
    $env:ANTHROPIC_AUTH_TOKEN = $null
    $env:ANTHROPIC_MODEL = $null
    $env:ANTHROPIC_SMALL_FAST_MODEL = $null

    Persist-Env "ANTHROPIC_BASE_URL" $null
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $null
    Persist-Env "ANTHROPIC_MODEL" $null
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $null

    Write-Host "✅ 已清空 Claude Code API 环境变量" -ForegroundColor Green
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
    "1" { Set-DeepSeek; Write-Host "✅ 已切换到 DeepSeek API" -ForegroundColor Green }
    "2" { Set-GLM; Write-Host "✅ 已切换到 GLM-4.5 API" -ForegroundColor Green }
    "3" { Set-Kimi; Write-Host "✅ 已切换到 Kimi API" -ForegroundColor Green }
    "4" { Clear-Env }
    "0" { Write-Host "已退出"; exit }
    Default { Write-Host "❌ 无效选择，请输入 0~4" -ForegroundColor Red }
}

# 再次显示当前状态
Show-CurrentProvider


