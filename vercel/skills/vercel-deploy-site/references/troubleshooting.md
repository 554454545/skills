# 常见问题

## 部署失败：invalid "runtime" ... (nodejs18.x)

日志特征：

```
[WARN] [@astrojs/vercel] The local Node.js version (26) is not supported by Vercel Serverless Functions.
Your project will use Node.js 18 as the runtime instead.
The following Serverless Functions contain an invalid "runtime": - _render (nodejs18.x)
```

新建项目时 Node.js Version 默认是最新（实测为 `26.x`），所以**每个新项目首次部署都会遇到**，不是偶发。

原因：Vercel 默认用较新的 Node 打包，项目里的旧版适配器不认识，回退到已停用的 Node 18。

解决（不用改代码）：

1. 项目 **Settings → Build and Deployment → Node.js Version** 选 `22.x` → Save。
2. **Deployments** → 失败那条右侧 `⋯` → **Redeploy**；弹窗里**取消勾选 “Use project's Ignore Build Step”**，避免项目自带的跳过脚本把这次构建跳过。

## Redeploy 弹窗选项

- Environment 保持 Production。
- “Use existing Build Cache” 可不勾。
- 若项目 `vercel.json` 里有 `ignoreCommand`，手动重部署时取消 “Use project's Ignore Build Step”。

## 域名一直 Invalid Configuration

1. Cloudflare 里记录的 Name / Target 是否和 Vercel 显示的一致（用复制按钮）。
2. Proxy status 必须是灰色 **DNS only**。
3. 同名子域名不能已有别的记录（如 Tunnel 记录），有冲突先删。
4. 等几分钟后在 Vercel 点 Refresh。

## 首次部署要验证码

Vercel 会给注册邮箱发 6 位码（主题 `Your Vercel security code: xxxxxx`，5 分钟有效），在垃圾邮件里也找找。

## Fork 页提示 No available destinations

账号下已经有这个仓库的 Fork（可能改过名）。不能再 fork 第二份；直接用已有 Fork 在 Vercel 新建项目。

## 检查脚本里 IP 是 198.18.x.x

这是本机代理（Clash 等）的 fake-IP，不代表解析错。以 HTTPS 是否 200、`Server: Vercel` 为准，或用 `Resolve-DnsName <域名> -Server 1.1.1.1` 看真实 CNAME。

## 本地改了网站没变

Vercel 只认 GitHub 仓库。确认已 `git push`，且 `git remote -v` 指向自己的 Fork，而不是原作者仓库。

## 删除本地项目目录报「在使用中」

- 现象：`Remove-Item` 报「因为它在使用中」或删了一半。
- 原因：当前终端停在该目录里（之前 `cd` 进去过），或 `pnpm run dev` 等进程还开着。
- 解决：`cd` 到别的目录，结束相关 node 进程，再用 `cmd /c 'rd /s /q "<目录>"'` 删除。

## 连接器删不了 GitHub 仓库

- GitHub 连接器/API 工具一般没有删除仓库的能力，删除走网页：仓库 Settings → Danger Zone → Delete this repository（三步确认，最后输入 `<账号>/<仓库>`）。
