<#
.SYNOPSIS
  验证子域名已撤掉、保留的站点仍正常。用公共 DNS（DoH）判断，绕开本机代理的假 IP 和缓存。
.EXAMPLE
  .\check-removed.ps1 -Removed demo.example.dev -Keep blog.example.dev
#>
param(
  [Parameter(Mandatory)][string[]]$Removed,
  [string[]]$Keep = @()
)

function Get-DoH([string]$Name) {
  $u = "https://cloudflare-dns.com/dns-query?name=$Name&type=CNAME"
  try { Invoke-RestMethod $u -Headers @{ accept = 'application/dns-json' } -TimeoutSec 15 }
  catch { $null }
}

$rows = @()
foreach ($n in $Removed) {
  $r = Get-DoH $n
  $state = if ($null -eq $r) { '查询失败' } elseif ($r.Status -eq 3) { '已删除（NXDOMAIN）' } elseif ($r.Answer) { "仍存在：$($r.Answer[0].data)" } else { "状态码 $($r.Status)" }
  $rows += [pscustomobject]@{ 域名 = $n; 期望 = '已撤掉'; 结果 = $state }
}
foreach ($n in $Keep) {
  try { $code = (Invoke-WebRequest "https://$n" -UseBasicParsing -TimeoutSec 20).StatusCode } catch { $code = $_.Exception.Message }
  $rows += [pscustomobject]@{ 域名 = $n; 期望 = '保持在线'; 结果 = "HTTP $code" }
}
$rows | Format-Table -AutoSize | Out-String | Write-Host
Write-Host '提示：本机开着 Clash 等代理时，系统 DNS 可能仍返回 198.18.x.x 假 IP，以上面的公共 DNS 结果为准。'
