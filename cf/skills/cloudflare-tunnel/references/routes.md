# 添加 Published application 路由

路由告诉隧道：访问哪个网址时，转发到本机哪个服务。

## 步骤

1. 控制台 **Networking → Tunnels**，点进要用的隧道。
2. **Routes → Add route**，类型选 **Published application**（旧版叫 Public hostname）。
3. 填写：

| 字段 | 填法 | 说明 |
| --- | --- | --- |
| Subdomain | `<sub>`，例如 `api` | 留空则用根域名 |
| Domain | 下拉选 `<domain>` | 只能选本账号里的域名 |
| Path | 留空 | 只有按路径分流时才填；灰色 `*/blog` 是示例提示 |
| Service URL | `http://localhost:<local-port>` | 必须带协议前缀 |

4. 页面会预览完整地址 `<sub>.<domain>`，确认后点 **Add route**。
5. 对应的 DNS 记录会自动创建，不用自己去 DNS 页加。
