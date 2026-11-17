# 到期与转出

## 到期

- 默认自动续费，约在到期前 30 天扣款。
- 关掉自动续费后，到期后（大多数后缀）：第 1–30 天宽限期照常解析、正常价可续；第 31–40 天暂停期仍可续；第 41–70 天赎回期要另交恢复费；第 71–75 天待删除，之后释放。详见 [pricing-and-renewal.md](pricing-and-renewal.md)。
- 续费加的年数接在原到期日后面，总年限不超过 10 年。

## 转出到其他注册商

1. 确认域名注册已满 60 天（新注册 60 天内不能转出）。
2. 在 Cloudflare 的域名管理页里解锁域名（关闭 transfer lock）。
3. 获取 Auth Code（转移授权码）。
4. 到新注册商发起转入，填 Auth Code，按对方流程付款。
5. 转出后 DNS 不再由 Cloudflare Registrar 管理；如果还想用 Cloudflare DNS，需要在新注册商那里把 nameserver 指回 Cloudflare。

具体按钮名以控制台为准，流程参考官方文档：https://developers.cloudflare.com/registrar/account-options/transfer-out-from-cloudflare/
