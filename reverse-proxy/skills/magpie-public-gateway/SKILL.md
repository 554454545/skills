---
name: magpie-public-gateway
description: "把本机的 magpie 模型网关（OpenAI 兼容 /v1 接口，默认端口 3425）通过 Cloudflare Tunnel 公开成 https://api.<domain>/v1，用 magpie 网关密钥鉴权后给别人使用。适用于要把 magpie 分享给别人、给某人新建网关密钥，或外网访问返回 401/403 时。"
metadata:
  version: "1.3"
  verified: "2026-11-17"
---

# magpie 公网网关（Cloudflare Tunnel 反代）

本 skill 包含操作步骤和 2026-11-17 复测结果；已验证与未验证范围见文末。

## 整体结构

```
别人的客户端 → https://api.<domain>/v1 → Cloudflare → 隧道 → cloudflared → http://localhost:<local-port>（magpie，校验网关密钥）
```

- 隧道只负责把请求送到你的电脑，鉴权靠 magpie 的网关密钥。
- 你的电脑和 magpie 都开着，别人才能用；对方消耗的是你的额度。

## 前提

- Cloudflare 上已有域名 `<domain>`。
- magpie 已在本机运行（默认端口 3425）。

## 步骤

1. **建隧道并加路由**：按 [../../../cf/skills/cloudflare-tunnel/SKILL.md](../../../cf/skills/cloudflare-tunnel/SKILL.md) 操作，路由填：
   - Subdomain：`api`
   - Domain：`<domain>`
   - Path：留空
   - Service URL：`http://localhost:<local-port>`
2. **先检查当前共享状态**：仅本机模式下，公网请求可能返回 403，提示要开启局域网共享并带网关密钥；已开启共享但没有携带有效密钥时通常返回 401。这说明请求已经到了 magpie，是 magpie 在拒绝：经过隧道的请求带 `X-Forwarded-For` / `Cf-Connecting-IP`，magpie 把它当作来自其他机器，而默认只允许本机。
3. **开局域网共享**：magpie → **网关** 页 → “局域网共享”从 **本机** 切到 **局域网**。下面会出现 **网关密钥** 区块，里面已有默认的 `Magpie` 密钥（你自己的总钥匙，不要给别人）。
4. **给使用者建一个密钥**：点 **添加网关密钥**，见 [references/gateway-keys.md](references/gateway-keys.md)。
5. **从外网测试**：见 [references/testing.md](references/testing.md)。带密钥返回 200，不带密钥返回 401，就说明可以用了，不需要再额外加 Cloudflare 规则。
6. **把三项配置发给对方**：
   - Base URL：`https://api.<domain>/v1`
   - API Key：给对方建的那个密钥
   - 模型 id：例如 `codex/gpt-6-luna`

## 注意

- 密钥发到聊天里就算泄露了，建议在 magpie 里换一个新的。
- 电脑关机或 magpie 退出，接口就不可用。

## 免费复测与恢复

不调用模型时，使用 `/v1/models` 检查链路与鉴权：无密钥和无效密钥应返回 401，有效且允许局域网访问的网关密钥应返回 200 和模型列表。该测试不调用上游模型推理；不能据此声称对话生成也已验证。

临时测试优先复用已有共享设置；如必须调整，先记录原值。新建密钥仅限本次验证，结束后撤销；使用已有密钥验证时只在内存中读取，不在输出或报告中显示。清理临时路由、DNS、Tunnel 和独立进程的方法见 Tunnel Skill 的“临时测试与恢复”。

## 实测边界（2026-11-17）

新建临时 Tunnel 和临时子域名后，公网 `/v1/models` 无密钥 / 错误密钥均返回 401，复用已有有效网关密钥返回 200、8 个模型。临时路由、DNS、Tunnel 和进程已清理，原有入口仍返回预期鉴权响应。

本次没有切换原有共享模式、没有新建网关密钥，也没有执行模型推理；这些步骤不能算作本次已复测通过。独立上传本 Skill 时需同时保留可解析的 Tunnel Skill 引用或补充依赖位置，当前相对链接依赖 cf 与 reverse-proxy 两个目录并列摆放。
## 一键导出连接配置

用户需要分享 Base URL、指定使用者的网关密钥和模型时，运行 [scripts/export-connection.ps1](scripts/export-connection.ps1)。先确认目标域名是用户授权的网关，再发送网关密钥；不要把密钥发往任意输入的第三方地址。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <skill-dir>/scripts/export-connection.ps1 -BaseUrl https://api.<domain>/v1 -KeyName friend1 -Model codex/gpt-6-luna -OutputPath <本地私密目录>/friend1.txt
```

脚本从当前用户的 .config/magpie/caller-keys.json 读取唯一匹配的指定密钥，拒绝默认 Magpie 总密钥；可用 KeysPath 参数指定其他位置。请求实时模型列表，验证指定模型，导出 Base URL、完整 API Key、所选模型及全部可用模型。未指定 Model 时按排序选择首个模型，不代表性能推荐。文件已存在时停止，避免覆盖。

导出文件包含明文密钥，仅保存在本地私密目录，不能提交仓库或上传 Skill。默认不在聊天、终端显示密钥，不自动给他人发送；用户明确要求展示或分享时再按其指定目的处理。exports/ 已加入此目录的忽略规则。脚本只读取配置和模型列表，不创建密钥、调整共享模式或调用模型推理；这些前置步骤仍需单独完成。Windows PowerShell 5.1 使用带 BOM 的 UTF-8 脚本。

补充实测：2026-11-17，用户另行授权后，现有公网入口使用 friend1 密钥调用 codex/gpt-6-luna 的 chat/completions，HTTP 200，回复“通了”。此次未改变原网关配置。