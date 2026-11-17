---
name: cloudflare-tunnel
description: "用 Cloudflare Tunnel（cloudflared）把本机或内网的 HTTP 服务公开成 https://<sub>.<domain>，不需要公网 IP，也不用在路由器上开端口。适用于用户要让外网访问本机服务、在控制台创建隧道、在 Windows 上安装 cloudflared 并装成开机自启服务、自定义 cloudflared 安装目录、添加 Published application 路由，或排查隧道 Healthy 但网址打不开的问题。只用免费额度，Buy more tunnels 等付费项跳过。"
metadata:
  version: "1.1"
  verified: "2026-11-17"
---

# Cloudflare Tunnel（cloudflared）

## 它是干什么的

你电脑上的 `cloudflared` 主动连上 Cloudflare，并一直保持这条连接。外网访问 `https://<sub>.<domain>` 时，Cloudflare 顺着这条连接把请求转给你电脑上的服务，再把结果送回去。

```
访问者 → https://<sub>.<domain> → Cloudflare ⇄（隧道，由你电脑主动建立）⇄ cloudflared → http://localhost:<local-port>
```

- 不需要公网 IP，不用开路由器端口，本机防火墙也不用放行入站。
- 电脑关机或 `cloudflared` 服务停止，网址就打不开。
- 隧道本身不做鉴权，谁知道网址都能访问。公开前先确认后端服务自己有鉴权（例如 magpie 的网关密钥）。

## 前提

- 一个已在 Cloudflare 上的域名，见 [../cloudflare-domain-registration/SKILL.md](../cloudflare-domain-registration/SKILL.md)。
- 本机服务已经在 `http://localhost:<local-port>` 跑起来，本机能访问。

## 免费额度

- 每个账号免费 1000 个隧道，个人用不完。
- 控制台里的 **Buy more tunnels** 不要点。

## 步骤

1. **建隧道**：主控制台左侧 **Networking → Tunnels → Create Tunnel**（新版控制台已不在 Zero Trust 里）。起个名字，比如服务名 `<tunnel-name>`。
2. **选系统**：选操作系统和架构（例如 Windows 64-bit）。页面会给出一条 `service install <token>` 命令。
   - `<token>` 是隧道密钥，等于这条隧道的钥匙。不要外传，截图前打码。
3. **运行 cloudflared**：先检查是否已有 `Cloudflared` 服务。已有服务时保留原配置，临时测试使用独立进程，不再次执行 `service install`，详见安装说明。首次长期部署才安装开机自启服务。按系统看 [references/install-cloudflared.md](references/install-cloudflared.md)。要放到自定义目录也在这里。
4. **确认连上**：控制台里隧道状态变成 **Healthy**，Replicas 为 1。Windows 可以运行 `Get-Service Cloudflared`，应显示 `Running`，启动类型 `Automatic`。
5. **加路由**：进隧道 → **Routes → Add route → Published application**，详见 [references/routes.md](references/routes.md)：
   - Subdomain：`<sub>`（例如 `api`）
   - Domain：选 `<domain>`
   - Path：留空
   - Service URL：`http://localhost:<local-port>`（必须带 `http://`）
   保存后 DNS 记录会自动建好，不用自己去 DNS 页加。
6. **测试**：在任意一台电脑上运行：
   ```
   curl -i https://<sub>.<domain>/
   ```
   也可以用脚本：Linux 运行 `bash scripts/check-tunnel.sh <sub>.<domain>`，Windows 运行 `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-tunnel.ps1 -HostName <sub>.<domain>`。
   确认响应来自目标后端（例如 magpie 的 JSON 鉴权错误），才算后端链路连通。单独看到 401/403 状态码不足以判断，Cloudflare Access 或 WAF 也可能返回这些状态。连不上看 [references/troubleshooting.md](references/troubleshooting.md)。

## 常见坑

- Path 里填了内容（比如误填 `HTTP`），请求会匹配不上。灰色的 `*/blog` 只是示例提示，实际为空。
- Service URL 不带 `http://`，或协议写错（后端是 HTTP 却写了 HTTPS）。
- 隧道显示 Healthy 但 Routes 显示 No routes：还没加路由。
- 后端通过请求头判断“是否来自本机”的（例如看 `X-Forwarded-For`、`Cf-Connecting-IP`），经隧道转来的请求会被当成外部请求，这是正常的。

## 官方文档

- https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/
- https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/get-started/create-remote-tunnel/
- https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/downloads/
- https://github.com/cloudflare/cloudflared/releases

## 临时测试与恢复

测试前记录已有隧道、路由、DNS、本地服务和网关共享配置。创建名称明确的临时隧道及单级子域名，不覆盖已有入口。只使用免费额度，不购买域名、升级套餐或调用付费模型。

结束后按以下顺序清理：

1. 删除临时 Published application 路由。2026-11-17 控制台实测会一并删除没有其他路由共用的对应 DNS，确认成功提示包含 DNS record deleted；否则手动检查并删除本次创建的 DNS。
2. 停止自己启动的临时 cloudflared 进程，只按记录的 PID 操作，不批量终止 cloudflared，也不停止原有服务。
3. 删除临时 Tunnel。直接删除 Tunnel 不会自动清理 DNS，所以不能跳过第一步。
4. 如测试修改了共享设置或创建了网关密钥，恢复原设置并撤销测试密钥。确认原隧道仍 Healthy、原入口仍可访问。
5. 移除本次临时令牌文件；如果复制过令牌，完成后清空剪贴板中的令牌。不要把令牌或原有密钥写入报告、仓库和日志。

## 实测边界（2026-11-17）

已验证新建远程管理 Tunnel、Windows 独立进程连接至 Healthy / 1 个实例、添加 Published application、自动创建 DNS、公网转发至 magpie，以及路由、DNS、Tunnel 和临时进程清理。已有 Windows 服务保持运行。

未在本次复测中验证首次下载安装或重新注册 Windows 服务。服务显示 Automatic 也不等于已经验证重启电脑后的自启动。