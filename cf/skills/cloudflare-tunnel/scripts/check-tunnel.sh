#!/usr/bin/env bash
# 用法：bash scripts/check-tunnel.sh <sub>.<domain> [path]
# 检查公网地址能否经隧道连到后端，打印 HTTP 状态码。
set -euo pipefail
host="${1:?用法: check-tunnel.sh <sub>.<domain> [path]}"
path="${2:-/}"
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "https://${host}${path}" || true)
case "$code" in
  000) echo "连不上：DNS 未生效或隧道未连接 (code=000)"; exit 1 ;;
  502) echo "502：隧道已连上，但 cloudflared 连不到本机服务，检查 Service URL"; exit 1 ;;
  530) echo "530/1033：隧道未连接，检查 cloudflared 服务"; exit 1 ;;
  *)   echo "隧道已通，后端返回 HTTP ${code}" ;;
esac
