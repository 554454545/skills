---
name: cloudflare-domain-registration
description: "在 Cloudflare Registrar 按成本价注册、续费或转出域名（.dev/.app/.com/.ai 等）。适用于用户要买域名、比较域名价格、判断一次买多年还是逐年续费、填写注册人（ICANN）信息和账单地址、关闭或开启自动续费、处理到期/宽限期/赎回期，或把域名转到别的注册商时。只用免费功能，付费附加项一律跳过。"
metadata:
  version: "1.0"
  verified: "2026-11-17"
---

# Cloudflare 域名注册（Registrar）

Cloudflare Registrar 按注册局成本价卖域名，不加价。注册后域名直接托管在 Cloudflare 上，DNS、SSL、Tunnel 等都能免费用。

## 什么时候用

- 想要一个自己的域名，用来挂 Tunnel、Pages、Workers 或收邮件。
- 免费的 `*.pages.dev`、`*.workers.dev` 在国内经常打不开，需要自己的域名。
- 要续费、改自动续费或转出已有域名。

## 先知道的规则

- 只能用 Cloudflare 的 nameserver，不能改用别家 DNS。
- 注册、续费最多 10 年；付款后不退款，下单前确认拼写。
- 默认开启自动续费，约在到期前 30 天扣款。
- 新注册的域名 60 天内不能转出。
- 价格细节和一次买多年怎么算，见 [references/pricing-and-renewal.md](references/pricing-and-renewal.md)。

## 注册步骤

1. 登录 Cloudflare 控制台，左侧 **Domains（域名）** → **域名注册 / Register Domains**。
2. 搜索想要的名字，看首年价和续费价（两者可能不同，促销只管第一年）。
3. 选好年限，加入 **Cart**，进入结账。
4. 填注册人信息（ICANN 要求，必填），见 [references/checkout-registrant-info.md](references/checkout-registrant-info.md)。
5. 填付款信息。账单地址必须和信用卡在发卡行登记的地址一致。
6. 结账页出现的付费附加项（如有）一律跳过；Stripe Link 的“保存信息”是可选的，可以不勾。
7. 提交后几分钟，域名会出现在 **Domains** 概览里，状态“有效”，套餐“免费”。

## 注册之后

- 子域名免费、数量不限，在 DNS 里加记录即可；用 Tunnel 加路由时会自动建好，见 [../cloudflare-tunnel/SKILL.md](../cloudflare-tunnel/SKILL.md)。
- `.dev`、`.app` 在浏览器里强制 HTTPS（HSTS preload），Cloudflare 会自动签好证书，不用手动处理。
- 想关自动续费：域名的管理页里找到 Auto-renew 开关关掉（菜单名以控制台为准）。关了以后要自己记得在到期前续。
- 到期和转出的流程见 [references/transfer-and-resale.md](references/transfer-and-resale.md)。

## 安全提醒

- 完整卡号、安全码（CVC）不要截图发给任何人，也不要写进笔记或文档。
- 注册人邮箱必须能收信，ICANN 验证邮件不点会导致域名被暂停。

## 官方文档

- https://developers.cloudflare.com/registrar/
- https://developers.cloudflare.com/registrar/get-started/register-domain/
- https://www.cloudflare.com/products/registrar/
