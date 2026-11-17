# 排查

先用 `curl -i https://<sub>.<domain>/` 看返回什么，或运行 [../scripts/check-tunnel.sh](../scripts/check-tunnel.sh) / [../scripts/check-tunnel.ps1](../scripts/check-tunnel.ps1)。

| 现象 | 可能原因 | 处理 |
| --- | --- | --- |
| 连不上（curl 返回码 000） | 域名解析不到：没加路由，或 DNS 还没生效 | 检查 Routes 有没有这条；等几分钟再试 |
| 530，Cloudflare 错误页 1033 | 隧道没连上 | 检查 cloudflared 服务；控制台是否 Healthy |
| 后端返回 401/403 | 隧道已通，是后端自己的鉴权 | 按后端要求带密钥 |

## 检查服务（Windows）

```powershell
Get-Service Cloudflared   # 应为 Running
```
