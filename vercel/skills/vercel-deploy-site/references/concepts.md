# 概念：VPS、Vercel、Cloudflare Pages、本机 + 隧道

| 方案 | 网站跑在哪 | 本机要开着吗 | 需要自己维护服务器吗 | 费用 | 适合 |
|---|---|---|---|---|---|
| 本机 + Cloudflare Tunnel | 自己电脑 | 要 | 要（自己电脑） | 免费 | 临时演示、本机服务（如 magpie 网关） |
| Vercel | Vercel 的服务器 + 全球 CDN | 不用 | 不用 | Hobby 免费 | 博客、作品集、Next.js/Astro 站点、轻量接口 |
| Cloudflare Pages | Cloudflare 的 CDN | 不用 | 不用 | 免费 | 静态站；域名本来就在 Cloudflare 时最顺手 |
| VPS | 租来的一整台服务器 | 不用 | 要（系统、Nginx、证书、安全全自己管） | 一般按月付费 | 需要长期后台进程、数据库、机器人等 |

要点：

1. Vercel / Pages 不是“送你一台 VPS”，而是“免费帮你托管网站”。你碰不到服务器，只交代码；打包、发布、HTTPS、CDN 它全包。代价是跑不了长期常驻的后台程序。
2. 它们为什么免费：个人小站成本极低；先让开发者免费用顺手，团队/商业用途再付费（Pro、企业版）；顺便推广自家框架（Vercel → Next.js）。
3. 选哪家主要看项目按谁配的：原项目用 Vercel 适配器就用 Vercel，换 Pages 需要改适配器。
4. 域名不用重新买：域名继续放在 Cloudflare，只加一条 CNAME 指向 Vercel。
