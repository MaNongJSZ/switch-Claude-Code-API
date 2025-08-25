param(
    [string]$Add,
    [switch]$List,
    [string]$Remove,
    [switch]$Help
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ConfigFile = Join-Path $ScriptDir "models.json"

function Show-Help {
    Write-Host "Claude Code API Switch Tool v2.0" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\switch.ps1                    # Interactive menu"
    Write-Host "  .\switch.ps1 -List              # List all models"
    Write-Host "  .\switch.ps1 -Add [modelId]     # Add new model"
    Write-Host "  .\switch.ps1 -Remove [modelId]  # Remove model"
    Write-Host "  .\switch.ps1 -Help              # Show help"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\switch.ps1 -Add claude3       # Add model named claude3"
    Write-Host "  .\switch.ps1 -Remove kimi       # Remove kimi model"
    Write-Host ""
}

function Load-Config {
    if (-not (Test-Path $ConfigFile)) {
        Write-Host "Error: Config file not found: $ConfigFile" -ForegroundColor Red
        Write-Host "Please ensure models.json exists in script directory." -ForegroundColor Yellow
        exit 1
    }
    
    try {
        $configContent = Get-Content $ConfigFile -Raw -Encoding UTF8
        return $configContent | ConvertFrom-Json
    } catch {
        Write-Host "Error: Invalid config format: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

function Save-Config {
    param($config)
    try {
        $config | ConvertTo-Json -Depth 10 | Out-File $ConfigFile -Encoding UTF8
        Write-Host "Config file saved successfully" -ForegroundColor Green
    } catch {
        Write-Host "Error saving config file: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-CurrentProvider {
    $env:ANTHROPIC_BASE_URL = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", "User")
    $env:ANTHROPIC_MODEL = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_MODEL", "User")
    $env:ANTHROPIC_SMALL_FAST_MODEL = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", "User")

    $baseUrl = $env:ANTHROPIC_BASE_URL
    $model   = $env:ANTHROPIC_MODEL
    $fast    = $env:ANTHROPIC_SMALL_FAST_MODEL

    if ($baseUrl) {
        Write-Host "Current Provider Environment Variables:" -ForegroundColor Yellow
        Write-Host "  BASE_URL   = $baseUrl"
        Write-Host "  MODEL      = $model"
        Write-Host "  FAST_MODEL = $fast"
        Write-Host ""
    } else {
        Write-Host "No Claude Code API environment variables configured" -ForegroundColor Red
        Write-Host ""
    }
}

function Persist-Env {
    param($key, $value)
    [System.Environment]::SetEnvironmentVariable($key, $value, "User")
}

function Set-Model {
    param($modelConfig)
    
    $apiKey = [System.Environment]::GetEnvironmentVariable($modelConfig.api_key_env, "User")
    if (-not $apiKey) {
        Write-Host "Warning: API key environment variable not found: $($modelConfig.api_key_env)" -ForegroundColor Yellow
        Write-Host "Please ensure this environment variable is set." -ForegroundColor Yellow
    }
    
    $env:ANTHROPIC_BASE_URL = $modelConfig.base_url
    $env:ANTHROPIC_AUTH_TOKEN = $apiKey
    $env:ANTHROPIC_MODEL = $modelConfig.model
    $env:ANTHROPIC_SMALL_FAST_MODEL = $modelConfig.fast_model

    Persist-Env "ANTHROPIC_BASE_URL" $env:ANTHROPIC_BASE_URL
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $apiKey
    Persist-Env "ANTHROPIC_MODEL" $env:ANTHROPIC_MODEL
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $env:ANTHROPIC_SMALL_FAST_MODEL
}

function Clear-Env {
    $env:ANTHROPIC_BASE_URL = $null
    $env:ANTHROPIC_AUTH_TOKEN = $null
    $env:ANTHROPIC_MODEL = $null
    $env:ANTHROPIC_SMALL_FAST_MODEL = $null

    Persist-Env "ANTHROPIC_BASE_URL" $null
    Persist-Env "ANTHROPIC_AUTH_TOKEN" $null
    Persist-Env "ANTHROPIC_MODEL" $null
    Persist-Env "ANTHROPIC_SMALL_FAST_MODEL" $null

    Write-Host "Claude Code API environment variables cleared" -ForegroundColor Green
}

function Show-Models {
    $config = Load-Config
    Write-Host "Available Models:" -ForegroundColor Cyan
    Write-Host ""
    
    $index = 1
    foreach ($modelId in $config.models.PSObject.Properties.Name) {
        $model = $config.models.$modelId
        Write-Host "$index. [$modelId] $($model.name)" -ForegroundColor White
        Write-Host "   Description: $($model.description)" -ForegroundColor Gray
        Write-Host "   API: $($model.base_url)" -ForegroundColor Gray
        Write-Host "   Models: $($model.model) / $($model.fast_model)" -ForegroundColor Gray
        Write-Host ""
        $index++
    }
}

function Add-Model {
    param($modelId)
    
    $config = Load-Config
    
    if ($config.models.PSObject.Properties.Name -contains $modelId) {
        Write-Host "Error: Model '$modelId' already exists!" -ForegroundColor Red
        return
    }
    
    Write-Host "Adding new model configuration: $modelId" -ForegroundColor Cyan
    Write-Host ""
    
    $name = Read-Host "Enter model display name"
    $description = Read-Host "Enter model description"
    $baseUrl = Read-Host "Enter API Base URL"
    $apiKeyEnv = Read-Host "Enter API key environment variable name"
    $model = Read-Host "Enter main model name"
    $fastModel = Read-Host "Enter fast model name (can be same as main)"
    
    if (-not $fastModel) {
        $fastModel = $model
    }
    
    $newModel = @{
        name = $name
        base_url = $baseUrl
        api_key_env = $apiKeyEnv
        model = $model
        fast_model = $fastModel
        description = $description
    }
    
    $config.models | Add-Member -NotePropertyName $modelId -NotePropertyValue $newModel
    
    Save-Config $config
    Write-Host "Model '$modelId' added successfully!" -ForegroundColor Green
}

function Remove-Model {
    param($modelId)
    
    $config = Load-Config
    
    if ($config.models.PSObject.Properties.Name -notcontains $modelId) {
        Write-Host "Error: Model '$modelId' not found!" -ForegroundColor Red
        return
    }
    
    $modelName = $config.models.$modelId.name
    $confirm = Read-Host "Are you sure you want to delete model '$modelId ($modelName)'? (y/N)"
    
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        $config.models.PSObject.Properties.Remove($modelId)
        Save-Config $config
        Write-Host "Model '$modelId' deleted successfully!" -ForegroundColor Green
    } else {
        Write-Host "Deletion cancelled." -ForegroundColor Yellow
    }
}

if ($Help) {
    Show-Help
    exit
}

if ($List) {
    Show-Models
    exit
}

if ($Add) {
    Add-Model $Add
    exit
}

if ($Remove) {
    Remove-Model $Remove
    exit
}

# Interactive menu
$config = Load-Config

Show-CurrentProvider

Write-Host "Please select Claude Code API provider:" -ForegroundColor Cyan

$models = @()
$index = 1
foreach ($modelId in $config.models.PSObject.Properties.Name) {
    $model = $config.models.$modelId
    Write-Host "$index. $($model.name)"
    $models += @{ id = $modelId; config = $model }
    $index++
}

Write-Host "$index. Clear current configuration"
Write-Host "0. Exit"
Write-Host ""

$choice = Read-Host "Enter number (0~$index)"

if ($choice -eq "0") {
    Write-Host "Exited"
    exit
} elseif ($choice -eq $index.ToString()) {
    Clear-Env
} elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -lt $index) {
    $selectedModel = $models[[int]$choice - 1]
    Set-Model $selectedModel.config
    Write-Host "Switched to $($selectedModel.config.name) API" -ForegroundColor Green
} else {
    Write-Host "Invalid selection, please enter 0~$index" -ForegroundColor Red
}

Show-CurrentProvider

Write-Host "Please run Claude Code tools in a new terminal/command window to use the new configuration." -ForegroundColor Blue
Write-Host ""