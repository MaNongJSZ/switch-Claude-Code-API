# Claude Code API Web Server
param(
    [int]$Port = 8080,
    [switch]$Help
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ConfigFile = Join-Path $ScriptDir "models.json"
$ApiKeysConfigFile = Join-Path $ScriptDir "api-keys.json"
$WebDir = Join-Path $ScriptDir "web"

function Show-Help {
    Write-Host "Claude Code API Web Server" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\web-server.ps1                # Start server on port 8080"
    Write-Host "  .\web-server.ps1 -Port 3000     # Start server on custom port"
    Write-Host "  .\web-server.ps1 -Help          # Show this help"
    Write-Host ""
}

if ($Help) {
    Show-Help
    exit
}

function Load-Config {
    if (-not (Test-Path $ConfigFile)) {
        return $null
    }
    
    try {
        $configContent = Get-Content $ConfigFile -Raw -Encoding UTF8
        return $configContent | ConvertFrom-Json
    } catch {
        return $null
    }
}

function Save-Config {
    param($config)
    try {
        $config | ConvertTo-Json -Depth 10 | Out-File $ConfigFile -Encoding UTF8
        return $true
    } catch {
        return $false
    }
}

function Load-ApiKeysConfig {
    if (-not (Test-Path $ApiKeysConfigFile)) {
        # 创建默认配置
        $defaultConfig = @{
            apiKeys = @{}
        }
        Save-ApiKeysConfig $defaultConfig
        return $defaultConfig
    }
    
    try {
        $configContent = Get-Content $ApiKeysConfigFile -Raw -Encoding UTF8
        return $configContent | ConvertFrom-Json
    } catch {
        Write-Host "Error loading API keys config: $($_.Exception.Message)" -ForegroundColor Red
        return @{ apiKeys = @{} }
    }
}

function Save-ApiKeysConfig {
    param($config)
    try {
        $config | ConvertTo-Json -Depth 10 | Out-File $ApiKeysConfigFile -Encoding UTF8
        return $true
    } catch {
        Write-Host "Error saving API keys config: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Get-CurrentStatus {
    $baseUrl = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", "User")
    $model = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_MODEL", "User")
    $fastModel = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", "User")
    
    $provider = "Unknown"
    if ($baseUrl) {
        if ($baseUrl -like "*deepseek*") { $provider = "DeepSeek" }
        elseif ($baseUrl -like "*bigmodel*") { $provider = "GLM-4.5" }
        elseif ($baseUrl -like "*moonshot*") { $provider = "Kimi" }
        else { $provider = "Custom" }
    }
    
    return @{
        configured = [bool]$baseUrl
        baseUrl = $baseUrl
        model = $model
        fastModel = $fastModel
        provider = $provider
    }
}

function Set-EnvironmentVariables {
    param($modelConfig)
    
    $apiKey = [System.Environment]::GetEnvironmentVariable($modelConfig.api_key_env, "User")
    
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $modelConfig.base_url, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $apiKey, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_MODEL", $modelConfig.model, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", $modelConfig.fast_model, "User")
}

function Clear-EnvironmentVariables {
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $null, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $null, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_MODEL", $null, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", $null, "User")
}

function Send-JsonResponse {
    param($Response, $Data, $StatusCode = 200)
    
    $json = $Data | ConvertTo-Json -Depth 10
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($json)
    
    $Response.StatusCode = $StatusCode
    $Response.ContentType = "application/json; charset=utf-8"
    $Response.ContentLength64 = $buffer.Length
    $Response.Headers.Add("Access-Control-Allow-Origin", "*")
    $Response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    $Response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
    
    $Response.OutputStream.Write($buffer, 0, $buffer.Length)
    $Response.OutputStream.Close()
}

