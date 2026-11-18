---
name: vercel-remove-site
description: "把用 vercel-deploy-site 部署上线的网站干净地撤掉、恢复现场：删除 Cloudflare 上的子域名 DNS 记录、删除 Vercel 项目，按需删除 GitHub Fork 和本地副本，并验证子域名已失效、其他站点不受影响。适用于用户说“把这个 demo 去掉”、“撤掉测试站”、“这个子域名不要了”、“恢复原样”时。全程只用免费功能，不开任何付费项。"
metadata:
  version: "1.0"
  verified: "2026-11-18（ego 浏览器实测：撤掉一个测试项目及其 demo 子域名，同域名下的其他站点不受影响）"
---

# 撤掉 Vercel 网站并恢复现场

部署时是「仓库 → Vercel 项目 → Cloudflare 子域名」，撤掉时反过来，**由外到内**：先断子域名，再删 Vercel 项目，最后才考虑仓库和本地文件。这样任何时刻都不会出现「子域名指向一个已经不存在的项目」。

```mermaid
flowchart LR
  A["1. 盘点<br/>要删什么 / 不能删什么"] --> B["2. Cloudflare<br/>删 CNAME 记录"]
  B --> C["3. Vercel<br/>Delete Project"]
  C --> D["4. 按需<br/>GitHub Fork / 本地副本"]
  D --> E["5. 验证<br/>子域名失效，其他站正常"]
```

## 1. 先盘点，再动手

删除都不可恢复，动手前列清楚并和用户确认：

1. 要撤的子域名（如 `demo.<domain>`）和它对应的 Vercel 项目名（如 `blog-demo`）。在 Vercel 某个项目的 **Settings → Domains** 看不到这个子域名时，它多半挂在另一个项目上，切换项目再找。
2. **共享的东西不能删**：多个 Vercel 项目可能连着同一个 GitHub 仓库（如 `blog` 和 `blog-demo` 都用 `<账号>/blog`）。这种情况只删 Vercel 项目，**仓库和本地副本一律保留**。
3. 同一域名下的其他 DNS 记录（如 `blog`、`api`）不要碰。

## 2. Cloudflare：删除子域名记录

1. 打开 `https://dash.cloudflare.com/<账户ID>/<domain>/dns/records`（或 Domains → 选域名 → DNS → Records）。首次进入有 **Got it** 引导遮罩，先点掉。
2. 找到该子域名那行，点 **Edit**。
3. 核对弹窗里的 Name 和 Target（Target 应是这个项目的 `xxx.vercel-dns-0xx.com`），确认无误后点左下角 **Delete**。
4. 二次确认框「Delete record / Are you sure…」里再核对一遍表格，点 **Delete**。
5. 记录列表里该行消失即可，其余记录应原样保留。

## 3. Vercel：删除项目

1. 打开 `https://vercel.com/<团队>/<项目名>/settings`（项目 → **Settings → General**），拉到最底部。
2. 点 **Delete Project**，弹窗要填两个框：
   1. 「To confirm, type "<项目名>"」：输入项目名。
   2. 「To confirm, type "delete my project"」：输入 `delete my project`。
3. 两个都填对后 **Delete Project** 按钮才可点，点击。
4. 跳到 `https://vercel.com/<团队>?projectDeleted=<项目名>`，项目列表里不再有它就成功了。项目自带的部署、域名绑定、`xxx.vercel.app` 地址和环境变量会一起删掉，不用单独处理。

只想下线子域名、保留项目时，改为在 **Settings → Domains** 里对该域名点 **Edit → Remove**，再做第 2 步。

## 4. 按需：GitHub Fork 和本地副本

只有仓库是为这次测试专门 Fork、且没有别的项目在用时才删，并且要用户明确同意。

1. **GitHub**：仓库 **Settings** 拉到底 Danger Zone → **Delete this repository** → **I want to delete this repository** → **I have read and understand these effects** → 输入 `<账号>/<仓库>` → **Delete this repository**。成功后跳到仓库列表，顶部提示 `was successfully deleted`。GitHub 连接器一般没有删库能力，只能走网页。
2. **本地副本**：先停掉 `pnpm run dev` 等开发服务器。Windows 上用 `cmd /c 'rd /s /q "<目录>"'` 删除，比 `Remove-Item` 更能处理很深的 `node_modules`。报「在使用中」时，多半是终端当前目录就在里面，先 `cd` 出来。

## 5. 验证

运行 `scripts/check-removed.ps1 -Removed demo.<domain> -Keep blog.<domain>`，或手动：

1. 用公共 DNS 查：子域名应返回 **NXDOMAIN**（DoH 结果 `"Status":3`）。
2. 保留的站点仍是 **200**。
3. Vercel 项目列表和 Cloudflare 记录列表里都已没有它。

注意：本机开着 Clash 等代理时，系统 DNS 会给出 `198.18.x.x` 假 IP，且可能还缓存着旧记录，访问会得到 Vercel 的 **404** 而不是解析失败。这不代表没删干净，以公共 DNS（DoH）结果为准。

## 用浏览器自动化执行

细节见 `references/automation-notes.md`。要点：

1. 三个站都要已登录；未登录交给用户。
2. 每次点击前先读出要删的那一行或那个项目的名字核对，确认是目标再点；绝不批量点 Delete。
3. Cloudflare 的 Edit 按钮可用 `button[aria-label="Edit CNAME record with name <子域名>"]` 精确定位。

## 安全与费用

- 删除操作本身不收费，也不需要开任何付费项。
- 每一步删除前都要确认对象；共享仓库、其他子域名、其他 Vercel 项目一律不动。
