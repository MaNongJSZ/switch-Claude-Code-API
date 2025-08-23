# Claude Code API 供应商切换脚本（优化版）
# 功能：
# - 状态显示 + 清空配置
# - 兼容 PowerShell 5.1 和 7

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

# 同步写入用户环境变量
function Persist-Env {
    param($key, $value)
    [System.Environment]::SetEnvironmentVariable($key, $value, "User")
}

# 切换 DeepSeek
function Set-DeepSeek {
    # 当前会话立即生效
    $env:ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:DEEPSEEK_API_KEY
    $env:ANTHROPIC_MODEL = "deepseek-chat"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "deepseek-chat"

    # 持久化
    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:DEEPSEEK_API_KEY
    Persist-Env "ANTHROPIC_MODEL" $env:ANTHROPIC_MODEL
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $env:ANTHROPIC_SMALL_FAST_MODEL
}

# 切换 GLM
function Set-GLM {
    $env:ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:GLM_API_KEY
    $env:ANTHROPIC_MODEL = "glm-4.5"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "glm-4.5-air"

    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:GLM_API_KEY
    Persist-Env "ANTHROPIC_MODEL" $env:ANTHROPIC_MODEL
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $env:ANTHROPIC_SMALL_FAST_MODEL
}

# 切换 Kimi
function Set-Kimi {
    $env:ANTHROPIC_BASE_URL = "https://api.moonshot.cn/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $env:KIMI_API_KEY
    $env:ANTHROPIC_MODEL = "kimi-k2-0711-preview"
    $env:ANTHROPIC_SMALL_FAST_MODEL = "kimi-k2-0711-preview"

    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $env:KIMI_API_KEY
    Persist-Env "ANTHROPIC_MODEL" $env:ANTHROPIC_MODEL
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $env:ANTHROPIC_SMALL_FAST_MODEL
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

# 提示用户需要在新终端中使用新配置
Write-Host "ℹ️  请在新打开的终端/命令行窗口中运行 Claude Code 工具以使用新配置。" -ForegroundColor Blue
Write-Host ""
