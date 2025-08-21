# Claude Code API Switcher

一个在 Windows 上快速切换 Claude Code API 供应商的工具，支持 **DeepSeek、GLM-4.5、Kimi** 等模型。  
通过 PowerShell 脚本 + BAT 启动器，支持 **当前会话立即生效** 和 **用户环境变量持久化**，兼容 **PowerShell 5.1 和 7+**。

## 文件结构

```

├─ scc.bat          # 启动器，双击即可运行
├─ switch.ps1       # 主脚本，包含交互菜单和环境变量设置逻辑

````

## 功能特点

- 在终端交互菜单中选择兼容 Claude API 供应商
- 当前 PowerShell 会话立即生效
- 用户环境变量持久化，新开 PowerShell 窗口也能生效
- 清空当前 API 配置
- 支持 PowerShell 5.1 与 PowerShell 7+
- 异步写入环境变量


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


## 注意事项

* 如果使用 BAT 启动器，请确保 BAT 和 `switch.ps1` 在同一目录，或者修改 BAT 中路径。
* 第一次切换时可能会写入用户环境变量，Windows 系统会有短暂延迟（几百毫秒至几秒）。
* 建议在 用户环境变量 中设置好 `DEEPSEEK_API_KEY`、`GLM_API_KEY`、`KIMI_API_KEY` 环境变量。


## 兼容性

* Windows 10 / 11
* PowerShell 5.1 或 PowerShell 7+
* 脚本不依赖外部模块

---

## 开源许可

MIT License © 2025 \MaNongJSZ
