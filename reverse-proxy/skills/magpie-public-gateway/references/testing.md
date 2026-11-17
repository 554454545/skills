# 网关测试

`<api-key>` 换成真实密钥。在 bash 里运行：

```bash
# 不带密钥：期望 401
curl -s -o /dev/null -w '%{http_code}\n' https://api.<domain>/v1/models

# 带密钥对话：期望 200，返回里有 choices
curl -s https://api.<domain>/v1/chat/completions \
  -H "Authorization: Bearer <api-key>" \
  -H "Content-Type: application/json" \
  -d '{"model":"codex/gpt-6-luna","messages":[{"role":"user","content":"回复两个字：通了"}]}'
```

## 结果判断

| 结果 | 含义 |
| --- | --- |
| 不带密钥 401，带密钥 200 | 正常，当天约 4.7 秒返回 |
| 403，提示局域网共享 | 先确认原共享状态；需要公开访问时再切到“局域网” |

## 不消耗模型推理额度的验证

优先执行模型列表请求，分别测试不带密钥、错误密钥和有效密钥；不要在“禁止花钱”的测试中执行上面的 chat/completions 请求。

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://<sub>.<domain>/v1/models
curl -s -o /dev/null -w '%{http_code}\n' https://<sub>.<domain>/v1/models -H 'Authorization: Bearer invalid-test-key'
# 真实密钥通过当前环境的安全输入或凭证机制注入，不写入脚本、仓库或命令历史。
curl -s https://<sub>.<domain>/v1/models -H "Authorization: Bearer ${GATEWAY_API_KEY}"
```

2026-11-17 复测：前两项均 401，第三项 200、8 个模型。对话示例属于另行授权的可选测试，可能消耗上游额度；本次未执行，也不保证示例模型在其他机器上可用，应从模型列表选择实际存在的模型。