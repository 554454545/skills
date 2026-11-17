# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-tunnel.ps1 -HostName <sub>.<domain> [-Path /]
# Checks whether the public hostname reaches the backend through the tunnel.
# ASCII only on purpose: Windows PowerShell 5.1 misreads BOM-less UTF-8 scripts.
param(
  [Parameter(Mandatory = $true)][string]$HostName,
  [string]$Path = "/"
)
$code = & curl.exe -s -o NUL -w "%{http_code}" --max-time 20 "https://$HostName$Path"
switch ($code) {
  "000" { Write-Output "Unreachable (000): DNS not ready or tunnel not connected"; exit 1 }
  "502" { Write-Output "502: tunnel is up but cloudflared cannot reach the local service; check Service URL"; exit 1 }
  "530" { Write-Output "530/1033: tunnel not connected; check the cloudflared service"; exit 1 }
  default { Write-Output "Tunnel OK, backend returned HTTP $code" }
}