function Send-FileResponse {
    param($Response, $FilePath)
    
    if (-not (Test-Path $FilePath)) {
        $Response.StatusCode = 404
        $Response.Close()
        return
    }
    
    $fileContent = Get-Content $FilePath -Raw -Encoding UTF8
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($fileContent)
    
    $Response.StatusCode = 200
    
    if ($FilePath -like "*.html") {
        $Response.ContentType = "text/html; charset=utf-8"
    } elseif ($FilePath -like "*.css") {
        $Response.ContentType = "text/css; charset=utf-8"
    } elseif ($FilePath -like "*.js") {
        $Response.ContentType = "application/javascript; charset=utf-8"
    } else {
        $Response.ContentType = "text/plain; charset=utf-8"
    }
    
    $Response.ContentLength64 = $buffer.Length
    $Response.OutputStream.Write($buffer, 0, $buffer.Length)
    $Response.OutputStream.Close()
}

function Handle-ApiRequest {
    param($Request, $Response)
    
    $method = $Request.HttpMethod
    $path = $Request.Url.AbsolutePath
    
    Write-Host "API Request: $method $path" -ForegroundColor Cyan
    
    try {
        switch -Regex ($path) {
            "^/api/status$" {
                if ($method -eq "GET") {
                    $status = Get-CurrentStatus
                    Send-JsonResponse $Response $status
                } else {
                    Send-JsonResponse $Response @{error = "Method not allowed"} 405
                }
            }
            
            "^/api/models$" {
                if ($method -eq "GET") {
                    $config = Load-Config
                    if ($config) {
                        $models = @()
                        foreach ($modelId in $config.models.PSObject.Properties.Name) {
                            $model = $config.models.$modelId
                            $models += @{
                                id = $modelId
                                name = $model.name
                                description = $model.description
                                base_url = $model.base_url
                                api_key_env = $model.api_key_env
                                model = $model.model
                                fast_model = $model.fast_model
                            }
                        }
                        Send-JsonResponse $Response $models
                    } else {
                        Send-JsonResponse $Response @{error = "Failed to load config"} 500
                    }
                } elseif ($method -eq "POST") {
                    $reader = New-Object System.IO.StreamReader($Request.InputStream)
                    $requestBody = $reader.ReadToEnd()
                    $reader.Close()
                    
                    $newModel = $requestBody | ConvertFrom-Json
                    $config = Load-Config
                    
                    if ($config -and $newModel) {
                        if ($config.models.PSObject.Properties.Name -contains $newModel.id) {
                            Send-JsonResponse $Response @{error = "Model already exists"} 409
                            return
                        }
                        
                        $modelData = @{
                            name = $newModel.name
                            description = $newModel.description
                            base_url = $newModel.base_url
                            api_key_env = $newModel.api_key_env
                            model = $newModel.model
                            fast_model = $newModel.fast_model
                        }
                        
                        $config.models | Add-Member -NotePropertyName $newModel.id -NotePropertyValue $modelData
                        
                        if (Save-Config $config) {
                            Send-JsonResponse $Response @{success = $true; message = "Model added successfully"}
                        } else {
                            Send-JsonResponse $Response @{error = "Failed to save config"} 500
                        }
                    } else {
                        Send-JsonResponse $Response @{error = "Invalid request"} 400
                    }
                } else {
                    Send-JsonResponse $Response @{error = "Method not allowed"} 405
                }
            }
            
            "^/api/models/(.+)$" {
                $modelId = $Matches[1]
                
                if ($method -eq "DELETE") {
                    $config = Load-Config
                    if ($config) {
                        if ($config.models.PSObject.Properties.Name -contains $modelId) {
                            $config.models.PSObject.Properties.Remove($modelId)
                            if (Save-Config $config) {
                                Send-JsonResponse $Response @{success = $true; message = "Model deleted successfully"}
                            } else {
                                Send-JsonResponse $Response @{error = "Failed to save config"} 500
                            }
                        } else {
                            Send-JsonResponse $Response @{error = "Model not found"} 404
                        }
                    } else {
                        Send-JsonResponse $Response @{error = "Failed to load config"} 500
                    }
                } else {
                    Send-JsonResponse $Response @{error = "Method not allowed"} 405
                }
            }
            
            "^/api/switch$" {
                if ($method -eq "POST") {
                    $reader = New-Object System.IO.StreamReader($Request.InputStream)
                    $requestBody = $reader.ReadToEnd()
                    $reader.Close()
                    
                    $switchRequest = $requestBody | ConvertFrom-Json
                    $config = Load-Config
                    
                    if ($config -and $switchRequest.modelId) {
                        $modelConfig = $config.models.($switchRequest.modelId)
                        if ($modelConfig) {
                            Set-EnvironmentVariables $modelConfig
                            Send-JsonResponse $Response @{success = $true; message = "Switched successfully"}
                        } else {
                            Send-JsonResponse $Response @{error = "Model not found"} 404
                        }
                    } else {
                        Send-JsonResponse $Response @{error = "Invalid request"} 400
                    }
                } else {
                    Send-JsonResponse $Response @{error = "Method not allowed"} 405
                }
            }
            
            "^/api/clear$" {
                if ($method -eq "POST") {
                    Clear-EnvironmentVariables
                    Send-JsonResponse $Response @{success = $true; message = "Configuration cleared"}
                } else {
                    Send-JsonResponse $Response @{error = "Method not allowed"} 405
                }
            }
            
            "^/api/keys$" {
                if ($method -eq "GET") {
                    # 从配置文件和环境变量获取API密钥状态
                    $keys = @{}
                    $config = Load-Config
                    $apiKeysConfig = Load-ApiKeysConfig
                    
                    # 首先添加配置文件中定义的模型
                    if ($config) {
                        foreach ($modelId in $config.models.PSObject.Properties.Name) {
                            $model = $config.models.$modelId
                            $envVar = $model.api_key_env
                            $apiKey = [System.Environment]::GetEnvironmentVariable($envVar, "User")
                            $keys[$envVar] = @{
                                modelId = $modelId
                                modelName = $model.name
                                envVar = $envVar
                                hasKey = [bool]$apiKey
                                keyPreview = if ($apiKey) { $apiKey.Substring(0, [Math]::Min(8, $apiKey.Length)) + "..." } else { "" }
                                isFromConfig = $true
                            }
                        }
                    }
                    
                    # 添加API密钥配置文件中定义的密钥
                    if ($apiKeysConfig -and $apiKeysConfig.apiKeys) {
                        foreach ($envVarName in $apiKeysConfig.apiKeys.PSObject.Properties.Name) {
                            if (-not $keys.ContainsKey($envVarName)) {
                                $keyInfo = $apiKeysConfig.apiKeys.$envVarName
                                $apiKey = [System.Environment]::GetEnvironmentVariable($envVarName, "User")
                                $keys[$envVarName] = @{
                                    modelId = "custom"
                                    modelName = $keyInfo.name
                                    envVar = $envVarName
                                    hasKey = [bool]$apiKey
                                    keyPreview = if ($apiKey) { $apiKey.Substring(0, [Math]::Min(8, $apiKey.Length)) + "..." } else { "" }
                                    isFromConfig = $false
                                    description = $keyInfo.description
                                }
                            }
                        }
                    }
                    
                    # 获取所有用户环境变量，查找其他_API_KEY结尾的变量
                    try {
                        $userEnvVars = [System.Environment]::GetEnvironmentVariables("User")
                        foreach ($envVarName in $userEnvVars.Keys) {
                            if ($envVarName -match ".*_API_KEY$" -and -not $keys.ContainsKey($envVarName)) {
                                $apiKey = $userEnvVars[$envVarName]
                                if ($apiKey) {
                                    $keys[$envVarName] = @{
                                        modelId = "custom"
                                        modelName = $envVarName.Replace("_API_KEY", "")
                                        envVar = $envVarName
                                        hasKey = $true
                                        keyPreview = $apiKey.Substring(0, [Math]::Min(8, $apiKey.Length)) + "..."
                                        isFromConfig = $false
                                        description = "用户自定义API密钥"
                                    }
                                }
                            }
                        }
                    } catch {
                        Write-Host "Error getting user environment variables: $($_.Exception.Message)" -ForegroundColor Red
                    }
                    
                    Write-Host "Returning API keys: $($keys.Keys -join ', ')" -ForegroundColor Cyan
                    Send-JsonResponse $Response $keys
                } elseif ($method -eq "POST") {
                    # 设置API密钥并更新配置文件
                    Write-Host "Processing POST /api/keys request" -ForegroundColor Yellow
                    
                    $reader = New-Object System.IO.StreamReader($Request.InputStream)
                    $requestBody = $reader.ReadToEnd()
                    $reader.Close()
                    
                    Write-Host "Request body: $requestBody" -ForegroundColor Yellow
                    
                    $keyRequest = $requestBody | ConvertFrom-Json
                    
                    if ($keyRequest.envVar -and $keyRequest.apiKey) {
                        Write-Host "Setting environment variable: $($keyRequest.envVar)" -ForegroundColor Green
                        
                        # 设置环境变量
                        [System.Environment]::SetEnvironmentVariable($keyRequest.envVar, $keyRequest.apiKey, "User")
                        
                        # 如果不在模型配置中，则添加到API密钥配置文件
                        $config = Load-Config
                        $isModelKey = $false
                        Write-Host "Checking if $($keyRequest.envVar) is a model key..." -ForegroundColor Yellow
                        if ($config -and $config.models) {
                            foreach ($modelId in $config.models.PSObject.Properties.Name) {
                                $model = $config.models.$modelId
                                Write-Host "Checking model $modelId with env var: $($model.api_key_env)" -ForegroundColor Yellow
                                if ($model.api_key_env -eq $keyRequest.envVar) {
                                    $isModelKey = $true
                                    Write-Host "Found matching model key: $modelId" -ForegroundColor Green
                                    break
                                }
                            }
                        }
                        
                        Write-Host "Is model key: $isModelKey" -ForegroundColor Yellow
                        
                        # 如果不是模型密钥，添加到API密钥配置文件
                        if (-not $isModelKey) {
                            Write-Host "Adding to API keys config file..." -ForegroundColor Green
                            $apiKeysConfig = Load-ApiKeysConfig
                            Write-Host "Current API keys config: $($apiKeysConfig | ConvertTo-Json -Depth 3)" -ForegroundColor Yellow
                            
                            $existingKeys = @($apiKeysConfig.apiKeys.PSObject.Properties.Name)
                            Write-Host "Existing keys in config: $($existingKeys -join ', ')" -ForegroundColor Yellow
                            Write-Host "Checking if $($keyRequest.envVar) exists in: $($existingKeys -contains $keyRequest.envVar)" -ForegroundColor Yellow
                            
                            if ($existingKeys -notcontains $keyRequest.envVar) {
                                $keyName = $keyRequest.envVar.Replace("_API_KEY", "")
                                $keyInfo = @{
                                    name = $keyName
                                    description = "$keyName API密钥"
                                }
                                Write-Host "Adding new key info: $($keyInfo | ConvertTo-Json)" -ForegroundColor Green
                                $apiKeysConfig.apiKeys | Add-Member -NotePropertyName $keyRequest.envVar -NotePropertyValue $keyInfo
                                
                                $saveResult = Save-ApiKeysConfig $apiKeysConfig
                                Write-Host "Save result: $saveResult" -ForegroundColor Green
                                
                                if ($saveResult) {
                                    Write-Host "Successfully added new API key to config: $($keyRequest.envVar)" -ForegroundColor Green
                                } else {
                                    Write-Host "Failed to save API keys config" -ForegroundColor Red
                                }
                            } else {
                                Write-Host "API key already exists in config: $($keyRequest.envVar)" -ForegroundColor Yellow
                            }
                        } else {
                            Write-Host "Skipping config file update - this is a model key" -ForegroundColor Yellow
                        }
                        
                        Send-JsonResponse $Response @{success = $true; message = "API密钥已保存"}
                    } else {
                        Write-Host "Missing required parameters: envVar=$($keyRequest.envVar), hasApiKey=$([bool]$keyRequest.apiKey)" -ForegroundColor Red
                        Send-JsonResponse $Response @{error = "缺少必要参数"} 400
                    }
                } else {
                    Send-JsonResponse $Response @{error = "Method not allowed"} 405
                }
            }
            
            "^/api/keys/(.+)$" {
                $envVar = $Matches[1]
                # PowerShell内置的URL解码方法
                $envVar = [System.Uri]::UnescapeDataString($envVar)
                
                if ($method -eq "DELETE") {
                    Write-Host "Processing DELETE /api/keys/$envVar request" -ForegroundColor Yellow
                    
                    # 检查是否为模型密钥，不允许删除模型密钥
                    $config = Load-Config
                    $isModelKey = $false
                    if ($config -and $config.models) {
                        foreach ($modelId in $config.models.PSObject.Properties.Name) {
                            $model = $config.models.$modelId
                            if ($model.api_key_env -eq $envVar) {
                                $isModelKey = $true
                                break
                            }
                        }
                    }
                    
                    if ($isModelKey) {
                        Write-Host "Cannot delete model key: $envVar" -ForegroundColor Red
                        Send-JsonResponse $Response @{error = "不能删除模型密钥，只能删除自定义密钥"} 400
                        return
                    }
                    
                    try {
                        # 从环境变量中完全删除（不仅仅是清空值）
                        # 使用.NET方法先清空值
                        [System.Environment]::SetEnvironmentVariable($envVar, $null, "User")
                        
                        # 然后使用PowerShell命令完全删除环境变量
                        try {
                            $regPath = "HKCU:\Environment"
                            if (Test-Path $regPath) {
                                Remove-ItemProperty -Path $regPath -Name $envVar -ErrorAction SilentlyContinue
                                Write-Host "Completely removed environment variable from registry: $envVar" -ForegroundColor Green
                            }
                        } catch {
                            Write-Host "Note: Could not remove from registry, but value was cleared: $($_.Exception.Message)" -ForegroundColor Yellow
                        }
                        
                        Write-Host "Removed environment variable: $envVar" -ForegroundColor Green
                        
                        # 从配置文件中删除（如果存在）
                        $apiKeysConfig = Load-ApiKeysConfig
                        if ($apiKeysConfig -and $apiKeysConfig.apiKeys) {
                            $existingKeys = @($apiKeysConfig.apiKeys.PSObject.Properties.Name)
                            if ($existingKeys -contains $envVar) {
                                $apiKeysConfig.apiKeys.PSObject.Properties.Remove($envVar)
                                $saveResult = Save-ApiKeysConfig $apiKeysConfig
                                if ($saveResult) {
                                    Write-Host "Removed API key from config file: $envVar" -ForegroundColor Green
                                } else {
                                    Write-Host "Failed to save API keys config after deletion" -ForegroundColor Red
                                }
                            }
                        }
                        
                        Send-JsonResponse $Response @{success = $true; message = "API密钥已删除"}
                    } catch {
                        Write-Host "Error deleting API key: $($_.Exception.Message)" -ForegroundColor Red
                        Send-JsonResponse $Response @{error = "删除API密钥失败"} 500
                    }
                } else {
                    Send-JsonResponse $Response @{error = "Method not allowed"} 405
                }
            }
            
            "^/api/test$" {
                if ($method -eq "POST") {
                    # 测试当前配置的模型
                    $reader = New-Object System.IO.StreamReader($Request.InputStream)
                    $requestBody = $reader.ReadToEnd()
                    $reader.Close()
                    
                    $testRequest = $requestBody | ConvertFrom-Json
                    
                    if ($testRequest.prompt) {
                        # 获取当前环境变量
                        $baseUrl = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_BASE_URL", "User")
                        $authToken = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "User")
                        $model = [System.Environment]::GetEnvironmentVariable("ANTHROPIC_MODEL", "User")
                        
                        if (-not $baseUrl -or -not $authToken -or -not $model) {
                            Send-JsonResponse $Response @{error = "请先配置一个模型"} 400
                            return
                        }
                        
                        try {
                            # 调用Claude API
                            $apiUrl = "$baseUrl/v1/messages"
                            $headers = @{
                                "Content-Type" = "application/json"
                                "x-api-key" = $authToken
                                "anthropic-version" = "2023-06-01"
                            }
                            
                            $body = @{
                                model = $model
                                max_tokens = 1024
                                messages = @(
                                    @{
                                        role = "user"
                                        content = $testRequest.prompt
                                    }
                                )
                            } | ConvertTo-Json -Depth 10
                            
                            Write-Host "Testing API: $apiUrl with model: $model" -ForegroundColor Cyan
                            
                            $response = Invoke-RestMethod -Uri $apiUrl -Method POST -Headers $headers -Body $body -ContentType "application/json"
                            
                            Send-JsonResponse $Response @{
                                success = $true
                                response = $response.content[0].text
                                model = $model
                                baseUrl = $baseUrl
                            }
                        } catch {
                            $errorMessage = $_.Exception.Message
                            if ($_.Exception.Response) {
                                try {
                                    $errorDetails = $_.Exception.Response.GetResponseStream()
                                    $reader = New-Object System.IO.StreamReader($errorDetails)
                                    $errorContent = $reader.ReadToEnd()
                                    $reader.Close()
                                    $errorMessage += ": $errorContent"
                                } catch { }
                            }
                            
                            Write-Host "API Test Error: $errorMessage" -ForegroundColor Red
                            Send-JsonResponse $Response @{error = "API调用失败: $errorMessage"} 500
                        }
                    } else {
                        Send-JsonResponse $Response @{error = "请提供测试提示词"} 400
                    }
                } else {
                    Send-JsonResponse $Response @{error = "Method not allowed"} 405
                }
            }
            
            default {
                Send-JsonResponse $Response @{error = "API endpoint not found"} 404
            }
        }
    } catch {
        Write-Host "API Error: $($_.Exception.Message)" -ForegroundColor Red
        Send-JsonResponse $Response @{error = "Internal server error"} 500
    }
}

