# Claude Code API Switcher

一个在 Windows 上快速切换 Claude Code API 供应商的工具，支持 **DeepSeek、GLM-4.5、Kimi** 等模型。  
通过 PowerShell 脚本 + BAT 启动器，支持 **当前会话立即生效** 和 **用户环境变量持久化**，兼容 **PowerShell 5.1 和 7+**。

## 文件结构

```
├─ scc.bat          # 启动器，双击即可运行
├─ switch.ps1       # 主脚本，包含交互菜单和环境变量设置逻辑
├─ start-web.bat    # Web界面启动器
├─ web-server.ps1   # Web服务器脚本
├─ models.json      # API供应商模型配置文件
├─ api-keys.json    # API密钥配置文件
└─ web/             # Web界面文件
    ├─ index.html   # Web界面主页面
    └─ app.js       # Web前端交互逻辑
```

## 功能特点

### 命令行功能
- 在终端交互菜单中选择兼容 Claude API 供应商
- 当前 PowerShell 会话立即生效
- 用户环境变量持久化，新开 PowerShell 窗口也能生效
- 清空当前 API 配置
- 支持 PowerShell 5.1 与 PowerShell 7+

### Web 界面功能
- 🔉 **现代化图形界面**：响应式设计，支持多语言切换
- 📊 **实时状态监控**：显示当前 API 供应商配置状态
- 🔧 **模型管理**：添加、编辑、删除模型配置
- 🔑 **API 密钥管理**：在线设置密钥，支持密钥预览
- 🚀 **一键切换**：无需命令行操作，点击即可切换
- 🧪 **模型测试**：内置测试面板，验证 API 连通性


## 安装与配置

1. 下载或克隆仓库到本地：

```bat
git clone https://github.com/MaNongJSZ/switch-Claude-Code-API.git
````

2. 设置用户环境变量（PowerShell 或系统环境变量）：

```powershell
setx DEEPSEEK_API_KEY "sk-xxxxxxx"
setx GLM_API_KEY "sk-xxxxxxx"
setx KIMI_API_KEY "sk-xxxxxxx"
```

3. 可选：将脚本目录加入系统 `PATH`，方便全局调用：

```bat
setx PATH "%PATH%;D:\scripts"
```


## 使用方法

### 方法 1：双击 BAT 文件

双击 `scc.bat` 即可启动菜单界面：

```
请选择 Claude Code API 供应商：
1. DeepSeek
2. GLM-4.5
3. Kimi
4. 清空当前配置
0. 退出
```

输入对应编号即可切换：

* `1` → DeepSeek
* `2` → GLM-4.5
* `3` → Kimi
* `4` → 清空配置
* `0` → 退出

### 方法 2：PowerShell 直接运行

在 PowerShell 中：

```powershell
cd D:\scripts
scc
```

**添加环境变量可在任意终端运行**

在 PowerShell 中：
```powershell
scc
```

同样会显示交互菜单，输入编号切换供应商。

### 方法 3：Web 图形界面（推荐）

#### 启动方式

**方式一：双击启动器**
```bat
# 双击 start-web.bat 文件
start-web.bat
```

**方式二：PowerShell 命令**
```powershell
# 默认端口 8080
.\switch.ps1 -Web

# 指定端口
.\switch.ps1 -Web -Port 3000
```

启动后浏览器会自动打开 `http://localhost:8080`，显示 Web 界面。

![alt text](assets\image.png)
![alt text](assets\image-1.png)
![alt text](assets\image-2.png)
#### Web 界面功能

**📊 状态监控**
- 实时显示当前配置的 API 供应商信息
- 显示基础 URL、模型信息、环境变量状态

**🔧 模型管理**
- 查看所有已配置的模型列表
- 添加新的 API 供应商模型
- 编辑现有模型配置
- 删除不需要的模型配置

**🔑 API 密钥管理**
- 直接在界面中设置各模型的 API 密钥
- 显示密钥状态（已设置/未设置）
- 支持密钥预览（前8位+...）
- 无需手动修改系统环境变量

**🚀 一键切换**
- 通过按钮快速切换到指定的 API 供应商
- 支持配置清空功能
- 切换后立即生效

**🌍 多语言支持**
- 支持中英文界面切换
- 点击右上角"EN"或"CN"按钮切换语言

**🧪 模型测试**
- 提供测试面板，输入提示词测试模型
- 验证 API 连通性
- 实时查看响应结果

#### Web API 端点

| 端点 | 方法 | 功能描述 |
|------|------|----------|
| `/api/status` | GET | 获取当前配置状态 |
| `/api/models` | GET | 获取所有模型列表 |
| `/api/models` | POST | 添加新模型配置 |
| `/api/models/{id}` | DELETE | 删除指定模型 |
| `/api/switch` | POST | 切换 API 供应商 |
| `/api/clear` | POST | 清空当前配置 |
| `/api/keys` | GET | 获取API密钥状态 |
| `/api/keys` | POST | 设置API密钥 |


## 注意事项

* 如果使用 BAT 启动器，请确保 BAT 和 `switch.ps1` 在同一目录，或者修改 BAT 中路径。
* 第一次切换时可能会写入用户环境变量，Windows 系统会有短暂延迟（几秒）。
* 建议在 用户环境变量 中设置好 `DEEPSEEK_API_KEY`、`GLM_API_KEY`、`KIMI_API_KEY` 环境变量。


## 兼容性

* Windows 10 / 11
* PowerShell 5.1 或 PowerShell 7+
* 脚本不依赖外部模块

---

## 开源许可

MIT License © 2025 \MaNongJSZ
