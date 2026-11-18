# 浏览器自动化细节（ego / Playwright 类工具）

2026-11-18 用 ego 浏览器实测撤掉一个 demo 子域名时记录的定位方式。按钮多为无 id 的 React 组件，以下选择器可能随网站改版变化，失效时按可见文字重新定位。

## Cloudflare DNS 记录

| 步骤 | 定位方式 |
|---|---|
| 记录行的编辑按钮 | `button[aria-label="Edit CNAME record with name demo.<domain>"]`（A 记录则是 `Edit A record with name …`） |
| 核对内容 | `input[name=name]` 的值是子域名前缀，`textarea[name=target]` 的值是 Vercel 目标 |
| 删除 | 编辑区里可见文字为 `Delete` 的按钮 |
| 二次确认 | `[role=dialog]` 内文字为 `Delete` 的按钮（页面上会同时有两个 Delete，要限定在弹窗内） |
| 成功判据 | 所有 `button[aria-label^="Edit"]` 里已没有该子域名 |

## Vercel 删除项目

| 步骤 | 定位方式 |
|---|---|
| 入口 | `https://vercel.com/<团队>/<项目名>/settings`，可见文字 `Delete Project` 的 `button`（先 `scrollIntoView`） |
| 项目名输入框 | `[role=dialog] input[name=resourceName]` |
| 确认语输入框 | `[role=dialog] input[name=verificationText]`，填 `delete my project` |
| 确认按钮 | `[role=dialog]` 内文字为 `Delete Project` 且未 disabled 的按钮 |
| 成功判据 | URL 变为 `…?projectDeleted=<项目名>`，团队首页不再出现该项目名 |

## GitHub 删除仓库

| 步骤 | 定位方式 |
|---|---|
| 入口 | `https://github.com/<账号>/<仓库>/settings`，文字 `Delete this repository` 的按钮 |
| 三步确认 | 依次点 `I want to delete this repository`、`I have read and understand these effects` |
| 输入框 | `input#verification_field`，填 `<账号>/<仓库>` |
| 最终按钮 | 弹窗内文字为 `Delete this repository` 且未 disabled 的最后一个按钮 |
| 成功判据 | 跳到 `https://github.com/<账号>?tab=repositories`，提示 `was successfully deleted` |

若 GitHub 要求重新输入密码或 2FA（sudo 模式），交给用户完成。

## ego 用法提醒

1. 一个目标一个 TaskSpace，结束时 `task.finish({ keep: [] })`。
2. `page.click` 只收 CSS 选择器：先用 `page.evaluate` 给目标元素加 `data-x` 属性，再点 `[data-x="…"]`。
3. `taskSpace("名字")` 若提示 page label 不存在，用返回的 space 编号和已有 page（如 `p1`）重连。
