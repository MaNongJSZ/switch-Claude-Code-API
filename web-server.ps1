# Claude Code API Web Server
param(
    [int]$Port = 8080,
    [switch]$Help
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ConfigFile = Join-Path $ScriptDir "models.json"
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