function Handle-StaticRequest {
    param($Request, $Response)
    
    $path = $Request.Url.AbsolutePath
    
    if ($path -eq "/") {
        $path = "/index.html"
    }
    
    $filePath = Join-Path $WebDir $path.TrimStart('/')
    
    Write-Host "Static Request: $path -> $filePath" -ForegroundColor Gray
    
    Send-FileResponse $Response $filePath
}

function Start-WebServer {
    $listener = New-Object System.Net.HttpListener
    $prefix = "http://localhost:$Port/"
    $listener.Prefixes.Add($prefix)
    
    try {
        $listener.Start()
        Write-Host "Claude Code API Web Server started at $prefix" -ForegroundColor Green
        Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Web Interface: http://localhost:$Port" -ForegroundColor Cyan
        Write-Host "API Endpoint: http://localhost:$Port/api" -ForegroundColor Cyan
        Write-Host ""
        
        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            try {
                if ($request.HttpMethod -eq "OPTIONS") {
                    $response.Headers.Add("Access-Control-Allow-Origin", "*")
                    $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
                    $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
                    $response.StatusCode = 200
                    $response.Close()
                    continue
                }
                
                if ($request.Url.AbsolutePath.StartsWith("/api/")) {
                    Handle-ApiRequest $request $response
                } else {
                    Handle-StaticRequest $request $response
                }
            } catch {
                Write-Host "Request Error: $($_.Exception.Message)" -ForegroundColor Red
                try {
                    $response.StatusCode = 500
                    $response.Close()
                } catch { }
            }
        }
    } catch {
        Write-Host "Server Error: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        if ($listener.IsListening) {
            $listener.Stop()
        }
        $listener.Dispose()
        Write-Host "Server stopped." -ForegroundColor Yellow
    }
}

Write-Host "Starting Claude Code API Web Server..." -ForegroundColor Cyan
Start-WebServer