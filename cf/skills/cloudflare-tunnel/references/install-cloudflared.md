# 安装 cloudflared 并装成开机自启服务

`<token>` 是控制台“选系统”那一步给出的命令里 `service install` 后面那一长串。`<install-dir>` 是你想放 cloudflared 的目录。

## Windows（PowerShell）

### 方式 A：winget（默认路径）

```powershell
winget install --id Cloudflare.cloudflared
```

默认装到 `C:\Program Files (x86)\cloudflared\cloudflared.exe`。然后在**管理员** PowerShell 里：

```powershell
& "C:\Program Files (x86)\cloudflared\cloudflared.exe" service install <token>
```

### 方式 B：自定义目录（独立 exe，推荐想放到 D 盘之类的情况）

cloudflared 只是一个独立的 exe，不需要安装，放在哪都能跑。

```powershell
# 仅在明确要迁移安装且已记录原服务配置时卸载；已有正常服务的临时测试不要执行
winget uninstall --id Cloudflare.cloudflared

New-Item -ItemType Directory -Force -Path "<install-dir>"
Invoke-WebRequest -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -OutFile "<install-dir>\cloudflared.exe"
& "<install-dir>\cloudflared.exe" --version
```

然后在**管理员** PowerShell 里：

```powershell
& "<install-dir>\cloudflared.exe" service install <token>
```

注意：

- 这会注册一个名为 `Cloudflared` 的 Windows 服务，开机自动启动。
- 服务直接从 `<install-dir>` 运行。
- 路径里有空格时，整个路径要用引号包住，前面加 `&`。

### 检查

```powershell
Get-Service Cloudflared | Select-Object Name, Status, StartType   # 应为 Running / Automatic
& "<install-dir>\cloudflared.exe" --version
```

## Linux（下载独立二进制）

```bash
mkdir -p "<install-dir>"
curl -L -o "<install-dir>/cloudflared" https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x "<install-dir>/cloudflared"
"<install-dir>/cloudflared" --version
```

下载页：https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/downloads/

## 已有服务时的临时测试

先运行 `Get-Service Cloudflared` 检查现有服务。已有正常服务时复用其 cloudflared 可执行文件，但用新建临时 Tunnel 的令牌启动独立进程，不安装第二个同名服务，不卸载原安装。

```powershell
# 令牌通过隐藏输入读取，不写入脚本或命令历史。
$testTokenSecure = Read-Host '输入临时 Tunnel 令牌' -AsSecureString
$testTokenCredential = [pscredential]::new('临时令牌', $testTokenSecure)
$testToken = $testTokenCredential.GetNetworkCredential().Password
$testConnector = Start-Process -FilePath '<cloudflared-exe>' -ArgumentList @('tunnel', 'run', '--token', $testToken) -WindowStyle Hidden -PassThru
$testConnector.Id
Remove-Variable testToken, testTokenCredential, testTokenSecure
```

进程运行时令牌会出现在该进程的启动参数中，避免输出完整命令行。记录 PID，测试结束只停止该进程：

```powershell
Stop-Process -Id $testConnector.Id
Get-Service Cloudflared | Select-Object Name, Status, StartType
```

上述脚本是可复用示例；2026-11-17 实际测试采用相同的独立进程方式，未重新安装现有服务。界面复制令牌如果触发浏览器权限提示，按当前浏览器工具要求处理；不要绕过权限弹窗。